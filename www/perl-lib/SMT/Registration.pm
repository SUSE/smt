package SMT::Registration;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use Apache2::Filter ();

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log MODE_READBYTES);
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);

use constant IOBUFSIZE => 8192;

use Log::Log4perl qw(get_logger :levels);

use SMT::Utils;
use SMT::Client;
use SMT::RegParams;
use SMT::RegSession;
use DBI qw(:sql_types);

use Data::Dumper;
use DBI;
use XML::Writer;
use XML::Parser;
use CGI;

sub handler {
    my $r = shift;
    my $log = get_logger('apache.smt.registration');
    
    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};
    
    if(! defined $args)
    {
        $log->error("Registration called without args.");
        return Apache2::Const::SERVER_ERROR;
    }
    
    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }
    $log->info("Registration called with command: ".$hargs->{command});

    if(exists $hargs->{command} && defined $hargs->{command})
    {
        if($hargs->{command} eq "register")
        {
            SMT::Registration::register($r, $hargs);
        }
        elsif($hargs->{command} eq "listproducts")
        {
            SMT::Registration::listproducts($r, $hargs);
        }
        elsif($hargs->{command} eq "listparams")
        {
            SMT::Registration::listparams($r, $hargs);
        }
        elsif($hargs->{command} eq "interactive")
        {
          SMT::Registration::interactive($r, $hargs);
        }
        elsif($hargs->{command} eq "apply")
        {
          SMT::Registration::applyInteractive($r, $hargs);
        }
        else
        {
            $log->error("Unknown command: ".$hargs->{command});
            return Apache2::Const::SERVER_ERROR;
        }
    }
    else
    {
        $log->error("Missing command");
        return Apache2::Const::SERVER_ERROR;
    }
    
    return Apache2::Const::OK;
}

#
# called from handler if client wants to register
# command=register argument given
#
sub register
{
    my $r          = shift;
    my $hargs      = shift;
    my $log = get_logger('apache.smt.registration.smt.registration');
    
    my $namespace  = "";
    
    $log->debug("register called");

    # to be compatible with SMT10
    if(exists $hargs->{testenv} && $hargs->{testenv})
    {
        $namespace = "testing";
    }
    if(exists $hargs->{namespace} && defined $hargs->{namespace} && $hargs->{namespace} ne "")
    {
        $namespace = $hargs->{namespace};
    }

    if( $namespace ne "" ) 
    {
        my $cfg = undef;
        
        eval
        {
            $cfg = SMT::Utils::getSMTConfig();
        };
        if($@ || !defined $cfg)
        {
            $log->error("Cannot read the SMT configuration file: ".$@);
            die "SMT server is missconfigured. Please contact your administrator.";
        }

        my $LocalBasePath = $cfg->val('LOCAL', 'MirrorTo');
        if(! -d  "$LocalBasePath/repo/$namespace" )
        {
            $log->error("Invalid namespace requested: $LocalBasePath/repo/$namespace/ does not exists.");
            $namespace = "";
        }
    }

    my $data = read_post($r);
    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $log->error("Cannot open Database");
        die "Please contact your administrator.";
    }

    my $regparam = SMT::RegParams->new( );
    $regparam->parse( $data );

    my $regsession = SMT::RegSession->new( dbh => $dbh, guid => $regparam->guid() );
    if( $regsession->loadSession() )
    {
      $regparam->joinSession( $regsession->yaml() );
    }
    $regsession->updateSession( $regparam->yaml() );

    
    my $xml = SMT::Registration::paramsForProducts("needinfo", $r, $dbh, $regparam->products(), $regparam);
    
  if($xml ne "")
  {
    $log->debug("Return NEEDINFO: $xml");

    # we need to send the <needinfo>
    print $xml;
  }
  else
  {
        # we have all data; store it and send <zmdconfig>

        # get the os-target

        my $target = SMT::Registration::findTarget($r, $dbh, $regparam);

        # insert new registration data

        my $pidarr = SMT::Registration::insertRegistration($r, $dbh, $regparam, $namespace, $target);

        # get the catalogs

        my $catalogs = SMT::Registration::findCatalogs($r, $dbh, $target, $pidarr);

        # send new <zmdconfig>

        my $zmdconfig = SMT::Registration::buildZmdConfig($r, $regparam->guid(), $catalogs, $namespace);

        $regsession->cleanSession();

        $log->debug("Return ZMDCONFIG: $zmdconfig");
        print $zmdconfig;
    }
    $dbh->disconnect();

    return;
}

