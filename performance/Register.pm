package Register;

use strict;
use XML::Parser;
use XML::Writer;
use Data::Dumper;
use File::Temp qw(tempfile);
use File::Copy;
use Sys::Syslog;
use IPC::Open3;
use Fcntl qw(:DEFAULT);
use URI;
use URI::QueryParam;
use Time::HiRes qw(gettimeofday tv_interval);


# client version number
our $SRversion = "1.2.3";

sub readSystemValues
{
    my $ctx = shift;
    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: readSystemValues\n" if($ctx->{time});

    my $code = 0;
    my $msg = "";
    
    ############### batch mode ########################
    
    if($ctx->{batch})
    {
        # if --no-optional or --no-hw-data are not given in batch mode
        # read the sysconfig values for the default

        my $sysconfigOptional = "false";
        my $sysconfigHWData   = "false";
        
        
        open(CNF, "< $ctx->{sysconfigFile}") and do {
        
            while(<CNF>)
            {
                if($_ =~ /^\s*#/)
                {
                    next;
                }
                elsif($_ =~ /^SUBMIT_OPTIONAL\s*=\s*"*([^"\s]*)"*\s*/ && defined $1 && $1 ne "") 
                {
                    $sysconfigOptional = $1;
                    
                }
                elsif($_ =~ /^SUBMIT_HWDATA\s*=\s*"*([^"\s]*)"*\s*/ && defined $1 && $1 ne "") 
                {
                    $sysconfigHWData = $1;
                }
            }
            close CNF;
        };

        if(!$ctx->{nooptional})
        {
            if(lc($sysconfigOptional) eq "true")
            {
                $ctx->{nooptional} = 0;
            }
            else
            {
                $ctx->{nooptional} = 1;
            }
        }
        if(!$ctx->{nohwdata})
        {
            if(lc($sysconfigHWData) eq "true")
            {
                $ctx->{nohwdata} = 0;
            }
            else
            {
                $ctx->{nohwdata} = 1;
            }
        }
   }
        
    ############### read the config ###################
    if(-e $ctx->{configFile})
    {
        open(CNF, "< $ctx->{configFile}") or do 
        {
            return logPrintReturn($ctx, "Cannot open file $ctx->{configFile}: $!\n", 12);
        };
        
        while(<CNF>)
        {
            if($_ =~ /^\s*#/)
            {
                next;
            }
            elsif($_ =~ /^url\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "") 
            {
                $ctx->{URL} = $1;
            }
            elsif($_ =~ /^listParams\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "") 
            {
                $ctx->{URLlistParams} = $1;
            }
            elsif($_ =~ /^listProducts\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "") 
            {
                $ctx->{URLlistProducts} = $1;
            }
            elsif($_ =~ /^register\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "")
            {
                $ctx->{URLregister} = $1;
            }
            elsif($_ =~ /^hostGUID\s*=\s*(\w*)\s*/ && defined $1 && $1 ne "")
            {
                $ctx->{hostGUID} = $1;
            }
            elsif($_ =~ /^addRegSrvSrc\s*=\s*(\w*)\s*/ && defined $1)
            {
                if(lc($1) eq "true")
                { 
                    $ctx->{addRegSrvSrc} = 1;
                }
                else 
                {
                    $ctx->{addRegSrvSrc} = 0;
                }
            }
            elsif($_ =~ /^addAdSrc\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "")
            {
                push @{$ctx->{addAdSrc}}, $1;
            }
        }
        close CNF;
    }
    
    ############### GUID ##############################

    if(!-e $ctx->{GUID_FILE})
    {
        ($code, $msg) = rugStart($ctx);
        if($code != 0)
        {
            return ($code, $msg);
        }
    }
    
    open(ZMD, "< $ctx->{GUID_FILE}") or do 
    {
        return logPrintReturn($ctx, "Cannot open file $ctx->{GUID_FILE}: $!\n", 12);
    };
    
    $ctx->{guid} = <ZMD>;
    chomp($ctx->{guid});
    close ZMD;
    
    print STDERR "GUID:$ctx->{guid}\n" if($ctx->{debug});

    ############### find Products #####################

    ($code, $msg) = getProducts($ctx);
    if($code != 0)
    {
        return ($code, $msg);
    }
    
    ########## host GUID (virtualization) #############

    # spec not finished and this seems not to work

     if(-d "/proc/xen" &&
        -e $ctx->{xenstoreread}) 
     {
         print STDERR "Found XEN\n" if($ctx->{debug} >= 2);
       
         # FIXME: check if this command really returns what we want
         my $val = `$ctx->{xenstoreread} domid 2>/dev/null`;
         $code = ($?>>8);
         chomp($val);
        
         if($code == 0 && defined $val && $val eq "0")
         {
             print STDERR "We are Domain-0\n" if($ctx->{debug} >= 2);
           
             # we are Domain-0    
             if(-e $ctx->{xenstorewrite} && -e $ctx->{xenstorechmod}) 
             {
                 print STDERR "Write /tool/SR/HostDeviceID to xenbus\n" if($ctx->{debug});
               
                 `$ctx->{xenstorewrite} /tool/SR/HostDeviceID $ctx->{guid} 2>/dev/null`;
                 `$ctx->{xenstorechmod} /tool/SR/HostDeviceID r 2>/dev/null`;
             }
         }
         elsif($code == 0 && defined $val && $val ne "")
         {
             print STDERR "try to read /tool/SR/HostDeviceID from xenbus\n" if($ctx->{debug} >= 2);
             
             $val = `$ctx->{xenstoreread} /tool/SR/HostDeviceID 2>/dev/null`;
             chomp($val);
             
             if(defined $val && $val ne "") 
             {
                 print STDERR "Got /tool/SR/HostDeviceID: $val\n" if($ctx->{debug});
               
                 $ctx->{hostGUID} = $val;
             }
         }
         else
         {
             print STDERR "Cannot read from xenstore: $code\n" if($ctx->{debug});
         }
     }

    ############## some initial values ########################

    $ctx->{args}->{processor} = { flag => "i", value => `$ctx->{uname} -p`, kind => "mandatory"};
    $ctx->{args}->{platform}  = { flag => "i", value => `$ctx->{uname} -i`, kind => "mandatory"};
    $ctx->{args}->{timezone}  = { flag => "i", value => "US/Mountain", kind => "mandatory"};      # default


    open(SYSC, "< $ctx->{SYSCONFIG_CLOCK}") or do
    {
        return logPrintReturn($ctx, "Cannot open file $ctx->{SYSCONFIG_CLOCK}: $!\n", 12);
    };
    while(<SYSC>) 
    {
        if($_ =~ /^TIMEZONE\s*=\s*"?([^"]*)"?/) 
        {
            if(defined $1 && $1 ne "")
            {
                $ctx->{args}->{timezone}  = { flag => "i", value => $1, kind => "mandatory"};
            }
        }
    }
    close SYSC;
    
    chomp($ctx->{args}->{processor}->{value});
    chomp($ctx->{args}->{platform}->{value});

    print STDERR indent($ctx)."END: readSystemValues:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return (0, "");
}


sub cpuCount
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: cpuCount\n" if($ctx->{time});

    my $currentCPU = -1;
    my $info = {};
    
    my $haveCoreData = 0;
    my $useCoreID = 0;
    
    my $pid = -1;  # processor id
    my $cos = -1;  # cores
    my $cid = -1;  # core id
    
    my $out = "";

    my $type = `uname -m`;
    chomp($type);

    if($type =~ /ppc/i)
    {
        my $sockets = `grep cpu /proc/device-tree/cpus/*/device_type | wc -l`;
        $out = "CPUSockets: ".($sockets)."\n";
        return $out;
    }

    my $cpuinfo = `cat /proc/cpuinfo`;
    my @lines = split(/\n/, $cpuinfo);
    
    foreach my $line (@lines)
    {
        if( $line =~ /^processor\s*:\s*(\d+)\s*$/)
        {
            if($pid >= 0 )
            {
                if($cos >= 0)
                {
                    $info->{$pid} = $cos;
                    $pid = -1;
                    $cos = -1;
                    $cid = -1;
                }
                elsif($cid >= 0)
                {
                    # IA64 does have core id but not cores
                    if(! exists $info->{$pid} || $cid > $info->{$pid})
                    {
                        $useCoreID = 1;
                        $info->{$pid} = $cid;
                        $pid = -1;
                        $cos = -1;
                        $cid = -1;
                    }
                }
                else 
                {
                    $out = "Read Error";
                }
            }
            
            $currentCPU = $1;
        }
        elsif( $line =~ /^physical id\s*:\s*(\d+)\s*$/)
        {
            $haveCoreData = 1;
            $pid = $1;
        }
        elsif( $line =~ /^cpu cores\s*:\s*(\d+)\s*$/)
        {
            $haveCoreData = 1;
            $cos = $1;
        }
        elsif( $line =~ /^core id\s*:\s*(\d+)\s*$/)
        {
            $haveCoreData = 1;
            $cid = $1;
        }
        elsif( $line =~ /^processor\s+(\d+):/)
        {
            # this is used for s390
            $currentCPU = $1;
        }
    }
    
    print STDERR "       socket => cores \n" if($ctx->{debug} >= 2);
    print STDERR Data::Dumper->Dump([$info]) if($ctx->{debug} >= 2);
    
    if(!$haveCoreData && $currentCPU >= 0)
    {
        $out = "CPUSockets: ".($currentCPU + 1)."\n";
    }
    elsif(keys %{$info} > 0)
    {
        my $cores = 0;
        foreach my $s (keys %{$info})
        {
            $cores += $info->{$s};
            if($useCoreID)
            {
                $cores += 1;
            }
        }
        $out = "CPUSockets: ".(keys %{$info})."\nCPUCores  : $cores\n"
    }
    else
    {
        $out = "Read Error";
    }
    
    print $out if($ctx->{debug} >= 2);
    
    print STDERR indent($ctx)."END: cpuCount:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;
    
    return $out;
}

