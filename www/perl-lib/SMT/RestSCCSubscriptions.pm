package SMT::RestSCCSubscriptions;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);
use constant IOBUFSIZE => 8192;
use Apache2::Filter ();

use APR::Brigade;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Access ();

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED NOT_FOUND FORBIDDEN AUTH_REQUIRED MODE_READBYTES HTTP_NOT_ACCEPTABLE :log);
use Apache2::RequestUtil;

use JSON;

use SMT::Utils;
use DBI qw(:sql_types);
use Data::Dumper;

sub _storeMachineData($$$$)
{
    my $r = shift || return;
    my $dbh = shift || return;
    my $guid = shift || return;
    my $c = shift || return;

    #
    # insert product info into MachineData
    #
    my $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME = %s",
                           $dbh->quote($guid),
                           $dbh->quote("machinedata"));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                        $dbh->quote($guid),
                        $dbh->quote("machinedata"),
                        $dbh->quote(encode_json($c)));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
}

#
# announce a system. This call create a system object in the DB
# and return system username and password to the client.
# all params are optional.
#
# QUESTION: no chance to check duplicate clients?
#           Every client should call this only once?
#
sub announce($$$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $c   = shift || return undef;
    my $result = {};
    my $hostname = "";
    my $target = "";
    my $namespace = "";

    if ( exists $c->{hostname} && $c->{hostname})
    {
        $hostname = $c->{hostname};
    }
    else
    {
        $hostname = $r->connection()->remote_host();
    }
    if (! $hostname)
    {
        $hostname = $r->connection()->remote_ip();
    }

    if ( exists $c->{distro_target} && $c->{distro_target})
    {
        $target = $c->{distro_target};
    }
    else{
        # in future we may fail here
        ;
    }

    if ( exists $c->{namespace} && $c->{namespace})
    {
        $namespace = $c->{namespace};
    }

    my $guid = `/usr/bin/uuidgen 2>/dev/null`;
    if (!$guid)
    {
        return undef;
    }
    chomp($guid);
    $guid =~ s/-//g;  # remove the -
    $result->{login} = "SCC_$guid"; # SUSEConnect always add this prefix
    my $secret = `/usr/bin/uuidgen 2>/dev/null`;
    if (!$secret)
    {
        return undef;
    }
    chomp($secret);
    $secret =~ s/-//g;  # remove the -
    $result->{password} = $secret;

    my $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET, NAMESPACE, SECRET, REGTYPE)
                             VALUES (%s, %s, %s, %s, %s, 'SC')",
                             $dbh->quote($result->{login}),
                             $dbh->quote($hostname),
                             $dbh->quote($target),
                             $dbh->quote($namespace),
                             $dbh->quote($result->{password}));
    $r->log->info("STATEMENT: $statement");
    eval
    {
        $dbh->do($statement);
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    _storeMachineData($r, $dbh, $result->{login}, $c);

    return $result;
}

#
# the handler for requests to the jobs ressource
#
sub subscriptions_handler($$$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $apiVersion = shift || return undef;
    my $path = sub_path($r);

    # map the requests to the functions
    if    ( $r->method() =~ /^GET$/i )
    {
        $r->log->error("GET request to the jobs interface. This is not supported.");
        return undef;
    }
    elsif ( $r->method() =~ /^POST$/i )
    {
        if ( $path =~ /^subscriptions\/systems/ )
        {
            $r->log->info("GET connect/subscriptions/systems (announce)");
            my $c = JSON::decode_json(read_post($r));
            return announce($r, $dbh, $c);
        }
        else { return undef; }
    }
    elsif ( $r->method() =~ /^PUT$/i )
    {
        # This request type is not (yet) supported
        # POSTing to the "jobs" interface (which is only used by smt-clients) means "creating a job"
        # It may be implemented later for the "clients" interface (which is for administrator usage).
        $r->log->error("PUT request to the jobs interface. This is not supported.");
        return undef;
    }
    elsif ( $r->method() =~ /^DELETE$/i )
    {
        # This request type is not (yet) supported
        # DELETEing to the "jobs" interface (which is only used by smt-clients) means "deleting a job"
        # It may be implemented later for the "clients" interface (which is for administrator usage).
        $r->log->error("DELETE request to the jobs interface. This is not supported.");
        return undef;
    }
    else
    {
        $r->log->error("Unknown request to the jobs interface.");
        return undef;
    }

    return undef;
}


#
# Apache Handler
# this is the main function of this request handler
#
sub handler {
    my $r = shift;
    my $path = sub_path($r);
    my $res = undef;

    my $apiVersion = SMT::Utils::requestedAPIVersion($r);
    if (not $apiVersion)
    {
        return respond_with_error($r, Apache2::Const::HTTP_NOT_ACCEPTABLE, "API version not supported") ;
    }

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) )
    {
        $r->log->error("RESTService could not connect to database.");
        return Apache2::Const::SERVER_ERROR;
    }

    if ( $path =~ qr{^subscriptions?}    ) {  $res = subscriptions_handler($r, $dbh, $apiVersion); }

    if (not defined $res)
    {
        $r->log->info("NOT FOUND");
        # errors are logged in each handler
        # returning undef from a handler is allowed, this will result in a 404 response, just as if no handler was defined for the request
        return Apache2::Const::NOT_FOUND;
    }
    else
    {
        $r->content_type('application/json');
        $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
        $r->err_headers_out->add('Pragma' => "no-cache");

        print encode_json($res);
    }

    # return a 200 response
    return Apache2::Const::OK;
}