#
# called from handler if client wants the product list
# command=listproducts argument given
#
sub listproducts
{
    my $r     = shift;
    my $hargs = shift;
    my $log = get_logger('apache.smt.registration.smt.registration');
    
    $log->debug("listproducts called");

    my $dbh = SMT::Utils::db_connect();
    if(!$dbh)
    {
        $log->error("Cannot connect to database");
        die "Please contact your administrator";
    }
    
    my $sth = $dbh->prepare("SELECT DISTINCT PRODUCT FROM Products where product_list = 'Y'");
    $sth->execute();

    my $output = "";
    my $writer = new XML::Writer(NEWLINES => 0, OUTPUT => \$output);
    $writer->xmlDecl('UTF-8');

    $writer->startTag("productlist",
                      "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "lang"  => "en");
    
    while ( my @row = $sth->fetchrow_array ) 
    {
        $writer->startTag("product");
        $writer->characters($row[0]);
        $writer->endTag("product");
    }
    $writer->endTag("productlist");
    
    $log->debug("Return PRODUCTLIST: $output");
    
    print $output;

    $dbh->disconnect();

    return;
}

#
# called from handler if client wants to fetch the parameter list
# command=listparams argument given
#
sub listparams
{
    my $r     = shift;
    my $hargs = shift;
    my $log = get_logger('apache.smt.registration.smt.registration');
    
    $log->debug("listparams called");

    my $lpreq = read_post($r);
    my $dbh = SMT::Utils::db_connect();

    my $data  = {STATE => 0, PRODUCTS => []};
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { prod_handle_start_tag($data, @_) },
                                     Char => sub { prod_handle_char($data, @_) },
                                     End=>   sub { prod_handle_end_tag($data, @_) }
                                   });
    eval {
        $parser->parse( $lpreq );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        $log->error("SMT::Registration::parseFromProducts Invalid XML: $@");
    }
    
    my $xml = SMT::Registration::paramsForProducts("paramlist", $r, $dbh, $data->{PRODUCTS});
    $log->debug("Return PARAMLIST: $xml");
    
    print $xml;
    
    $dbh->disconnect();

    return;
}