sub evalNeedinfo
{
    my $ctx = shift;
    my $tree      = shift || undef;
    my $logic     = shift || "";
    my $indent    = shift || "";
    my $mandatory = shift || 0;
    my $modified  = shift || 0;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: evalNeedinfo\n" if($ctx->{time});

    my $mandstr = "";

    my $nextLogic = $logic;
    if($#{$ctx->{registerReadableText}} >= 0) 
    {
        $indent = $indent."  ";
    }
        
    if (! defined $tree)
    {
        logPrintError($ctx, "Missing data.\n", 14);
        return $modified;
    }
 
    print STDERR "LOGIC: $logic\n" if($ctx->{debug} >= 3);
    print STDERR Data::Dumper->Dump([$tree])."\n" if($ctx->{debug} >= 3);

    foreach my $kid (@$tree)
    {
        my $local_mandatory = $mandatory;
        
        if (ref($kid) eq "SR::param") 
        {
            if (@{$kid->{Kids}} > 1)
            {
                $nextLogic = "AND";
            }
            if($logic eq "") 
            {
                $logic = $nextLogic;
            }
        }
        elsif (ref($kid) eq "SR::select")
        {
            $nextLogic = "OR";
            if($logic eq "")
            {
                $logic = $nextLogic;
            }
        }
        elsif (ref($kid) eq "SR::privacy")
        { 
            if (exists $kid->{description} && defined $kid->{description})
            {
                if(!$ctx->{yastcall})
                {
                    $ctx->{registerPrivPol} .= "\nInformation on Novell's Privacy Policy:\n";
                    $ctx->{registerPrivPol} .= $kid->{description}."\n";
                }
                else
                {
                    $ctx->{registerPrivPol} .= "<p>Information on Novell's Privacy Policy:<br>\n";
                    $ctx->{registerPrivPol} .= $kid->{description}."</p>\n";
                }
            }
            
            if (exists $kid->{url} && defined $kid->{url} && $kid->{url} ne "")
            {
                if(!$ctx->{yastcall})
                {
                    $ctx->{registerPrivPol} .= $kid->{url}."\n";
                }
                else
                {
                    $ctx->{registerPrivPol} .= "<p><a href=\"".$kid->{url}."\">";
                    $ctx->{registerPrivPol} .= $kid->{url}."</a></p>\n";
                }
            }
        }
        elsif (ref($kid) eq "SR::needinfo")
        {
            # do nothing
        }
        else
        {
            # skip host, guid, product and maybe more to come later. 
            # There are no strings for the user to display.
            next;
        }

        if (exists  $kid->{class} &&
            defined $kid->{class} &&
            $kid->{class} eq "mandatory")
        {
            $local_mandatory = 1;
            $mandstr = "(mandatory)";
            print STDERR "Found mandatory\n" if($ctx->{debug} >= 3);
        }
        elsif(!$local_mandatory &&
              !exists $kid->{class})
        {
            $mandstr = "(optional)";
        }
  
        if (ref($kid) ne "SR::privacy" &&
            @{$kid->{Kids}} == 0 &&
            defined $kid->{description} &&
            defined $kid->{id})
        {
            if ( ($ctx->{nooptional} && $local_mandatory) || !$ctx->{nooptional})
            {
                if(! exists $kid->{command})
                {
                    print STDERR "Add instruction\n" if($ctx->{debug} >= 3);
                    
                    my $txt = $indent."* ".$kid->{description}." $mandstr";
                    $ctx->{args}->{$kid->{id}} = { flag => "m", 
                                                   value => undef, 
                                                   kind => ($local_mandatory)?"mandatory":"optional"};
                    
                    if(!$ctx->{yastcall})
                    {
                        $txt .= ":\t".$kid->{id}."=<value>\n";
                    }
                    else
                    {
                        $txt .= "\n";
                    }
                    push @{$ctx->{registerReadableText}}, $txt;
                    $modified  = 1;
                }
                else
                {
                    my $ret = evaluateCommand($ctx, $kid->{command}, $local_mandatory);
                    if($ctx->{errorcode} != 0)
                    {
                        return $modified;
                    }
                    if (defined $ret)
                    {
                        $ctx->{args}->{$kid->{id}} = { flag  => "a", 
                                                       value => $ret,
                                                       kind  => ($local_mandatory)?"mandatory":"optional"
                                                     };
                        $modified = 1;
                    }
                }
            }
        }
        elsif (ref($kid) ne "SR::privacy" && defined $kid->{description})
        {
            if ( ($ctx->{nooptional} && $local_mandatory) || !$ctx->{nooptional})
            {
                print STDERR "Add description\n" if($ctx->{debug} >= 3);
                push @{$ctx->{registerReadableText}}, $indent.$kid->{description}." $mandstr with:\n";
            }
        }

        if ( exists $kid->{Kids} && @{$kid->{Kids}} > 0 )
        {
            $modified = evalNeedinfo($ctx, $kid->{Kids}, $nextLogic, $indent, $local_mandatory, $modified);
            $nextLogic = $logic;
            if (defined $ctx->{registerReadableText}->[$#{$ctx->{registerReadableText}}] &&
                $ctx->{registerReadableText}->[$#{$ctx->{registerReadableText}}] =~ /^\s*AND|OR\s*$/i)
            {
                if ($logic =~ /^\s*$/)
                {
                    pop @{$ctx->{registerReadableText}};
                }
                else
                {
                    $ctx->{registerReadableText}->[$#{$ctx->{registerReadableText}}] = $indent."$logic\n";
                }
            }
            else
            {
                push @{$ctx->{registerReadableText}}, $indent."$logic\n";
            }
        }
    }

    print STDERR indent($ctx)."END: evalNeedinfo:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return $modified;
}



sub buildXML
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: buildXML\n" if($ctx->{time});
    
    my $output = '<?xml version="1.0" encoding="utf-8"?>';
    
    my $writer = new XML::Writer(OUTPUT => \$output);

    my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
             "client_version" => "$SRversion");
    
    if(!$ctx->{nooptional})
    {
        $a{accept} = "optional";
    }
    if($ctx->{acceptmand} || $ctx->{nooptional}) 
    {
        $a{accept} = "mandatory";
    }
    if($ctx->{forcereg}) 
    {
        $a{force} = "registration";
    }
    if($ctx->{batch}) 
    {
        $a{force} = "batch";
    }
    
    $writer->startTag("register", %a);
    
    $writer->startTag("guid");
    $writer->characters($ctx->{guid});
    $writer->endTag("guid");

    if(defined $ctx->{hostGUID} && $ctx->{hostGUID} ne "") 
    {
        $writer->startTag("host");
        $writer->characters($ctx->{hostGUID});
        $writer->endTag("host");
    }
    else
    {
        $writer->emptyTag("host");
    }
    
    foreach my $PArray (@{$ctx->{products}})
    {
        if(defined $PArray->[0] && $PArray->[0] ne "" &&
           defined $PArray->[1] && $PArray->[1] ne "")
        {
            $writer->startTag("product",
                              "version" => $PArray->[1],
                              "release" => $PArray->[2],
                              "arch"    => $PArray->[3]);
            if ($PArray->[0] =~ /\s+/)
            {
                $writer->cdata($PArray->[0]);
            }
            else
            {
                $writer->characters($PArray->[0]);
            }
            $writer->endTag("product");
        }
    }
    
    foreach my $key (keys %{$ctx->{args}})
    {
        next if(!defined $ctx->{args}->{$key}->{value});

        if($ctx->{args}->{$key}->{value} eq "")
        {
            $writer->emptyTag("param", "id" => $key);
        }
        else
        {
            $writer->startTag("param",
                              "id" => $key);
            if ($ctx->{args}->{$key}->{value} =~ /\s+/)
            {
                $writer->cdata($ctx->{args}->{$key}->{value});
            }
            else
            {
                $writer->characters($ctx->{args}->{$key}->{value});
            }
            $writer->endTag("param");
        }
    }

    # request up-to 5 mirrors in <zmdconfig> to 
    $writer->emptyTag("mirrors", "count" => $ctx->{mirrorCount});

    $writer->endTag("register");

    print STDERR "XML:\n$output\n" if($ctx->{debug} >= 3);

    print STDERR indent($ctx)."END: buildXML:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return $output;
}


sub sendData
{
    my $ctx = shift;
    my $url  = shift || undef;
    my $data = shift || undef;
    
    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: sendData\n" if($ctx->{time});
    
    my $curlErr = 0;
    my $res = "";
    my $err = "";
    my %header = ();
    my $code = "";
    my $mess = "";
    
    if (! defined $url)
    {
        logPrintError($ctx, "Cannot send data to registration server. Missing URL.\n", 14);
        return;
    }
    if($url =~ /^-/)
    {
        logPrintError($ctx, "Invalid protocol($url).\n", 15);
        return;
    }

    my $uri = URI->new($url);
    
    if(!defined $uri->host || $uri->host !~ /$ctx->{initialDomain}$/)
    {
        logPrintError($ctx, "Invalid URL($url). Data could only be send to $ctx->{initialDomain} .\n", 15);
        return;
    }
    if(!defined $uri->scheme || $uri->scheme ne "https")
    {
        logPrintError($ctx, "Invalid protocol($url). https is required.\n", 15);
        return;
    }
    $url = $uri->as_string;
        
    if (! defined $data)
    {
        logPrintError($ctx, "Cannot send data. Missing data.\n", 14);
        return;
    }

    my @cmdArgs = ( "--capath", $ctx->{CA_PATH});

    my $fh = new File::Temp(TEMPLATE => 'dataXXXXX',
                            SUFFIX   => '.xml',
                            DIR      => '/tmp/');
    print $fh $data;

    push @cmdArgs, "--data", "@".$fh->filename();
    push @cmdArgs, "-i";
    push @cmdArgs, "--max-time", "60";

    foreach my $extraOpt (@{$ctx->{extraCurlOption}})
    {
        if($extraOpt =~ /^([\w-]+)[\s=]*(.*)/)
        {
            if(defined $1 && $1 ne "")
            {
                push @cmdArgs, $1;
                
                if(defined $2 && $2 ne "")
                {
                    push @cmdArgs, $2;
                }
            }
        }
    }
    
    push @cmdArgs, "$url";

    print STDERR "Call $ctx->{curl} ".join(" ", @cmdArgs)."\n" if($ctx->{debug} >= 2);
    print STDERR "SEND DATA to URI: $url:\n" if($ctx->{debug} >= 2);
    print STDERR "$data\n"  if($ctx->{debug} >= 2);

    print {$ctx->{LOGDESCR}} "\nSEND DATA to URI: $url:\n" if(defined $ctx->{LOGDESCR});
    print {$ctx->{LOGDESCR}} "$data\n"  if(defined $ctx->{LOGDESCR});

    if($ctx->{noproxy})
    {
        delete $ENV{'http_proxy'};
        delete $ENV{'HTTP_PROXY'};
        delete $ENV{'https_proxy'};
        delete $ENV{'HTTPS_PROXY'};
        delete $ENV{'ALL_PROXY'};
        delete $ENV{'all_proxy'};
    }
    $ENV{'PATH'} = '/bin:/usr/bin:/sbin:/usr/sbin:/opt/kde3/bin/:/opt/gnome/bin/';

    my $pid = open3(\*IN, \*OUT, \*ERR, $ctx->{curl}, @cmdArgs) or do {
        logPrintError($ctx, "Cannot execute $ctx->{curl} ".join(" ", @cmdArgs).": $!\n",13);
        return;
    };

    my $foundBody = 0;
    while (<OUT>)
    {
        $res = "" if(! defined $res);
        if ($foundBody)
        {
            $res .= "$_";
        }
        elsif ($_ =~ /^HTTP\/\d\.\d\s(\d+)\s(.*)$/)
        {
            if (defined $1 && $1 ne "")
            {
                $code = $1;
            }
            if (defined $2 && $2 ne "")
            {
                $mess = $2;
            }
        }
        elsif ($_ =~ /^[\w-]+:\s/)
        {
            my ($key, $val) = split(": ", $_, 2);
            $header{$key} = $val;
        }
        elsif ($_ =~ /^\s*</)
        {
            $foundBody = 1;
            $res .= "$_";
        }
    }
    while (<ERR>)
    {
        $err .= "$_";
    }
    close OUT;
    close ERR;
    close IN;
    waitpid $pid, 0;

    $curlErr = ($?>>8);

    print STDERR "CURL RETURN WITH: $curlErr\n" if($ctx->{debug} >= 2);
    print STDERR "\nRECEIVED DATA:\n" if($ctx->{debug} >= 2);
    print STDERR "CODE: $code MESSAGE:  $mess\n" if($ctx->{debug} >= 2);
    print STDERR "HEADER: ".Data::Dumper->Dump([\%header])."\n" if($ctx->{debug} >= 2);
    print STDERR "BODY:  $res\n" if($ctx->{debug} >= 2);
    
    print {$ctx->{LOGDESCR}} "\nRECEIVED DATA:\n" if(defined $ctx->{LOGDESCR});
    print {$ctx->{LOGDESCR}} "CURL RETURN WITH: $curlErr\n" if(defined $ctx->{LOGDESCR});
    print {$ctx->{LOGDESCR}} "CODE: $code MESSAGE:  $mess\n" if(defined $ctx->{LOGDESCR});
    print {$ctx->{LOGDESCR}} "HEADER: ".Data::Dumper->Dump([\%header])."\n" if(defined $ctx->{LOGDESCR});
    print {$ctx->{LOGDESCR}} "BODY:  $res\n" if(defined $ctx->{LOGDESCR});

    if ($curlErr != 0)
    {
        logPrintError($ctx, "Execute curl command failed with '$curlErr': $err", 4);
        return $res;
    }

    if ($code >= 300 && exists $header{Location} && defined $header{Location})
    {
        if ($ctx->{redirects} > 5)
        {
            logPrintError($ctx, "Too many redirects. Aborting.\n", 5);
            return $res;
        }
        $ctx->{redirects}++;
        
        my $loc = $header{Location};

        local $/ = "\r\n";
        chomp($loc);
        local $/ = "\n";

        #print STDERR "sendData(redirect): ".(tv_interval($t0))."\n" if($ctx->{time});

        $res = sendData($ctx, $loc, $data);
    }
    elsif($code < 200 || $code >= 300) 
    {
        my $b = "";
        my @c = ();

        if(-e "/usr/bin/lynx")
        {
            $b = "/usr/bin/lynx";
            push @c, "-dump", "-stdin";
        }
        elsif(-e "/usr/bin/w3m") 
        {
            $b = "/usr/bin/w3m";
            push @c, "-dump", "-T", "text/html";
        }
        
        my $out = "";

        my $pid = open3(\*IN, \*OUT, \*ERR, $b, @c) or do
        {
            logPrintError($ctx, "Cannot execute $b ".join(" ", @c).": $!\n",13);
            return undef;
        };
        
        print IN $res;
        close IN;
        
        while (<OUT>)
        {
            $out .= "$_";
        }
        #chomp($msg) if(defined $msg && $msg ne "");
        while (<ERR>)
        {
            $out .= "$_";
        }
        close OUT;
        close ERR;
        waitpid $pid, 0;
        chomp($out) if(defined $out && $out ne "");
        
        $out .= "\n$mess\n";
        
        logPrintError($ctx, "ERROR: $code: $out\n", 2);
    }
    #else
    #{
        print STDERR indent($ctx)."END: sendData:".(tv_interval($t0))."\n" if($ctx->{time});
        $ctx->{timeindent}--;
    #}
    
    return $res;
}


sub getPatterns
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: getPatterns\n" if($ctx->{time});

    my $code = 0;
    my $msg = "";
    
    if(!defined $ctx->{querypool})
    {
        # SLES9 ?
        return (0, "");
    }
    

    print STDERR "query pool command: $ctx->{querypool} patterns \@system \n" if($ctx->{debug} >= 1);
    
    my $result = `$ctx->{querypool} patterns \@system`;
    $code = ($?>>8);

    if($code != 0) 
    {
        $code += 30;
        $msg = "Query patterns failed. $result\n";
        #syslog("err", "Query patterns failed($code): $result");
    }
    else 
    {
        foreach my $line (split("\n", $result))
        {
            next if($line =~ /^\s*$/);
            
            my @p = split('\|', $line);
            
            if(defined $p[0] && $p[0] eq "i" && 
               defined $p[2] && $p[2] ne "")
            {
                push @{$ctx->{installedPatterns}}, $p[2];
            }
        }
    }
    
    print STDERR "Query patterns failed($code): $result\n" if($ctx->{debug} && $code != 0);
    
    print STDERR "installed patterns:           ".Data::Dumper->Dump([$ctx->{installedPatterns}])."\n" if($ctx->{debug});
    
    print STDERR indent($ctx)."END: getPatterns:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return logPrintReturn($ctx, $msg, $code);
}

sub getProducts
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: getProducts\n" if($ctx->{time});

    my $code = 0;
    my $msg = "";
    my $result = "";
    
    if(defined $ctx->{querypool})
    {
        print STDERR "query pool command: $ctx->{querypool} products \@system \n" if($ctx->{debug} >= 1);
        
        $result = `$ctx->{querypool} products \@system`;
        $code = ($?>>8);
        
        if($code != 0) 
        {
            $code += 30;
            $msg = "Query products failed. $result\n";
            #syslog("err", "Query products failed($code): $result");
        }
        else 
        {
            foreach my $line (split("\n", $result))
            {
                next if($line =~ /^\s*$/);
                
                my @p = split('\|', $line);
                my $installed   = $p[0];
                my $type        = $p[1];
                my $product     = $p[2];
                my $version     = $p[3];
                my $arch        = $p[4];
                my $distproduct = "";
                my $distversion = "";
                my $distrelease = "";
                
                if(defined $p[5] && $p[5] ne "")
                {
                    $distproduct = $p[5];
                }
                else
                {
                    $distproduct = $product;
                }
                if(defined $p[6] && $p[6] ne "")
                {
                    $distversion = $p[6];
                }
                else
                {
                    $distversion = $version;
                }
                
                if(!defined $arch || $arch eq "" || $arch eq "noarch")
                {
                    $arch = `$ctx->{uname} -i`;
                    chomp($arch);
                }
                
                if(defined $distversion && $distversion ne "")
                {
                    my @v = split("-", $distversion, 2);
                    if(exists $v[0] && defined $v[0] && $v[0] ne "")
                    {
                        $distversion = $v[0];
                    }
                    if(exists $v[1] && defined $v[1] && $v[1] ne "")
                    {
                        $distrelease = $v[1];
                    }
                }
                
                if($installed eq "i" && lc($type) eq lc("product"))
                {
                    push @{$ctx->{installedProducts}}, [$distproduct, $distversion, $distrelease, $arch];
                }
            }
        }
    }
    elsif( -e $ctx->{suserelease})
    {
        # SLES9

        my $product = `$ctx->{suserelease} --distproduct -s`;
        $code = ($?>>8);
        if($code != 0) 
        {
            $code += 40;
            $msg = "Query products failed. \n";
            #syslog("err", "Query products failed($code): $result");
        }

        my $version = `$ctx->{suserelease} --distversion -s`;
        $code = ($?>>8);
        if($code != 0) 
        {
            $code += 40;
            $msg = "Query products failed. \n";
            #syslog("err", "Query products failed($code): $result");
        }

        my $arch = `$ctx->{uname} -m`;
        $code = ($?>>8);
        if($code != 0) 
        {
            $code += 40;
            $msg = "Query products failed. \n";
            #syslog("err", "Query products failed($code): $result");
        }
        chomp($product);
        chomp($version);
        chomp($arch);       
        
        push @{$ctx->{installedProducts}}, [$product, $version, "", $arch];
    }
    
    print STDERR "Query products failed($code): $result\n" if($ctx->{debug} && $code != 0);
    
    print STDERR "installed products:           ".Data::Dumper->Dump([$ctx->{installedProducts}])."\n" if($ctx->{debug});
    syslog("info", "Installed Products Dump: ".Data::Dumper->Dump([$ctx->{installedProducts}]));


    print STDERR indent($ctx)."END: getProducts:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return logPrintReturn($ctx, $msg, $code);
}



sub logPrintReturn
{
    my $ctx = shift;
    my $message = shift || "";
    my $code    = shift || 0;

    if($code != 0)
    {
        syslog("err", "$message($code)");
        print STDERR "$message($code)\n" if($ctx->{debug});
    }
    
    # cleanup errors in the context
    $ctx->{errorcode} = 0;
    $ctx->{errormsg} = "";

    return ($code, $message);
}


sub logPrintError
{
    my $ctx = shift;
    my $message = shift || undef;
    my $code    = shift || 0;

    if($code != 0) 
    {
        
        if(exists $ctx->{args}->{password})
        {
            $ctx->{args}->{password}->{value} = "secret";
        }
        if(exists $ctx->{args}->{passwd})
        {
            $ctx->{args}->{passwd}->{value} = "secret";
        }
        if(exists $ctx->{args}->{secret})
        {
            $ctx->{args}->{secret}->{value} = "secret";
        }
        my $cmdtxt = "Commandline params: no-optional:$ctx->{nooptional}  forceregistration:$ctx->{forcereg}  ";
        $cmdtxt .= "no-hw-data:$ctx->{nohwdata} batch:$ctx->{batch} ";
        
        syslog("err", $cmdtxt);
        syslog("err", "Argument Dump: ".Data::Dumper->Dump([$ctx->{args}]));
        syslog("err", "Products Dump: ".Data::Dumper->Dump([$ctx->{products}]));
        syslog("err", "$message($code)");
    }
    
    $ctx->{errorcode} = $code;
    $ctx->{errormsg} = $message;
    
    return;
}

sub listProducts
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: listProducts\n" if($ctx->{time});
    
    my $output = "\n";
    
    my $writer = new XML::Writer(OUTPUT => \$output);

    $ctx->{redirects} = 0;

    my $res = sendData($ctx, $ctx->{URL}."?".$ctx->{URLlistProducts}."&lang=en-US&version=$ctx->{version}", $output);
    if($ctx->{errorcode} != 0)
    {
        return logPrintReturn($ctx, $ctx->{errormsg}, $ctx->{errorcode});
    }
    
    my $p = new XML::Parser(Style => 'Objects', Pkg => 'SR');
    my $tree = $p->parse($res);
    
    #print Data::Dumper->Dump([$tree])."\n";
    
    if (! defined $tree || ref($tree->[0]) ne "SR::productlist")
    {
        return logPrintReturn($ctx, "Unknown XML format. Cannot show human readable output. Try --xml-output.\n",
                              6);
    }
    
    foreach my $kid (@{$tree->[0]->{Kids}})
    {
        #print Data::Dumper->Dump([$kid])."\n";
        
        if (ref($kid) eq "SR::product" &&
            exists  $kid->{Kids} &&
            exists  $kid->{Kids}->[0] &&
            ref($kid->{Kids}->[0]) eq "SR::Characters" &&
            exists  $kid->{Kids}->[0]->{Text} &&
            defined $kid->{Kids}->[0]->{Text} &&
            $kid->{Kids}->[0]->{Text} ne "")
        {
                #print "SEE:".Data::Dumper->Dump([$tree->[1]->[$i]])."\n\n";
            
            push @{$ctx->{serverKnownProducts}}, [$kid->{Kids}->[0]->{Text}, "0"];
        }
    }

    print STDERR "Server Known Products:".Data::Dumper->Dump([$ctx->{serverKnownProducts}])."\n" if($ctx->{debug} >= 2);

    print STDERR indent($ctx)."END: listProducts:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return (0, "");
}