#
# get the proper sub-path info part
#  cropps the prefix of the path: "/connect/"
#
sub sub_path($)
{
    my $r = shift || return '';

    # get the path_info
    my $path = $r->path_info();
    # crop the prefix: '/'connect rest service identifier
    $path =~ s/^\/connect\/+//;
    # crop the trailing slash
    $path =~ s/\/?$//;
    # crop the beginning slash
    $path =~ s/^\/?//;

    return $path;
}


#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;

    my $bb = APR::Brigade->new($r->pool, $r->connection->bucket_alloc);

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

            if ($b->read(my $buf)) { $data .= $buf; }
            $b->remove; # optimization to reuse memory
        }
    } while (!$seen_eos);

    $bb->destroy;
    $r->log->info("Got content: $data");
    return $data;
}

1;

=head1 NAME

SMT::RESTService - REST service documentation

=head1 DESCRIPTION

To access the REST interface all URLs start with /=/1/ path.

=head1 Jobs Interface

=over 4

=item GET /jobs

Returns a list of all jobs

=item GET /jobs/@next

Return the next job

=item GET /jobs/<ID>

Return job information of the specified ID

=item PUT /jobs/<ID>

Finish job with the given ID

=back

=head1 Clients Interface

=over 4

=item GET /clients

Return a list of all clients

 <clients>
   <client id="1" description="" guid="bb75d9deb4724a0c937f018a45f2bf34"
           hostname="www" lastcontact="2010-04-15 17:18:03" namespace=""
           patchstatus_date="" patchstatus_o="" patchstatus_p=""
           patchstatus_r="" patchstatus_s="" target="sle-11-x86_64"/>
   <client id="1" .... />
 </clients>

=item GET /clients/<GUID>

Return client information of this GUID

   <client id="1" description="" guid="bb75d9deb4724a0c937f018a45f2bf34"
           hostname="www" lastcontact="2010-04-15 17:18:03" namespace=""
           patchstatus_date="" patchstatus_o="" patchstatus_p=""
           patchstatus_r="" patchstatus_s="" target="sle-11-x86_64"/>
   <client id="1" .... />

=item GET /clients/@all/jobs

Return a list of jobs of all clients

 <jobs>
   <job id="71" type="patchstatus" name="Patchstatus Job"
        description="Patchstatus Job for Client 4b4608ddc16e4b3fa1271df903056b3a"
        status="0" created="2011-07-25 12:19:42" upstream="0"
        cacheresult="0" verbose="0" timelag="23:00:00" persistent="1">
     <arguments/>
   </job>
   <job id="42" guid="123" type="patchstatus" name="Patchstatus Job"
        description="Patchstatus Job for Client 123" status="0" exitcode="0"
        created="2010-07-12 17:20:27" targeted="2012-02-03 11:36:02"
        retrieved="2012-02-02 12:36:01" finished="2012-02-02 12:36:02"
        upstream="0" cacheresult="0" verbose="0" timelag="23:00:00"
        message="0:0:0:0 # PackageManager=0 Security=0 Recommended=0
        Optional=0" persistent="1">
     <stdout>
       <![CDATA[ ]]>
     </stdout>
     <stderr>
       <![CDATA[ ]]>
     </stderr>
     <arguments/>
   </job>
   ...
 </jobs>

=item GET /clients/<GUID>/jobs

Return a list of jobs for the client specified by GUID

 <jobs>
   <job id="42" guid="123" type="patchstatus" name="Patchstatus Job"
        description="Patchstatus Job for Client 123" status="0" exitcode="0"
        created="2010-07-12 17:20:27" targeted="2012-02-03 11:36:02"
        retrieved="2012-02-02 12:36:01" finished="2012-02-02 12:36:02"
        upstream="0" cacheresult="0" verbose="0" timelag="23:00:00"
        message="0:0:0:0 # PackageManager=0 Security=0 Recommended=0
        Optional=0" persistent="1">
     <stdout>
       <![CDATA[ ]]>
     </stdout>
     <stderr>
       <![CDATA[ ]]>
     </stderr>
     <arguments/>
   </job>
   ...
 </jobs>

=item GET /clients/<GUID>/jobs/@next

Return the next job of the client specified by GUID.

=item GET /clients/<GUID>/jobs/<ID>

Return job information of a specific client and a specific job

=item GET /clients/@all/patchstatus

Return the patchstatus of all clients

 <clients>
   <client id="1" guid="f9c48ef7ae0c4ed39294f96715d36b50" patchstatus_date=""
           patchstatus_o="" patchstatus_p="" patchstatus_r="" patchstatus_s=""/>
   <client id=2" ... />
 </clients>