sub applyInteractive
{
  my $r     = shift;
  my $hargs = shift;
  my $pargs = {};
  my $log = get_logger('apache.smt.registration');
  
  $r->content_type('text/html');
  
  $log->debug("applyInteractive called");

  my $lpreq = read_post($r);

  my $query = new CGI( $lpreq );
  foreach my $key ( $query->param )
  {
    my $value = $query->param($key);
    $value =~ s{&}{&amp;}gso;
    $value =~ s{"}{&quot;}gso;
    $value =~ s{<}{&lt;}gso;
    $value =~ s{>}{&gt;}gso;
    $pargs->{$key} = $value;
    $log->debug("Param: $key = ".$query->param($key));
  }

  my $dbh = SMT::Utils::db_connect();
  if(!$dbh)
  {
    $log->error("Cannot connect to database");
    die "Please contact your administrator";
  }
  my $guid = undef;
  my $sessionID = undef;
  $guid = $pargs->{guid} if(exists $pargs->{guid} && defined $pargs->{guid} && $pargs->{guid} ne "");
  $sessionID = $pargs->{sessionid} if(exists $pargs->{sessionid} && defined $pargs->{sessionid} && $pargs->{sessionid} ne "");

  if(!defined $sessionID)
  {
    $log->error("No sessionID found.");
    die "Forbidden";
  }

  my $regsession = SMT::RegSession->new( dbh => $dbh, guid => $guid );
  if( !$regsession->loadSession() )
  {
    $log->error("Session could not be loaded");
    die "Not Found";
  }
  my $regparam = SMT::RegParams->new( );
  $regparam->guid($guid);
  if(!$regparam->joinSession( $regsession->yaml(), $sessionID ))
  {
    $log->error("RegParams object could not be created");
    die "Forbidden";
  }
  
  # check if the session is in the correct status
  
  if(!defined $regparam->param("secret") || $regparam->param("secret") eq "")
  {
    $log->error("No secret found in interactive session.");
    die "Internal Server Error";
  }

  my @list = findColumnsForProducts($r, $dbh, $regparam->products(), "PRODUCTDATAID");
  my $pids = $dbh->quote(shift @list);
  foreach my $item (@list)
  {
    $pids .= ", ".$dbh->quote($item);
  }
  
  my $statement = sprintf("SELECT distinct param_name FROM needinfo_params WHERE product_id IN (%s) AND command = '' ORDER BY id",
                          $pids);
  $log->debug("STATEMENT: $statement");
  my $arrayref = $dbh->selectall_arrayref( $statement, {Slice => {}} );

  foreach my $value (@{$arrayref})
  {
    next if($value->{param_name} eq "guid" || $value->{param_name} eq "host");
    next if($value->{param_name} eq "product" || $value->{param_name} eq "privacy");
    if(exists $pargs->{$value->{param_name}} && defined $pargs->{$value->{param_name}} &&
      $pargs->{$value->{param_name}} ne "")
    {
      $regparam->param($value->{param_name}, $pargs->{$value->{param_name}});
    }
  }
  $regparam->wasInteractive(1);
  $regsession->updateSession( $regparam->yaml() );

  my $html =<<EOF
  <html>
  <head>
  <title>Subscription Management Tool - System Registration</title>
  <meta name="Robots" content="INDEX, FOLLOW"/>
  <meta http-equiv="Content-Language" content="en-US"/>
  <meta http-equiv="Content-Type" content="text/html; CHARSET=UTF-8"/>
  <script type="text/javascript" language="JavaScript"></script>
  <style type="text/css">
  a { color:#383A3B; }
  a:hover { color:#A6A9A9; text-decoration:underline; }
  h1 { font-size:150%; color:#565858; margin:0; padding:20px 0 28px 0;}
  h2 { font-size:100%; font-weight:normal; margin:-28px 0 15px 0; padding:0; }
  p.flyspec { font-size:80%; font-style:italic; }
  p.summary { font-style:italic; text-align:center; }
  .first, .notop { margin-top:0; padding-top:0; }
  
  #content { padding-left:154px; }
  #contenthead { font-size:75%; width:598px; }
  #mainbody { font-size:70%; min-height:320px; height:auto !important; height:100%; width:598px; }
  
  .dLeft { font-weight:bold; padding-right:10px; text-align:right; width:200px; }
  .dLeft, .dRight { float:left; }
  
  .fullw { clear:both; width:598px; }
  
  h1 { padding-top:0; padding-bottom:14px; }
  h2 { margin:-14px 0 14px 0; }
  #pageEnd { text-align:right; width:462px; padding:0; }
  #pageEnd p.imagebutton, #pageEnd p.imagebutton-arrowleft, #pageEnd p.imagebutton-arrowgray { float:right; margin-left:10px; }
  #pageEnd .dLeft p.imagebutton, #pageEnd .dLeft p.imagebutton-arrowgray { float:left; font-weight:normal; margin-left:0px; margin-right:10px; }
  
  </style>
  </head>
  
  <body>
  <div id="content">
  <div id="contenthead">
  <h1>Subscription Management Tool - System Registration</h1>
  </div>
  
  <div id="mainbody">
  
  <p>
  To complete the process of registering this system and getting access to online updates,
  you need to finish the registration process. Close the web browser and continue the registration.
  </p>
  </div>
  </div>
  </body>
  </html>
EOF
;

  print $html;
  return;
}

sub interactive
{
  my $r     = shift;
  my $hargs = shift;
  my $log = get_logger('apache.smt.registration');
  
  $r->content_type('text/html');
  
  $log->debug("interactive called");

  my $dbh = SMT::Utils::db_connect();
  if(!$dbh)
  {
    $log->error("Cannot connect to database");
    die "Please contact your administrator";
  }
  
  
  my $guid = undef;
  my $sessionID = undef;
  $guid = $hargs->{guid} if(exists $hargs->{guid} && defined $hargs->{guid} && $hargs->{guid} ne "");
  $sessionID = $hargs->{sessionid} if(exists $hargs->{sessionid} && defined $hargs->{sessionid} && $hargs->{sessionid} ne "");
  
  if(!defined $sessionID)
  {
    $log->error("No sessionID found.");
    die "Forbidden";
  }
  
  my $regsession = SMT::RegSession->new( dbh => $dbh, guid => $guid );
  if( !$regsession->loadSession() )
  {
    $log->error("Session could not be loaded");
    die "Not Found";
  }

  my $regparam = SMT::RegParams->new( );
  $regparam->guid($guid);
  if(!$regparam->joinSession( $regsession->yaml(), $sessionID ))
  {
    $log->error("RegParams object could not be created");
    die "Forbidden";
  }
  
  # check if the session is in the correct status
  
  if(!defined $regparam->param("secret") || $regparam->param("secret") eq "")
  {
    $log->error("No secret found in interactive session.");
    die "Internal Server Error";
  }
  
  my @list = findColumnsForProducts($r, $dbh, $regparam->products(), "FRIENDLY");
  my $productsFriendly = join('<br/>', @list);
  @list = findColumnsForProducts($r, $dbh, $regparam->products(), "PRODUCTDATAID");
  my $pids = $dbh->quote(shift @list);
  foreach my $item (@list)
  {
    $pids .= ", ".$dbh->quote($item);
  }
  
  my $statement = sprintf("SELECT distinct param_name, description, mandatory FROM needinfo_params WHERE product_id IN (%s) AND command = '' ORDER BY id",
                          $pids);
  $log->debug("STATEMENT: $statement");
  my $hashref = $dbh->selectall_hashref( $statement, "param_name" );
  
  my @pnames = ();
  foreach my $param_name (keys %{$hashref})
  {
     push @pnames, $dbh->quote($param_name);
  }
  $statement = sprintf("SELECT KEYNAME, VALUE FROM MachineData WHERE GUID = %s and KEYNAME IN (%s)",
                       $dbh->quote($regparam->guid()), join(',', @pnames));
  $log->debug("STATEMENT: $statement");
  my $oldata = $dbh->selectall_hashref( $statement, "KEYNAME" );
  $log->debug("DATA: ".Data::Dumper->Dump([$oldata]));
  my $html =<<EOF
  <html>
  <head>
  <title>Subscription Management Tool - System Registration</title>
  <meta name="Robots" content="INDEX, FOLLOW"/>
  <meta http-equiv="Content-Language" content="en-US"/>
  <meta http-equiv="Content-Type" content="text/html; CHARSET=UTF-8"/>
  <style type="text/css">
  a { color:#383A3B; }
  a:hover { color:#A6A9A9; text-decoration:underline; }
  h1 { font-size:150%; color:#565858; margin:0; padding:20px 0 28px 0;}
  h2 { font-size:100%; font-weight:normal; margin:-28px 0 15px 0; padding:0; }
  p.flyspec { font-size:80%; font-style:italic; }
  p.summary { font-style:italic; text-align:center; }
  .first, .notop { margin-top:0; padding-top:0; }
  
  #content { padding-left:154px; }
  #contenthead { font-size:75%; width:598px; }
  #mainbody { font-size:70%; min-height:320px; height:auto !important; height:100%; width:598px; }
  
  .dLeft { font-weight:bold; padding-right:10px; text-align:right; width:200px; }
  .dLeft, .dRight { float:left; }
  
  .fullw { clear:both; width:598px; }
  
  h1 { padding-top:0; padding-bottom:14px; }
  h2 { margin:-14px 0 14px 0; }
  #pageEnd { text-align:right; width:462px; padding:0; }
  #pageEnd p.imagebutton, #pageEnd p.imagebutton-arrowleft, #pageEnd p.imagebutton-arrowgray { float:right; margin-left:10px; }
  #pageEnd .dLeft p.imagebutton, #pageEnd .dLeft p.imagebutton-arrowgray { float:left; font-weight:normal; margin-left:0px; margin-right:10px; }
  
  </style>
  </head>
  
  <body>
  <div id="content">
  <div id="contenthead">
    <h1>Subscription Management Tool - System Registration</h1>
    <h2>
      $productsFriendly
    </h2>
  </div>
  
  <div id="mainbody">
  
  <p>
  Please enter the following information to register your product. By completing this simple registration, you will gain immediate access to online updates.
  </p>
  
  <form name="Form" method="POST" action="regsvc?command=apply">
    <input type="hidden" name="guid" value="$guid"/>
    <input type="hidden" name="sessionid" value="$sessionID"/>
    <input type="hidden" name="lang" value="en-US"/>
    <input type="hidden" name="from" value="interactive"/>
    <div class="fullw">
EOF
;
  
  delete $hashref->{'guid'} if(exists $hashref->{'guid'});
  delete $hashref->{'host'} if(exists $hashref->{'host'});
  delete $hashref->{'product'} if(exists $hashref->{'product'});
  delete $hashref->{'privacy'} if(exists $hashref->{'privacy'});
  
  # first we display the email question
  if(exists $hashref->{'email'})
  {
    $html .= '    <div class="dLeft">'."\n";
    $html .= $hashref->{'email'}->{description};
    $html .= '    </div><div class="dRight">'."\n";
    $html .= '    <input type="text" name="email" size="40" maxlength="100" ';
    if(exists $oldata->{'email'} && defined $oldata->{'email'})
    {
      $html .= 'value="'.$oldata->{'email'}->{VALUE}.'"/>'."\n";
    }
    else
    {
      $html .= 'value=""/>'."\n";
    }
    $html .= '  </div>'."\n";
    $html .= '<div style="clear:both">&nbsp;</div>'."\n";
    delete $hashref->{'email'};
  }

  # next: all registration code questions
  foreach my $key (keys %{$hashref})
  {
    next if($key !~ /^regcode/);

    $html .= '    <div class="dLeft">'."\n";
    $html .= $hashref->{$key}->{description};
    $html .= '    </div><div class="dRight">'."\n";
    $html .= '    <input type="text" name="'.$key.'" size="40" maxlength="100" ';
    if(exists $oldata->{$key} && defined $oldata->{$key})
    {
      $html .= 'value="'.$oldata->{$key}->{VALUE}.'"/>'."\n";
    }
    else
    {
      $html .= 'value=""/>'."\n";
    }
    $html .= '  </div>'."\n";
    $html .= '<div style="clear:both">&nbsp;</div>'."\n";
    delete $hashref->{$key};
  }
  
  # last: everything which is left
  foreach my $key (keys %{$hashref})
  {
    $html .= '    <div class="dLeft">'."\n";
    $html .= $hashref->{$key}->{description};
    $html .= '    </div><div class="dRight">'."\n";
    $html .= '    <input type="text" name="'.$key.'" size="40" maxlength="100" ';
    if(exists $oldata->{$key} && defined $oldata->{$key})
    {
      $html .= 'value="'.$oldata->{$key}->{VALUE}.'"/>'."\n";
    }
    else
    {
      $html .= 'value=""/>'."\n";
    }
    $html .= '  </div>'."\n";
    $html .= '<div style="clear:both">&nbsp;</div>'."\n";
    delete $hashref->{$key};
  }
  
  $html .= '</div><div id="pageEnd"> <div class="dRight">'."\n";
  $html .= '<input type="submit" name="submit" value="Submit"/>'."\n";
  $html .= '</div></div></form>'."\n";
  $html .= '</div></div></body> </html>'."\n";

  print $html;
  return;
}

###############################################################################

sub paramsForProducts
{
  my $what = shift;
  my $r = shift;
  my $dbh = shift;
  my $productarray = shift;
  my $regparam = shift || undef;
  my $count = 0;
  
  my $array = getParamsForProducts($r, $dbh, $productarray);

  my $output = "";
  my $writer = XML::Writer->new(NEWLINES => 0, OUTPUT => \$output);
  $writer->xmlDecl("UTF-8");
  if($what eq "needinfo" && defined $regparam)
  {
    $writer->startTag("needinfo", "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "href" => " https://".$r->server()->server_hostname()."".$r->uri()."?command=interactive&guid=".$regparam->guid()."&sessionid=".$regparam->sessionID(),
                      "lang" => "en");
  }
  elsif($what eq "paramlist")
  {
    $writer->startTag("paramlist", "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "lang" => "en");
  }

  foreach my $p (@{$array})
  {
    if($what eq "needinfo" && defined $regparam)
    {
      next if($p->{param_name} eq "guid" && defined $regparam->guid());
      next if($p->{param_name} eq "host" && defined $regparam->param("host"));
      next if($p->{param_name} eq "product" && @{$regparam->products()} > 0 );
      next if($p->{param_name} eq "privacy" && $regparam->privacy());
      next if(defined $regparam->param($p->{param_name}));
      
      next if($p->{command} eq "" && ($regparam->wasInteractive() || $regparam->force() ne "registration"));
      next if($regparam->acceptMandatory() && !$p->{mandatory});
    }

    if($p->{param_name} eq "guid" || $p->{param_name} eq "host"||
      $p->{param_name} eq "product" || $p->{param_name} eq "privacy")
    {
      my %attrs = ();
      $attrs{description} = $p->{description};
      $attrs{class} = "mandatory" if($p->{mandatory});
      $attrs{command} = $p->{command} if($p->{command} ne "");
      $writer->emptyTag($p->{param_name}, %attrs);
    }
    else
    {
      my %attrs = ();
      $attrs{id} = $p->{param_name};
      $attrs{description} = $p->{description};
      $attrs{class} = "mandatory" if($p->{mandatory});
      $attrs{command} = $p->{command} if($p->{command} ne "");
      $writer->emptyTag("param", %attrs);
      $count++;
    }
  }
  if($what eq "needinfo")
  {
    $writer->endTag("needinfo");
  }
  elsif($what eq "paramlist")
  {
    $writer->endTag("paramlist");
  }
  
  return $output if($count > 0);
  return "";
}

sub getParamsForProducts
{
  my $r = shift;
  my $dbh = shift;
  my $productarray = shift;
  my $log = get_logger('apache.smt.registration');
  
  my @list = findColumnsForProducts($r, $dbh, $productarray, "PRODUCTDATAID");
  if( @list > 0 )
  {
    my $pids = $dbh->quote(shift @list);
    foreach my $item (@list)
    {
      $pids .= ", ".$dbh->quote($item);
    }
    my $statement = sprintf("SELECT distinct param_name, description, command, mandatory FROM needinfo_params WHERE product_id IN (%s) order by id",
                            $pids);
    $log->debug("STATEMENT: $statement");
    return $dbh->selectall_arrayref( $statement, {Slice => {}} );
  }
}

sub insertRegistration
{
    my $r         = shift;
    my $dbh       = shift;
    my $regparam  = shift;
    my $namespace = shift || '';
    my $target    = shift || '';
    my $log = get_logger('apache.smt.registration');
    
    my $cnt     = 0;
    my $existingpids = {};
    my $regtimestring = "";
    my $hostname = "";
    
    my @list = findColumnsForProducts($r, $dbh, $regparam->products(), "PRODUCTDATAID");

    my $statement = sprintf("SELECT PRODUCTID from Registration where GUID=%s", $dbh->quote($regparam->guid()));
    $log->debug("STATEMENT: $statement");
    eval
    {
        $existingpids = $dbh->selectall_hashref($statement, "PRODUCTID");
    };
    if($@)
    {
        $log->error("DBERROR: ".$dbh->errstr);
    }

    # store the regtime
    $regtimestring = SMT::Utils::getDBTimestamp();

    my @insert = ();
    my @update = ();

    foreach my $pnum (@list)
    {
        if(exists $existingpids->{$pnum})
        {
            # reg exists, do update
            push @update, $dbh->quote($pnum);
            delete $existingpids->{$pnum};
        }
        else
        {
            # reg does not exist, do insert
            push @insert, $pnum;
        }
    }
    
    my @delete = ();
    foreach my $d (keys %{$existingpids})
    {
        push @delete, $dbh->quote($d);
    }
    
    if(@delete > 0)
    {
      $statement = sprintf("DELETE from Registration where GUID=%s AND PRODUCTID ", $dbh->quote($regparam->guid()));
        if(@delete > 1)
        {
            $statement .= "IN (".join(",", @delete).")";
        }
        else
        {
            $statement .= "= ".$delete[0];
        }
        
        eval {
            $cnt = $dbh->do($statement);
            $log->debug("STATEMENT: $statement  Affected rows: $cnt");
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
    }

    foreach my $id (@insert)
    {
        eval {
            my $sth = $dbh->prepare("INSERT into Registration (GUID, PRODUCTID, REGDATE) VALUES (?, ?, ?)");
            $sth->bind_param(1, $regparam->guid());
            $sth->bind_param(2, $id, SQL_INTEGER);
            $sth->bind_param(3, $regtimestring, SQL_TIMESTAMP);
            $cnt = $sth->execute;
            
            $log->debug("STATEMENT: ".$sth->{Statement}." Affected rows: $cnt");
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
    }

    if(@update > 0)
    {
        $statement = "UPDATE Registration SET REGDATE=? WHERE GUID=? AND PRODUCTID "; 

        if(@update > 1)
        {
            $statement .= "IN (".join(",", @update).")";
        }
        else
        {
            $statement .= "= ".$update[0];
        }
        
        eval {
            my $sth = $dbh->prepare($statement);
            $sth->bind_param(1, $regtimestring, SQL_TIMESTAMP);
            $sth->bind_param(2, $regparam->guid());
            $cnt = $sth->execute;
            $log->debug("STATEMENT: ".$sth->{Statement}."  Affected rows: $cnt");
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
    }
    
    
    #
    # clean old machinedata
    #
    $cnt = 0;
    $statement = sprintf("DELETE from MachineData where GUID=%s", $dbh->quote($regparam->guid()));
    eval {
        $cnt = $dbh->do($statement);
        $log->debug("STATEMENT: $statement  Affected rows: $cnt");
    };
    if($@)
    {
        $log->error("DBERROR: ".$dbh->errstr);
    }
    
    #
    # insert new machinedata
    #
    foreach my $key (keys %{$regparam->params()})
    {
        next if($key eq "guid" || $key eq "product" || $key eq "mirrors");
        if($key eq "hostname")
        {
            $hostname = $regparam->param($key);
        }
        
        my $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regparam->guid()),
                                $dbh->quote($key),
                                $dbh->quote($regparam->param($key)));
        $log->debug("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
    }

    for(my $i = 0; $i < @{$regparam->products()}; $i++)
    {
      my $ph = @{$regparam->products()}[$i];

        my $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                                $dbh->quote($regparam->guid()),
                                $dbh->quote("product-name-".$list[$i]),
                                $dbh->quote($ph->{name}));
        $log->debug("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regparam->guid()),
                             $dbh->quote("product-version-".$list[$i]),
                             $dbh->quote($ph->{version}));
        $log->debug("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regparam->guid()),
                             $dbh->quote("product-arch-".$list[$i]),
                             $dbh->quote($ph->{arch}));
        $log->debug("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
        $statement = sprintf("INSERT into MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                             $dbh->quote($regparam->guid()),
                             $dbh->quote("product-rel-".$list[$i]),
                             $dbh->quote($ph->{release}));
        $log->debug("STATEMENT: $statement");
        eval {
            $dbh->do($statement);
        };
        if($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
        }
    }
    #
    # if we do not have the hostname, try to get the IP address
    #
    if($hostname eq "")
    {
        $hostname = $r->connection()->remote_host();
        if(! defined $hostname || $hostname eq "")
        {
            $hostname = $r->connection()->remote_ip();
        }
    }

    #
    # update Clients table
    #
    my $aff = 0;
    eval
    {
        my $sth = $dbh->prepare("UPDATE Clients SET HOSTNAME=?, TARGET=?, LASTCONTACT=?, NAMESPACE=?, SECRET=? WHERE GUID=?");
        $sth->bind_param(1, $hostname);
        $sth->bind_param(2, $target);
        $sth->bind_param(3, $regtimestring, SQL_TIMESTAMP);
        $sth->bind_param(4, $namespace );
        $sth->bind_param(5, $regparam->param("secret"));
        $sth->bind_param(6, $regparam->guid());
        $aff = $sth->execute;

        $log->debug("STATEMENT: ".$sth->{Statement});
    };
    if ($@)
    {
        $log->error("DBERROR: ".$dbh->errstr);
        $aff = 0;
    }
    if ($aff == 0)
    {
        # New registration; we need an insert
        $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET, NAMESPACE, SECRET) VALUES (%s, %s, %s, %s, %s)",
                             $dbh->quote($regparam->guid()),
                             $dbh->quote($hostname),
                             $dbh->quote($target),
                             $dbh->quote($namespace),
                             $dbh->quote($regparam->param("secret")));
        $log->debug("STATEMENT: $statement");
        eval
        {
            $aff = $dbh->do($statement);
        };
        if ($@)
        {
            $log->error("DBERROR: ".$dbh->errstr);
            $aff = 0;
        }
    }

    my $client = SMT::Client->new({ 'dbh' => $dbh });
    
    if ( !  $client->insertPatchstatusJob( $regparam->guid() ) )
    {
        $log->error(sprintf("SMT Registration error: Could not create initial patchstatus reporting job for client with guid: %s  ",
                            $regparam->guid() )  );
    }
    
    return \@list;
}

sub findTarget
{
    my $r        = shift;
    my $dbh      = shift;
    my $regparam = shift;
    my $log = get_logger('apache.smt.registration');
    
    my $result  = undef;
    
    my $rtarget = $regparam->param("ostarget");
    if(!defined $rtarget || $rtarget ne "")
    {
      $rtarget = $regparam->param("ostarget-bak");
      $rtarget =~ s/^\s*"//;
      $rtarget =~ s/"\s*$//;
    }
    
    if(defined $rtarget && $rtarget ne "")
    {
        my $statement = sprintf("SELECT TARGET from Targets WHERE OS=%s", $dbh->quote($rtarget)) ;
        $log->debug("STATEMENT: $statement");

        my $target = $dbh->selectcol_arrayref($statement);

        if(exists $target->[0])
        {
            $result = $target->[0];
        }
    }
    return $result;
}

sub findCatalogs
{
    my $r      = shift;
    my $dbh    = shift;
    my $target = shift;
    my $productids = shift;
    my $log = get_logger('apache.smt.registration');
    

    my $result = {};
    my $statement ="";

    my @q_pids = ();
    foreach my $id (@{$productids})
    {
        push @q_pids, $dbh->quote($id);
    }
    

    # get catalog values (only for the once we DOMIRROR)

    $statement  = "SELECT c.CATALOGID, c.NAME, c.DESCRIPTION, c.TARGET, c.LOCALPATH, c.CATALOGTYPE, c.STAGING from Catalogs c, ProductCatalogs pc WHERE ";
    $statement .= "pc.OPTIONAL='N' AND c.DOMIRROR='Y' AND c.CATALOGID=pc.CATALOGID ";
    $statement .= "AND (c.TARGET IS NULL ";
    if(defined $target && $target ne "")
    {
        $statement .= sprintf("OR c.TARGET=%s", $dbh->quote($target));
    }
    $statement .= ") AND ";

    if(@{$productids} > 1)
    {
        $statement .= "pc.PRODUCTDATAID IN (".join(",", @q_pids).") ";
    }
    elsif(@{$productids} == 1)
    {
        $statement .= "pc.PRODUCTDATAID = ".$q_pids[0]." ";
    }
    else
    {
        # This should not happen
        $log->error("No productids found");
        return $result;
    }
    
    $log->debug("STATEMENT: $statement");

    $result = $dbh->selectall_hashref($statement, "CATALOGID");

    $log->debug("RESULT: ".Data::Dumper->Dump([$result]));

    return $result;
}

sub buildZmdConfig
{
    my $r          = shift;
    my $guid       = shift;
    my $catalogs   = shift;
    my $namespace  = shift || '';
    my $log = get_logger('apache.smt.registration');
    
    my $cfg = undef;

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $log->error("Cannot read the SMT configuration file: ".$@);
        die "SMT server is missconfigured. Please contact your administrator.";
    }
    
    my $LocalNUUrl = $cfg->val('LOCAL', 'url');
    my $aliasChange = $cfg->val('NU', 'changeAlias');
    if(defined $aliasChange && $aliasChange eq "true")
    {
        $aliasChange = 1;
    }
    else
    {
        $aliasChange = 0;
    }
    
    $LocalNUUrl =~ s/\s*$//;
    if(!defined $LocalNUUrl || $LocalNUUrl !~ /^http/)
    {
        $log->error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        die "SMT server is missconfigured. Please contact your administrator.";
    }
    my $localID = "SMT-".$LocalNUUrl;
    $localID =~ s/:*\/+/_/g;
    $localID =~ s/\./_/g;
    $localID =~ s/_$//;

    my $nuCatCount = 0;
    foreach my $cat (keys %{$catalogs})
    {
        $nuCatCount++ if(lc($catalogs->{$cat}->{CATALOGTYPE}) eq "nu");
    }

    my $output = "";
    my $writer = new XML::Writer(OUTPUT => \$output);

    $writer->xmlDecl("UTF-8");
    $writer->startTag("zmdconfig", 
                      "xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
                      "lang"  => "en");
    
    $writer->startTag("guid");
    $writer->characters($guid);
    $writer->endTag("guid");
    
    # first write all catalogs of type NU
    if($nuCatCount > 0)
    {
        $writer->startTag("service", 
                          "id"          => "$localID",
                          "description" => "Local NU Server",
                          "type"        => "nu");
        $writer->startTag("param", "id" => "url");
        $writer->characters($LocalNUUrl);
        $writer->endTag("param");
        
        foreach my $cat (keys %{$catalogs})
        {
            next if(lc($catalogs->{$cat}->{CATALOGTYPE}) ne "nu");
            if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
               $catalogs->{$cat}->{LOCALPATH} eq "")
            {
                $log->error("Path for repository '$cat' does not exists. Skipping the repository.");
                next;
            }

            my $catalogURL = "$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH};
            my $catalogName = $catalogs->{$cat}->{NAME};
            if($namespace ne "" && uc($catalogs->{$cat}->{STAGING}) eq "Y")
            {
                $catalogURL = "$LocalNUUrl/repo/$namespace/".$catalogs->{$cat}->{LOCALPATH};
                $catalogName = $catalogs->{$cat}->{NAME};
                if($aliasChange)
                {
                    $catalogName .= ":$namespace";
                }
            }
            
            $writer->startTag("param", 
                              "name" => "catalog",
                              "url"  => $catalogURL
                             );
            $writer->characters($catalogName);
            $writer->endTag("param");
        }
        $writer->endTag("service");
    }
    
    # and now the zypp and yum Repositories

    foreach my $cat (keys %{$catalogs})
    {
        next if(lc($catalogs->{$cat}->{CATALOGTYPE}) ne "zypp" && lc($catalogs->{$cat}->{CATALOGTYPE}) ne "yum");
        if(! exists $catalogs->{$cat}->{LOCALPATH} || ! defined $catalogs->{$cat}->{LOCALPATH} ||
           $catalogs->{$cat}->{LOCALPATH} eq "")
        {
            $log->error("Path for repository '$cat' does not exists. Skipping the repository.");
            next;
        }

        my $catalogURL = "$LocalNUUrl/repo/".$catalogs->{$cat}->{LOCALPATH};
        my $catalogName = $catalogs->{$cat}->{NAME};
        if($namespace ne "" && uc($catalogs->{$cat}->{STAGING}) eq "Y")
        {
            $catalogURL = "$LocalNUUrl/repo/$namespace/".$catalogs->{$cat}->{LOCALPATH};
            $catalogName = $catalogs->{$cat}->{NAME}.":$namespace";
        }
        #
        # this does not work
        # NCCcredentials are not known in SLE10 and not in RES
        #
        #$catalogURL .= "?credentials=NCCcredentials";
        
        $writer->startTag("service", 
                          "id"          => $catalogName,
                          "description" => $catalogs->{$cat}->{DESCRIPTION},
                          "type"        => $catalogs->{$cat}->{CATALOGTYPE});
        $writer->startTag("param", "id" => "url");
        $writer->characters($catalogURL);
        $writer->endTag("param");
        

        $writer->startTag("param", "name" => "catalog");
        $writer->characters($catalogName);
        $writer->endTag("param");

        $writer->endTag("service");
    }

    $writer->endTag("zmdconfig");

    return $output;
}

sub findColumnsForProducts
{
    my $r      = shift;
    my $dbh    = shift;
    my $parray = shift;
    my $column = shift;
    my $log = get_logger('apache.smt.registration');
    
    my @list = ();

    foreach my $phash (@{$parray})
    {
        my $statement = sprintf("SELECT %s, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER FROM Products where ", $dbh->quote_identifier($column));
        
        $statement .= "PRODUCTLOWER = ".$dbh->quote(lc($phash->{name}));
        
        $statement .= " AND (";
        $statement .= "VERSIONLOWER=".$dbh->quote(lc($phash->{version}))." OR " if(defined $phash->{version} && $phash->{version} ne "");
        $statement .= "VERSIONLOWER IS NULL)";
        
        $statement .= " AND (";
        $statement .= "RELLOWER=".$dbh->quote(lc($phash->{release}))." OR " if(defined $phash->{release} && $phash->{release} ne "");
        $statement .= "RELLOWER IS NULL)";
        
        $statement .= " AND (";
        $statement .= "ARCHLOWER=".$dbh->quote(lc($phash->{arch}))." OR " if(defined $phash->{arch} && $phash->{arch} ne "");
        $statement .= "ARCHLOWER IS NULL)";
        
        $log->debug( "STATEMENT: $statement");
        
        my $pl = $dbh->selectall_arrayref($statement, {Slice => {}});
        
        $log->trace("RESULT: ".Data::Dumper->Dump([$pl]));
        $log->trace("RESULT: not defined ") if(!defined $pl);
        $log->trace("RESULT: empty ") if(@$pl == 0);
        
        if(@$pl == 1)
        {
            # Only one match found. 
            push @list, $pl->[0]->{$column};
        }
        elsif(@$pl > 1)
        {
            my $found = 0;
            # Do we have an exact match?
            foreach my $prod (@$pl)
            {
                if(lc($prod->{VERSIONLOWER}) eq lc($phash->{version}) &&
                   lc($prod->{ARCHLOWER}) eq  lc($phash->{arch})&&
                   lc($prod->{RELLOWER}) eq lc($phash->{release}))
                {
                    # Exact match found.
                    push @list, $prod->{$column};
                    $found = 1;
                    last;
                }
            }
            if(!$found)
            {
                $log->warn("No exact match found: ".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch}." Choose the first one.");
                push @list, $pl->[0]->{$column};
            }
        }
        else
        {
            $log->error("No Product match found: ".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch});
            die "Product (".$phash->{name}." ".$phash->{version}." ".$phash->{release}." ".$phash->{arch}.") not found in the database.";
        }
    }
    return @list;
}


#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;
    my $log = get_logger('apache.smt.registration');
    
    my $bb = APR::Brigade->new($r->pool,
                               $r->connection->bucket_alloc);
    
    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);
        
        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }
            
            if ($b->read(my $buf)) {
                $data .= $buf;
            }
            
            $b->remove; # optimization to reuse memory
        }
        
    } while (!$seen_eos);
    
    $bb->destroy;
    
    $log->debug("Got content: $data");

    return $data;
}


###############################################################################
### XML::Parser Handler
###############################################################################


sub prod_handle_start_tag
{
    my $data = shift;
    my( $expat, $element, %attrs ) = @_;

    if(lc($element) eq "product")
    {
        $data->{STATE} = 1;
        foreach (keys %attrs)
        {
            $data->{CURRENT}->{lc($_)} = $attrs{$_};
        }
    }
}

sub prod_handle_char
{
    my $data = shift;
    my( $expat, $string) = @_;

    if($data->{STATE} == 1)
    {
        chomp($string);
        if(!exists $data->{CURRENT}->{name} || !defined $data->{CURRENT}->{name})
        {
            $data->{CURRENT}->{name} = $string;
        }
        else
        {
            $data->{CURRENT}->{name} .= $string;
        }
    }
}

sub prod_handle_end_tag
{
    my $data = shift;
    my( $expat, $element) = @_;

    if($data->{STATE} == 1)
    {
        push @{$data->{PRODUCTS}}, $data->{CURRENT};
        $data->{CURRENT} = undef;
        $data->{STATE} = 0;
    }
}

# sub unescapeParams
# {
#   my $data = shift;
#   return "" if(!defined $data || $data eq "");
#   
#   $data =~ s{&amp;}{&}gso;
#   $data =~ s{&quot;}{"}gso;
#   $data =~ s{&lt;}{<}gso;
#   $data =~ s{&gt;}{>}gso;
#   return $data;
# }

1;