sub intersection
{
    my $ctx = shift;
    my $arr1 = shift || undef;
    my $arr2 = shift || undef;
    my $ret = [];
    
    if(!defined $arr1 || !defined $arr2 || 
       ref($arr1->[0]) ne "ARRAY" || ref($arr2->[0]) ne "ARRAY")
    {
        return [];
    }

    print STDERR "intersect1: ".Data::Dumper->Dump([$arr1])."\n" if($ctx->{debug} >= 3);
    print STDERR "intersect2: ".Data::Dumper->Dump([$arr2])."\n" if($ctx->{debug} >= 3);
    
    foreach my $v1 (@$arr1)
    {
        foreach my $v2 (@$arr2) 
        {
            if(lc($v1->[0]) eq lc($v2->[0]))
            {
                if($v2->[1] ne "0")
                {
                    push @$ret, $v2;
                }
                else
                {
                    push @$ret, $v1;
                }
                last;
            }
        }
    }
    
    print STDERR "intersect return : ".Data::Dumper->Dump([$ret])."\n" if($ctx->{debug} >= 3);
    return $ret;
}

sub rugOSTarget
{
    my $ctx = shift;
    my $msg = "";
    my $code = 1;

    return (0, "SUSE Linux Enterprise Server 10 (i586)");
}

sub indent
{
    my $ctx = shift;
    my $ind = "";
    for(my $i = 0;
        $i < $ctx->{timeindent};
        $i++)
    {
        $ind .= " ";
    }
    return $ind;
}

sub stripURL
{
    my $ctx = shift;
    my $url = shift || "";

    if($url eq "")
    {
        return "";
    }
    
    my $uri = URI->new($url);

    if($uri->scheme eq "http"  ||
       $uri->scheme eq "https" )
    {
        # delete user/password from url
        $uri->userinfo(undef);
    }
    
    # delete all query parameter from the url
    $uri->query(undef);
    
    return $uri->as_string;
}

sub fillURL
{
    my $ctx         = shift;
    my $url         = shift || "";
    my $queryparams = shift || undef;
    
    if($url eq "")
    {
        return "";
    }
    
    my $secret = "";
    open(SEC, "< $ctx->{SECRET_FILE}") or do {
        logPrintReturn("Cannot open file $ctx->{SECRET_FILE}: $!\n", 12);
        return "";
    };
    while(<SEC>)
    {
        $secret .= $_;
    }
    close SEC;
    
    my $uri = URI->new($url);

    if($uri->scheme eq "http"  ||
       $uri->scheme eq "https" )
    {
        # add user/password to url
        $uri->userinfo($ctx->{guid}.":$secret");
    }

    if(! defined $queryparams || $queryparams eq "")
    {
	# delete the query paramter
        $uri->query(undef);
    }
    else
    {
	# add query parameter
        $uri->query_form($queryparams);
    }
   
    return $uri->as_string;
}

###############################################################################

sub init_ctx
{
    my $data = shift;
    my $ctx = {};
    my $code = 0;
    my $msg = "";

    $ctx->{errorcode} = 0;
    $ctx->{errormsg} = "";
    $ctx->{time} = 0;
    $ctx->{timeindent} = 0;
    if(exists $data->{time} && defined $data->{time})
    {
        $ctx->{time} = $data->{time};
    }
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR Register::indent($ctx)."START: init_ctx\n" if($ctx->{time});



    $ctx->{version} = "1.0";

    $ctx->{configFile}      = "/etc/suseRegister.conf";
    $ctx->{sysconfigFile}   = "/etc/sysconfig/suse_register";

    $ctx->{GUID_FILE}       = "/etc/zmd/deviceid";
    $ctx->{SECRET_FILE}     = "/etc/zmd/secret";
    $ctx->{SYSCONFIG_CLOCK} = "/etc/sysconfig/clock";
    $ctx->{CA_PATH}         = "/etc/ssl/certs";

    $ctx->{URL}             = "https://secure-www.novell.com/center/regsvc/";

    $ctx->{URLlistParams}   = "command=listparams";
    $ctx->{URLregister}     = "command=register";
    $ctx->{URLlistProducts} = "command=listproducts";

    $ctx->{guid}      = undef;
    $ctx->{locale}    = undef;
    $ctx->{encoding}  = "utf-8";
    $ctx->{lang}      = "en-US";

    $ctx->{listParams}      = 0;
    $ctx->{xmlout}          = 0;  
    $ctx->{nozypp}          = 0;
    $ctx->{norug}           = 0;
    $ctx->{nozypper}        = 0;
    $ctx->{dumpfilehack}    = ""; # FIXME: is this nedded ?
    $ctx->{dumpxmlfilehack} = ""; # FIXME: is this nedded ?
    $ctx->{nooptional}  = 0;
    $ctx->{acceptmand}  = 0;
    $ctx->{forcereg}    = 0;
    $ctx->{nohwdata}    = 0;
    $ctx->{batch}       = 0;
    $ctx->{interactive} = 0;
    $ctx->{logfile}     = undef;
    $ctx->{noproxy}     = 0;
    $ctx->{debug}       = 0;
    $ctx->{yastcall}    = 0; # FIXME: is this still needed?
    $ctx->{LOGDESCR}    = undef;
    $ctx->{args}      = {
                         processor => { flag => "i", value => undef, kind => "mandatory" },
                         platform  => { flag => "i", value => undef, kind => "mandatory" },
                         timezone  => { flag => "i", value => undef, kind => "mandatory" },
                        };
    $ctx->{comlineProducts}     = [];
    $ctx->{serverKnownProducts} = [];
    $ctx->{installedProducts}   = [];
    $ctx->{products} = [];

    $ctx->{installedPatterns} = [];

    $ctx->{extraCurlOption} = [];

    $ctx->{hostGUID} = undef;

    $ctx->{zmdConfig} = {};
    $ctx->{ostarget} = "";

    $ctx->{redirects} = 0;
    $ctx->{registerManuallyURL} = "";
    $ctx->{registerReadableText} = [];
    $ctx->{registerPrivPol} = "";

    $ctx->{querypool}     = "/usr/lib/zypp/zypp-query-pool";
    $ctx->{suserelease}   = "/usr/lib/suseRegister/bin/suse_release";
    $ctx->{rug}           = "/usr/bin/rug";
    $ctx->{zypper}        = "/usr/bin/zypper";
    $ctx->{lsb_release}   = "/usr/bin/lsb_release";
    $ctx->{uname}         = "/bin/uname";
    $ctx->{hwinfo}        = "/usr/sbin/hwinfo";
    $ctx->{zmdInit}       = "/etc/init.d/novell-zmd";
    $ctx->{curl}          = "/usr/bin/curl";

    $ctx->{xenstoreread}  = "/usr/bin/xenstore-read";
    $ctx->{xenstorewrite} = "/usr/bin/xenstore-write";
    $ctx->{xenstorechmod} = "/usr/bin/xenstore-chmod";

    $ctx->{createGuid}    = "/usr/bin/uuidgen";

    $ctx->{lastResponse}    = "";
    $ctx->{initialDomain}   = "";

    $ctx->{rugzmdInstalled} = 0;
    $ctx->{zypperInstalled} = 0;
    
    $ctx->{addRegSrvSrc} = 1;
    $ctx->{addAdSrc} = [];

    $ctx->{mirrorCount} = 1;
    $ctx->{zmdcache} = "/var/cache/SuseRegister/lastzmdconfig.cache";
    $ctx->{ignoreCache} = 0;
    

    if(exists $data->{products} && ref($data->{products}) eq "ARRAY")
    {
        $ctx->{comlineProducts} = $data->{products};
    }
    
    if(exists $data->{xmlout} && defined $data->{xmlout})
    {
        $ctx->{xmlout} = $data->{xmlout};
    }

    if(exists $data->{nozypp} && defined $data->{nozypp})
    {
        $ctx->{nozypp} = $data->{nozypp};
    }

    if(exists $data->{norug} && defined $data->{norug})
    {
        $ctx->{norug} = $data->{norug};
    }

    if(exists $data->{nozypper} && defined $data->{nozypper})
    {
        $ctx->{nozypper} = $data->{nozypper};
    }

    if(exists $data->{dumpfilehack} && defined $data->{dumpfilehack})
    {
        $ctx->{dumpfilehack} = $data->{dumpfilehack};
    }

    if(exists $data->{dumpxmlfilehack} && defined $data->{dumpxmlfilehack})
    {
        $ctx->{dumpxmlfilehack} = $data->{dumpxmlfilehack};
    }

    if(exists $data->{nooptional} && defined $data->{nooptional})
    {
        $ctx->{nooptional} = $data->{nooptional};
    }

    if(exists $data->{forcereg} && defined $data->{forcereg})
    {
        $ctx->{forcereg} = $data->{forcereg};
    }

    if(exists $data->{nohwdata} && defined $data->{nohwdata})
    {
        $ctx->{nohwdata} = $data->{nohwdata};
    }

    if(exists $data->{batch} && defined $data->{batch})
    {
        $ctx->{batch} = $data->{batch};
    }

    if(exists $data->{interactive} && defined $data->{interactive})
    {
        $ctx->{interactive} = $data->{interactive};
    }

    if(exists $data->{logfile} && defined $data->{logfile})
    {
        $ctx->{logfile} = $data->{logfile};
    }

    if(exists $data->{locale} && defined $data->{locale})
    {
        $ctx->{locale} = $data->{locale};
    }

    if(exists $data->{noproxy} && defined $data->{noproxy})
    {
        $ctx->{noproxy} = $data->{noproxy};
    }

    if(exists $data->{yastcall} && defined $data->{yastcall})
    {
        $ctx->{yastcall} = $data->{yastcall};
    }

    if(exists $data->{mirrorCount} && defined $data->{mirrorCount})
    {
        $ctx->{mirrorCount} = $data->{mirrorCount};
    }

    if(exists $data->{debug} && defined $data->{debug})
    {
        $ctx->{debug} = $data->{debug};
    }

    if(exists $data->{args} && ref($data->{args}) eq "HASH")
    {
        foreach my $a (keys %{$data->{args}})
        {
            $ctx->{args}->{$a} = {flag => "i", value => $data->{args}->{$a}, kind => "mandatory"};
        }
    }

    if(exists $data->{extraCurlOption} && ref($data->{extraCurlOption}) eq "ARRAY")
    {
        $ctx->{extraCurlOption} = $data->{extraCurlOption};
    }

    openlog("suse_register", "ndelay,pid", 'user');

    if(-e $ctx->{zmdInit} && -e $ctx->{rug}) 
    {
        $ctx->{rugzmdInstalled} = 1;
    }
    
    if(-e $ctx->{zypper}) 
    {
        $ctx->{zypperInstalled} = 1;
    }

    # check and fix mirrorCount
    
    if(!defined $ctx->{mirrorCount} || $ctx->{mirrorCount} < 1)
    {
        $ctx->{mirrorCount} = 1;
    }

    if(exists $data->{ignoreCache} && defined $data->{ignoreCache})
    {
        $ctx->{ignoreCache} = $data->{ignoreCache};
    }

    if(exists $ENV{LANG} && $ENV{LANG} =~ /^([\w_]+)\.?/) 
    {
        if(defined $1 && $1 ne "") 
        {
            $ctx->{lang} = $1;
            $ctx->{lang} =~ s/_/-/;
        }
    }
    elsif(exists $ENV{LANGUAGE} && $ENV{LANGUAGE} =~ /^([\w_]+)\.?/) 
    {
        if(defined $1 && $1 ne "") 
        {
            $ctx->{lang} = $1;
            $ctx->{lang} =~ s/_/-/;
        }
    }

    if (defined $ctx->{locale})
    {
        my ($l, $e) = split(/\.|@/, $ctx->{locale}, 2);
        
        if (defined $l && $l ne "")
        {
            $l =~ s/_/-/;
            $ctx->{lang} = $l;
        }
        
        if (defined $e && $e ne "") 
        {        
            $ctx->{encoding} = $e;
        }
    }
    
    # set LANG to en_US to get the error messages in english
    $ENV{LANG}     = "en_US";
    $ENV{LANGUAGE} = "en_US";
    
        
    if(! -e $ctx->{querypool})
    {
        # Code10 compat
        $ctx->{querypool} = "/usr/lib/zmd/query-pool";

        # lib64 hack
        if(! -e $ctx->{querypool}) 
        {
            $ctx->{querypool} = "/usr/lib64/zmd/query-pool";
        
            if(!-e $ctx->{querypool})
            {
                # SLES9 ? try to find suse_release
                if(-e $ctx->{suserelease})
                {
                    $ctx->{querypool} = undef;
                }
                else
                {
                    Register::logPrintError($ctx, "query-pool command not found.\n", 12);
                    return $ctx;
                }
            }
        }
    }
    
    # check for xen tools
    if(! -e $ctx->{xenstoreread} &&
       -e "/bin/xenstore-read")
    {
        $ctx->{xenstoreread} = "/bin/xenstore-read";
    }
    if(! -e $ctx->{xenstorewrite} &&
       -e "/bin/xenstore-write" )
    {
        $ctx->{xenstorewrite} = "/bin/xenstore-write";
    }
    if(! -e $ctx->{xenstorechmod} &&
       -e "/bin/xenstore-chmod" )
    {
        $ctx->{xenstorechmod} = "/bin/xenstore-chmod";
    }
    

    if (defined $ctx->{logfile} && $ctx->{logfile} ne "")
    {
        open($ctx->{LOGDESCR}, ">> ".$ctx->{logfile}) or do 
        {
            if(!$ctx->{yastcall})
            {
                Register::logPrintError($ctx, "Cannot open logfile <$ctx->{logfile}>: $!\n", 12);
                return $ctx;
            }
            else
            {
                syslog("err", "Cannot open logfile <$ctx->{logfile}>: $!(yastcall ignoring error)");
                $ctx->{LOGDESCR} = undef;
            }
        };
        # $LOGDESCR is undef if no logfile is defined
        if(defined $ctx->{LOGDESCR})
        {
            print {$ctx->{LOGDESCR}} "----- ".localtime()." ---------------------------------------\n";
        }
    }

    #$ENV{'PATH'} = '/bin:/usr/bin:/sbin:/usr/sbin:/opt/kde3/bin:/opt/gnome/bin';

    my @x = ();
    foreach my $p (@{$ctx->{comlineProducts}})
    {
        push @x, [$p, "0"];
    }
    $ctx->{comlineProducts} = \@x;

    ($code, $msg) = Register::readSystemValues($ctx);
    if($code != 0)
    {
        Register::logPrintError($ctx, $msg, $code);
        return $ctx;
    }


    print STDERR "list-parameters:   $ctx->{listParams}\n" if($ctx->{debug});
    print STDERR "product:           ".Data::Dumper->Dump([$ctx->{comlineProducts}])."\n" if($ctx->{debug});
    print STDERR "xml-output:        $ctx->{xmlout}\n" if($ctx->{debug});
    print STDERR "dumpfile:          $ctx->{dumpfilehack}\n" if($ctx->{debug});
    print STDERR "dumpxmlfile:       $ctx->{dumpxmlfilehack}\n" if($ctx->{debug});
    print STDERR "no-optional:       $ctx->{nooptional}\n" if($ctx->{debug});
    print STDERR "batch:             $ctx->{batch}\n" if($ctx->{debug});
    print STDERR "forcereg:          $ctx->{forcereg}\n" if($ctx->{debug});
    print STDERR "no-hw-data:        $ctx->{nohwdata}\n" if($ctx->{debug});
    print STDERR "norug:             $ctx->{norug}\n" if($ctx->{debug});
    print STDERR "nozypper:          $ctx->{nozypper}\n" if($ctx->{debug});
    print STDERR "log:               ".(($ctx->{logfile})?$ctx->{logfile}:"undef")."\n" if($ctx->{debug});
    print STDERR "locale:            ".(($ctx->{locale})?$ctx->{locale}:"undef")."\n" if($ctx->{debug});
    print STDERR "no-proxy:          $ctx->{noproxy}\n" if($ctx->{debug});
    print STDERR "yastcall:          $ctx->{yastcall}\n" if($ctx->{debug});
    print STDERR "mirrorCount:       $ctx->{mirrorCount}\n" if($ctx->{debug});
    print STDERR "arg: ".Data::Dumper->Dump([$ctx->{args}])."\n" if($ctx->{debug});
    print STDERR "extra-curl-option:".Data::Dumper->Dump([$ctx->{extraCurlOption}])."\n" if($ctx->{debug});
    
    print STDERR "URL:               $ctx->{URL}\n" if($ctx->{debug});
    print STDERR "listParams:        $ctx->{URLlistParams}\n" if($ctx->{debug});
    print STDERR "register:          $ctx->{URLregister}\n" if($ctx->{debug});
    print STDERR "lang:              $ctx->{lang}\n" if($ctx->{debug});
    
    
    my $iuri = URI->new($ctx->{URL});

    $ctx->{initialDomain} = $iuri->host;
    $ctx->{initialDomain} =~ s/.+(\.[^.]+\.[^.]+)$/$1/;

    print STDERR "initialDomain:     $ctx->{initialDomain}\n" if($ctx->{debug});

    ($code, $msg) = Register::listProducts($ctx);
    if($code != 0)
    {
        Register::logPrintError($ctx, $msg, $code);
        return $ctx;
    }
    
    if(@{$ctx->{comlineProducts}} > 0)
    {
        $ctx->{products} = Register::intersection($ctx, $ctx->{comlineProducts}, $ctx->{installedProducts});
        $ctx->{products} = Register::intersection($ctx, $ctx->{products}, $ctx->{serverKnownProducts});
    }
    else
    {
        $ctx->{products} = Register::intersection($ctx, $ctx->{installedProducts}, $ctx->{serverKnownProducts});
    }

    if($#{$ctx->{installedProducts}} == 0 && 
       exists $ctx->{installedProducts}->[0]->[0] &&
       $ctx->{installedProducts}->[0]->[0] =~ /FACTORY/i)
    {
        Register::logPrintError($ctx, "FACTORY cannot be registered\n", 101);
        return $ctx;
    }

    if(@{$ctx->{products}} == 0)
    {
        Register::logPrintError($ctx, "None of the installed products can be registered at the Novell registration server.\n", 100);
        return $ctx;
    }

    print STDERR Register::indent($ctx)."END: init_ctx:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return $ctx;
}

sub listParams
{
    my $ctx = shift;
    my $text = "";

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR Register::indent($ctx)."START: listParams\n" if($ctx->{time});

    # cleanup the error status
    $ctx->{errorcode} = 0;
    $ctx->{errormsg} = "";

    my $output = '<?xml version="1.0" encoding="utf-8"?>';
    
    my $writer = new XML::Writer(OUTPUT => \$output);

    $writer->startTag("listparams", "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                                    "client_version" => "$Register::SRversion");

    foreach my $PArray (@{$ctx->{products}})
    {
        if(defined $PArray->[0] && $PArray->[0] ne "" &&
           defined $PArray->[1] && $PArray->[1] ne "")
        {
            $writer->startTag("product",
                              "version" => $PArray->[1],
                              "release" => $PArray->[2],
                              "arch"    => $PArray->[3]);
            if ($PArray->[0] =~ /\s+/)
            {
                $writer->cdata($PArray->[0]);
            }
            else
            {
                $writer->characters($PArray->[0]);
            }
            $writer->endTag("product");
        }
    }
    
    $writer->endTag("listparams");

    print STDERR "XML:\n$output\n" if($ctx->{debug} >= 3);

    $ctx->{redirects} = 0;                           
                                      # hard coded en-US; suse_register is in english
    my $res = Register::sendData($ctx, $ctx->{URL}."?".$ctx->{URLlistParams}."&lang=en-US&version=$ctx->{version}", $output);
    if($ctx->{errorcode} != 0)
    {
        return;
    }
        
    if ($ctx->{xmlout})
    {
        return "$res\n";
    }
    else
    {
        my $privpol = "";
        
        if(!$ctx->{yastcall})
        {
            $text .= "Available Options:\n\n";
            $text .= "You can add these options to suse_register with the -a option.\n";
            $text .= "'-a' can be used multiple times\n\n";
        }
        
        my $p = new XML::Parser(Style => 'Objects', Pkg => 'SR');
        my $tree = $p->parse($res);

        #print Data::Dumper->Dump([$tree])."\n";

        if (! defined $tree || ref($tree->[0]) ne "SR::paramlist" ||
            ! exists $tree->[0]->{Kids} || ref($tree->[0]->{Kids}) ne "ARRAY")
        {
            Register::logPrintError($ctx, "Invalid XML format. Cannot show human readable output. Try --xml-output.\n".
                                     6);
            return;
        }

        if($ctx->{yastcall})
        {
            $text .= "<pre>";
        }
                
        foreach my $kid (@{$tree->[0]->{Kids}})
        {
            #print Data::Dumper->Dump([$tree->[1]->[$i]])."\n\n";

            if (ref($kid) eq "SR::param")
            {
                if (exists $kid->{command} && defined $kid->{command} &&
                    $ctx->{nohwdata} && $kid->{command} =~ /^hwinfo/)
                {
                    # skip; --no-hw-data was provided 
                    next;
                }
                elsif (exists $kid->{command} && defined $kid->{command} &&
                    $ctx->{nohwdata} && $kid->{command} =~ /^installed-desktops$/)
                {
                    # skip; --no-hw-data was provided 
                    next;
                }
                
                $text .= "* ".$kid->{description}.": ";
                if(!$ctx->{yastcall})
                {
                    $text .= "\n\t".$kid->{id}."=<value> ";
                }

                if (exists $kid->{command} && defined $kid->{command} && $kid->{command} ne "")
                {
                    $text .= "(command: ".$kid->{command}.")\n";
                }
                else
                {
                    $text .= "\n";
                }
                if(!$ctx->{yastcall})
                {
                    $text .= "\n";
                }
            }
            elsif (ref($kid) eq "SR::privacy" )
            {
                if (exists $kid->{description} && defined $kid->{description})
                {
                    if(!$ctx->{yastcall}) 
                    {
                        $privpol .= "\nInformation on Novell's Privacy Policy:\n";
                        $privpol .= $kid->{description}."\n";
                    }
                    else
                    {
                        $privpol .= "<p>Information on Novell's Privacy Policy:<br>\n";
                        $privpol .= $kid->{description}."</p>\n";
                    }
                }
                
                if (exists $kid->{url} && defined $kid->{url} && $kid->{url} ne "")
                {
                    if(!$ctx->{yastcall}) 
                    {
                        $privpol .= $kid->{url}."\n";
                    }
                    else
                    {
                        $privpol .= "<p><a href=\"".$kid->{url}."\">";
                        $privpol .= $kid->{url}."</a></p>\n";
                    }
                }
            }
        }
        if(!$ctx->{yastcall})
        {
            $text .= "Example:\n";
            $text .= "  suse_register -a email=\"tux\@example.com\"\n";
        }
        else
        {
            $text .= "</pre>\n";
        }

        $text .= $privpol;
    }

    print STDERR Register::indent($ctx)."END: listParams:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;

    return "$text\n";
}

sub register
{
    my $ctx = shift;

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR Register::indent($ctx)."START: register\n" if($ctx->{time});


    my $code = 0;
    my $msg = "";
    
    # cleanup the error status
    $ctx->{errorcode} = 0;
    $ctx->{errormsg} = "";

    my $output = Register::buildXML($ctx);

    $ctx->{redirects} = 0;
    my $res = Register::sendData($ctx, $ctx->{URL}."?".$ctx->{URLregister}."&lang=en-US&version=$ctx->{version}", $output);
    if($ctx->{errorcode} != 0)
    {
        return 2;
    }

    if($res eq $ctx->{lastResponse})
    {
        # Got the same server response as the last time
        Register::logPrintError($ctx, "Invalid response from the registration server. Aborting.\n", 9);
        return 2;
    }
    $ctx->{lastResponse} = $res;

    my $p = new XML::Parser(Style => 'Objects', Pkg => 'SR');
    my $tree = $p->parse($res);
    
    #print Data::Dumper->Dump([$tree])."\n";


    if (defined $tree && ref($tree->[0]) eq "SR::needinfo" && 
        exists $tree->[0]->{Kids} && ref($tree->[0]->{Kids}) eq "ARRAY") 
    {
        if ($ctx->{xmlout})
        {
            $ctx->{xmloutput} = "$res\n";
            return 1;
        }

        # cleanup old stuff
        $ctx->{registerReadableText} = [];
        $ctx->{registerManuallyURL} = "";
        $ctx->{registerPrivPol} = "";

        if (exists $tree->[0]->{href} &&
            defined $tree->[0]->{href} &&
            $tree->[0]->{href} ne "")
        {
            my $uri = URI->new($tree->[0]->{href});
            my $h = $uri->query_form_hash();
            $h->{lang} = "$ctx->{lang}";
            $uri->query_form_hash($h);
            $ctx->{registerManuallyURL} = $uri->as_string;
        }
        
        my $ret = Register::evalNeedinfo($ctx, $tree);
        if($ctx->{errorcode} != 0)
        {
            return 2;
        }
        
        if ($#{$ctx->{registerReadableText}} > -1 && 
            $ctx->{registerReadableText}->[$#{$ctx->{registerReadableText}}] =~ /^\s*$/) 
        {
            pop @{$ctx->{registerReadableText}};
        }
        
        if(!$ctx->{yastcall})
        {
            unshift @{$ctx->{registerReadableText}},
            "To complete the registration, provide some additional parameters:\n\n";
            
            push @{$ctx->{registerReadableText}}, "\nYou can provide these parameters with the '-a' option.\n";
            push @{$ctx->{registerReadableText}}, "You can use the '-a' option multiple times.\n\n";
            push @{$ctx->{registerReadableText}}, "Example:\n\n";
            push @{$ctx->{registerReadableText}}, 'suse_register -a email="me@example.com"'."\n";
            push @{$ctx->{registerReadableText}}, "\nTo register your product manually, use the following URL:\n\n";
            push @{$ctx->{registerReadableText}}, "$ctx->{registerManuallyURL}\n\n";
            
        }
        else 
        {
            unshift @{$ctx->{registerReadableText}}, "<pre>";
            push @{$ctx->{registerReadableText}}, "</pre>";
            push @{$ctx->{registerReadableText}}, "<p>To register your product manually, use the following URL:</p>\n";
            push @{$ctx->{registerReadableText}}, "<pre>$ctx->{registerManuallyURL}</pre>\n\n";
        }
        
        push @{$ctx->{registerReadableText}}, $ctx->{registerPrivPol};
        
        
        # after the first needinfo, set accept=mandatory to true
        # If the application think, that this is not a good idea
        # it can reset this.
        $ctx->{acceptmand} = 1;
        
        print STDERR Register::indent($ctx)."END: register(needinfo):".(tv_interval($t0))."\n" if($ctx->{time});
        $ctx->{timeindent}--;
        
        # return 1 == needinfo
        return 1;
    }
    elsif (defined $tree && ref($tree->[0]) eq "SR::zmdconfig" &&
           exists $tree->[0]->{Kids} && ref($tree->[0]->{Kids}) eq "ARRAY")
    {
        $ctx->{xmloutput} = "$res\n";
        return 0;
        
    }
    else
    {
        Register::logPrintError($ctx, "Unknown reponse format.\n", 11);
        return 2;
    }
    print STDERR Register::indent($ctx)."END: register(zmdconfig):".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;
    return 0;
}


sub fullpathOf 
{
    my $ctx = shift;
    my $program = shift || undef;
    
    if(!defined $program || $program eq "" || $program !~ /^[\w_-]+$/)
    {
        return undef;
    }
    
    my $fullpath = `which $program 2>/dev/null`;
    chomp($fullpath);
    print STDERR "Fullpath:$fullpath\n" if($ctx->{debug} >=2);
    
    if (defined $fullpath && $fullpath ne "")
    {
        return $fullpath;
    }
    return undef;
}

sub evaluateCommand
{
    my $ctx = shift;
    my $command   = shift || undef;
    my $mandatory = shift || 0;
    my $cmd       = undef;
    my $out       = undef;
    my @arguments = ();

    $ctx->{timeindent}++;
    my $t0 = [gettimeofday] if($ctx->{time});
    print STDERR indent($ctx)."START: evaluateCommand\n" if($ctx->{time});


    if (!defined $command || $command eq "")
    {
        logPrintError($ctx, "Missing command.\n", 14);
        return undef;
    }

    if ($command =~ /^hwinfo\s*(.*)\s*$/)
    {
        if(!$ctx->{nohwdata})
        {
            $cmd = undef;
            if (defined $1)
            {
                if($1 eq "--cpu")
                {
                    $out = '01: None 00.0: 10103 CPU
  [Created at cpu.290]
  Unique ID: rdCR.j8NaKXDZtZ6
  Hardware Class: cpu
  Arch: Intel
  Vendor: "GenuineIntel"
  Model: 15.2.7 "Intel(R) Pentium(R) 4 CPU 2.53GHz"
  Features: fpu,vme,de,pse,tsc,msr,pae,mce,cx8,apic,sep,mtrr,pge,mca,cmov,pat,pse36,clflush,dts,acpi,mmx,fxsr,sse,sse2,ss,ht,tm,pbe,cid
  Clock: 2533 MHz
  Cache: 512 kb
  Units/Processor: 1
  Config Status: cfg=new, avail=yes, need=no, active=unknown
';
                }
                elsif($1 eq "--disk")
                {
                    $out = '15: IDE 00.0: 10600 Disk
  [Created at block.193]
  UDI: /org/freedesktop/Hal/devices/storage_serial_WF0WFJ62565
  Unique ID: l_yX.aqnQfZWFJ99
  Parent ID: 3p2J.Ee0nWqHrzxE
  SysFS ID: /block/hda
  SysFS BusID: 0.0
  SysFS Device Link: /devices/pci0000:00/0000:00:1f.1/ide0/0.0
  Hardware Class: disk
  Model: "IBM-DTTA-351010"
  Device: "IBM-DTTA-351010"
  Revision: "T56OA73A"
  Serial ID: "WF0WFJ62565"
  Driver: "PIIX_IDE", "ide-disk", "ide-disk"
  Device File: /dev/hda
  Device Files: /dev/hda, /dev/disk/by-id/ata-IBM-DTTA-351010_WF0WFJ62565, /dev/disk/by-path/pci-0000:00:1f.1-ide-0:0, /dev/disk/by-id/edd-int13_dev80
  Device Number: block 3:0-3:63
  BIOS id: 0x80
  Geometry (Logical): CHS 19650/16/63
  Size: 19807200 sectors a 512 bytes
  Geometry (BIOS EDD): CHS 19650/16/63
  Size (BIOS EDD): 19807200 sectors
  Geometry (BIOS Legacy): CHS 1023/255/63
  Config Status: cfg=no, avail=yes, need=no, active=unknown
  Attached to: #10 (IDE interface)
';
                }
                elsif($1 eq "--dsl")
                {
                    $out = '';
                }
                elsif($1 eq "--gfxcard")
                {
                    $out = '21: PCI(AGP) 100.0: 0300 VGA compatible controller (VGA)
  [Created at pci.312]
  UDI: /org/freedesktop/Hal/devices/pci_1002_5157
  Unique ID: VCu0.fPl59+BnBR8
  Parent ID: vSkL.2rJrak7FxvF
  SysFS ID: /devices/pci0000:00/0000:00:01.0/0000:01:00.0
  SysFS BusID: 0000:01:00.0
  Hardware Class: graphics card
  Model: "Hightech Information RV200 QW"
  Vendor: pci 0x1002 "ATI Technologies Inc"
  Device: pci 0x5157 "RV200 QW"
  SubVendor: pci 0x17af "Hightech Information System Ltd."
  SubDevice: pci 0x2002
  Memory Range: 0xe8000000-0xefffffff (rw,prefetchable)
  I/O Ports: 0xc800-0xc8ff (rw)
  Memory Range: 0xff8f0000-0xff8fffff (rw,non-prefetchable)
  Memory Range: 0xff8c0000-0xff8dffff (ro,prefetchable,disabled)
  IRQ: 11 (no events)
  I/O Ports: 0x3c0-0x3df (rw)
  Module Alias: "pci:v00001002d00005157sv000017AFsd00002002bc03sc00i00"
  Driver Info #0:
    XFree86 v4 Server Module: radeon
  Driver Info #1:
    XFree86 v4 Server Module: radeon
    3D Support: yes
    Color Depths: 16
    Extensions: dri
    Options:
  Config Status: cfg=no, avail=yes, need=no, active=unknown
  Attached to: #11 (PCI bridge)

Primary display adapter: #21
';
                }
                elsif($1 eq "--isdn")
                {
                    $out = '';
                }
                elsif($1 eq "--memory")
                {
                    $out = '01: None 00.0: 10102 Main Memory
  [Created at memory.59]
  Unique ID: rdCR.CxwsZFjVASF
  Hardware Class: memory
  Model: "Main Memory"
  Memory Range: 0x00000000-0x3fedfbff (rw)
  Memory Size: 1 GB
  Config Status: cfg=no, avail=yes, need=no, active=unknown
';
                }
                elsif($1 eq "--netcard")
                {
                    $out = '22: PCI 208.0: 0200 Ethernet controller
  [Created at pci.312]
  UDI: /org/freedesktop/Hal/devices/pci_8086_1039
  Unique ID: rBUF.YFpX9nR8ki1
  Parent ID: 6NW+.ccU5FZC1tz2
  SysFS ID: /devices/pci0000:00/0000:00:1e.0/0000:02:08.0
  SysFS BusID: 0000:02:08.0
  Hardware Class: network
  Model: "Intel 82801DB PRO/100 VE (LOM) Ethernet Controller"
  Vendor: pci 0x8086 "Intel Corporation"
  Device: pci 0x1039 "82801DB PRO/100 VE (LOM) Ethernet Controller"
  SubVendor: pci 0x8086 "Intel Corporation"
  SubDevice: pci 0x3015
  Revision: 0x82
  Driver: "e100"
  Device File: eth0
  Memory Range: 0xff9ff000-0xff9fffff (rw,non-prefetchable)
  I/O Ports: 0xdc00-0xdc3f (rw)
  IRQ: 201 (2446609 events)
  HW Address: 00:07:e9:f2:fd:c8
  Link detected: yes
  Module Alias: "pci:v00008086d00001039sv00008086sd00003015bc02sc00i00"
  Driver Info #0:
    Driver Status: e100 is active
    Driver Activation Cmd: "modprobe e100"
  Driver Info #1:
    Driver Status: eepro100 is not active
    Driver Activation Cmd: "modprobe eepro100"
  Config Status: cfg=no, avail=yes, need=no, active=unknown
  Attached to: #16 (PCI bridge)
';
                }
                elsif($1 eq "--scsi")
                {
                    $out = '';
                }
                elsif($1 eq "--sound")
                {
                    $out = '20: PCI 1f.5: 0401 Multimedia audio controller
  [Created at pci.312]
  UDI: /org/freedesktop/Hal/devices/pci_8086_24c5
  Unique ID: W60f.FqFX8nG0RM2
  SysFS ID: /devices/pci0000:00/0000:00:1f.5
  SysFS BusID: 0000:00:1f.5
  Hardware Class: sound
  Model: "Intel 82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) AC\'97 Audio Controller"
  Vendor: pci 0x8086 "Intel Corporation"
  Device: pci 0x24c5 "82801DB/DBL/DBM (ICH4/ICH4-L/ICH4-M) AC\'97 Audio Controller"
  SubVendor: pci 0x8086 "Intel Corporation"
  SubDevice: pci 0x0106
  Revision: 0x02
  I/O Ports: 0xe400-0xe4ff (rw)
  I/O Ports: 0xe080-0xe0bf (rw)
  Memory Range: 0xffaff800-0xffaff9ff (rw,non-prefetchable)
  Memory Range: 0xffaff400-0xffaff4ff (rw,non-prefetchable)
  IRQ: 3 (no events)
  Module Alias: "pci:v00008086d000024C5sv00008086sd00000106bc04sc01i00"
  Driver Info #0:
    Driver Status: i810_audio is not active
    Driver Activation Cmd: "modprobe i810_audio"
  Driver Info #1:
    Driver Status: snd_intel8x0 is not active
    Driver Activation Cmd: "modprobe snd_intel8x0"
  Config Status: cfg=no, avail=yes, need=no, active=unknown
';
                }
                elsif($1 eq "--sys")
                {
                    $out = '02: None 00.0: 10107 System
  [Created at sys.57]
  Unique ID: rdCR.n_7QNeEnh23
  Hardware Class: system
  Model: "System"
  Formfactor: "unknown"
  Driver Info #0:
    Driver Status: thermal,fan are active
    Driver Activation Cmd: "modprobe thermal; modprobe fan"
  Config Status: cfg=no, avail=yes, need=no, active=unknown
';
                }
                elsif($1 eq "--tape")
                {
                    $out = '';
                }
                else
                {
                    $out = '';
                }
            }
        }
        elsif($ctx->{mandatory})
        {
            logPrintError($ctx, "Mandatory hardware data cannot be supplied because the option --no-hw-data was given.\n",
                          3);
            return undef;
        }
        else
        {
            return "DISCARDED";
        }
    }
    elsif ($command =~ /^lsb_release\s*(.*)\s*$/)
    {
        # maybe lsb_release is not installed
        if(-e $ctx->{lsb_release})
        {
            $cmd = $ctx->{lsb_release};
            if (defined $1) 
            {
                @arguments = split(/\s+/, $1);
            }
        }
        else
        {
            return "";
        }
    }
    elsif ($command =~ /^uname\s*(.*)\s*$/)
    {
        $cmd = $ctx->{uname};
        if (defined $1)
        {
            @arguments = split(/\s+/, $1);
        }
    }
    elsif ($command =~ /^zmd-secret$/)
    {
        $cmd = undef;
        open(SEC, "< $ctx->{SECRET_FILE}") or do
        {
            logPrintError($ctx, "Cannot open file $ctx->{SECRET_FILE}: $!\n", 12);
            return undef;
        };
        while(<SEC>)
        {
            $out .= $_;
        }
        close SEC;
    }
    elsif ($command =~ /^zmd-ostarget$/)
    {
        $cmd = undef;

        my ($code, $msg) = rugOSTarget($ctx);
        if($code != 0)
        {
            logPrintError($ctx, $msg, $code);
            return undef;
        }
                
        $out = $ctx->{ostarget};
    }
    elsif ($command =~ /^cpu-count$/)
    {
        $cmd = undef;

        if(!$ctx->{nohwdata})
        {
            $out = cpuCount($ctx);
        }
        elsif($ctx->{mandatory})
        {
            logPrintError($ctx, "Mandatory hardware data cannot be supplied because the option --no-hw-data was given.\n",
                          3);
            return undef;
        }
        else
        {
            return "DISCARDED";
        }
    }
    elsif ($command =~ /^installed-desktops$/)
    {
        $cmd = undef;

        if(!$ctx->{nohwdata})
        {
            my $kde = 0;
            my $gnome = 0;
            my $x11 = 0;
            
            if($#{$ctx->{installedPatterns}} == -1)
            {
                # ignore errors, getPatterns is not so important
                getPatterns($ctx);
            }
            
            foreach my $pat (@{$ctx->{installedPatterns}})
            {
                if($pat eq "kde")
                {
                    $kde = 1;
                }
                elsif($pat eq "gnome")
                {
                    $gnome = 1;
                }
                elsif($pat eq "x11")
                {
                    $x11 = 1;
                }
            }
            
            $out = "KDE" if($kde && !$gnome);
            $out = "GNOME" if(!$kde && $gnome);
            $out = "KDE+GNOME" if($kde && $gnome);
            $out = "X11" if($x11 && !$kde && !$gnome);
            $out = "NOX11" if(!$x11 && !$kde && !$gnome);
        }
        else
        {
            $out = "DISCARDED";
        }
    }
    else
    {
        $out = "DISCARDED"; # command not allowed; reply DISCARDED
        $cmd = undef;
    }

    if (defined $cmd)
    {
        print "Execute $cmd ".join(" ", @arguments)."\n" if($ctx->{debug});
        
        my $pid = open3(\*IN, \*OUT, \*ERR, $cmd, @arguments) or do 
        {
            logPrintError($ctx, "Cannot execute $cmd ".join(" ", @arguments).": $!\n",13);
            return undef;
        };

        while (<OUT>)
        {
            $out .= "$_";
        }
        #chomp($msg) if(defined $msg && $msg ne "");
        while (<ERR>)
        {
            $out .= "$_";
        }
        close OUT;
        close ERR;
        close IN;
        waitpid $pid, 0;
        chomp($out) if(defined $out && $out ne "");
        if(!defined $out || $out eq "") 
        {
            $out = "";
        }
        print STDERR "LENGTH: ".length($out)."\n" if($ctx->{debug});
    }
    
    print STDERR indent($ctx)."END: evaluateCommand:".(tv_interval($t0))."\n" if($ctx->{time});
    $ctx->{timeindent}--;
    
    return $out;
}


1;