=item GET /clients/<GUID>/patchstatus

Return the patchstatus of the client specified by GUID

 <client id="1" guid="f9c48ef7ae0c4ed39294f96715d36b50" patchstatus_date=""
         patchstatus_o="" patchstatus_p="" patchstatus_r="" patchstatus_s=""/>

=back

=head1 Products Interface

=over 4

=item GET /products

Return a list of all products

 <products>
   <product name="SUSE_SLES" arch="x86_64" class="7261" id="3009" rel=""
            serverclass="OS" uiname="SUSE Linux Enterprise Server 11 SP2"
            version="11.2"/>
   <product name="SUSE_SLES" arch="i586" class="7261" id="3006" rel=""
            serverclass="OS" uiname="SUSE Linux Enterprise Server 11 SP2"
            version="11.2"/>
   ...
 </products>

=item GET /products/<ID>

Return the product specified by ID

 <product name="SUSE_SLES" arch="x86_64" class="7261" id="3009" rel=""
          serverclass="OS" uiname="SUSE Linux Enterprise Server 11 SP2"
          version="11.2"/>

=item GET /products/<ID>/repos

Return repositories of a specific product id

 <repos>
   <repo name="SLES11-SP1-Updates" id="1094" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-WebYaST-SP2-Pool" id="1218" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP1-Debuginfo-Pool" id="1396" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLE11-WebYaST-SP2-Updates" id="984" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Core" id="1032" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-Extras" id="998" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP1-Pool" id="1053" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP2-Debuginfo-Updates" id="1269" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Extension-Store" id="1401" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Updates" id="1296" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP1-Debuginfo-Updates" id="845" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP2-Debuginfo-Core" id="934" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
 </repos>

=back

=head1 Repository Interface

=over 4

=item GET /repos

Return a list of all repositories

 <repos>
   <repo name="SLES11-SP1-Updates" id="1094" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-WebYaST-SP2-Pool" id="1218" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP1-Debuginfo-Pool" id="1396" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLE11-WebYaST-SP2-Updates" id="984" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Core" id="1032" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-Extras" id="998" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP1-Pool" id="1053" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP2-Debuginfo-Updates" id="1269" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Extension-Store" id="1401" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLES11-SP2-Updates" id="1296" mirrored="" optional="N"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP1-Debuginfo-Updates" id="845" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   <repo name="SLE11-SP2-Debuginfo-Core" id="934" mirrored="" optional="Y"
         target="sle-11-x86_64"/>
   ...
 </repos>


=item GET /repos/<ID>

Return the repository specified by ID

 <repo name="SLE11-SP2-Debuginfo-Core" id="934" target="sle-11-x86_64"
       type="nu">
   <description>SLE11-SP2-Debuginfo-Core for sle-11-x86_64</description>
   <localpath>
     /space/mirror/repo/$RCE/SLE11-SP2-Debuginfo-Core/sle-11-x86_64
   </localpath>
   <mirrored date=""/>
   <url>
     https://nu.novell.com/repo/$RCE/SLE11-SP2-Debuginfo-Core/sle-11-x86_64/
   </url>
 </repo>

=item GET /repos/<ID>/patches

Return a list of patches in the repository specified with ID

 <patches>
   <patch name="slessp1-sle-apparmor-quick_en-pdf" category="recommended"
          id="4591" version="3885"/>
   <patch name="slessp1-apache2-mod_php5" category="recommended"
          id="4842" version="3264"/>
   <patch name="slessp1-at" category="recommended" id="4513"
          version="4571"/>
   ...
 </patches>

=back

=head1 Patches Interface

=over 4

=item GET /patches/<ID>

Return information about a specific patch defined by ID

 <patch name="slessp1-sle-apparmor-quick_en-pdf" category="recommended" id="4591" version="3885">
   <description>
     This update provides the latest corrections and addtions to the SLES Manuals. In addition, it provides a new chapter about KVM.
   </description>
   <issued date="1296214440"/>
   <packages>
     <package name="sles-admin_en-pdf" arch="noarch" epoch="" release="16.25.1" version="11.1">
       <origlocation>
         https://nu.novell.com/repo/$RCE/SLES11-SP1-Updates/sle-11-x86_64/rpm/noarch/sles-admin_en-pdf-11.1-16.25.1.noarch.rpm
       </origlocation>
       <smtlocation>
         https://smt.example.com/repo/$RCE/SLES11-SP1-Updates/sle-11-x86_64/rpm/noarch/sles-admin_en-pdf-11.1-16.25.1.noarch.rpm
       </smtlocation>
     </package>
     <package>
     ...
   </package>
   <references>
     <reference id="664232" href="https://bugzilla.novell.com/show_bug.cgi?id=664232" title="bug number 664232" type="bugzilla"/>
   </references>
   <title>
     Recommended update for SLES Manual Update and KVM User Guide
   </title>
 </patch>

=back

=head1 AUTHOR

mc@suse.de, jdsn@suse.de

=head1 COPYRIGHT

Copyright 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut
