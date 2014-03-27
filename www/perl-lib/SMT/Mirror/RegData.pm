package SMT::Mirror::RegData;
use strict;

use LWP::UserAgent;
use URI;
use SMT::Parser::RegData;
use XML::Writer;
use Crypt::SSLeay;
use SMT::Utils;
use File::Temp;

use Data::Dumper;

=head1 NAME

SMT::Mirror::RegData - Get data from Registration Server

=head1 SYNOPSIS

  use SMT::Mirror::RegData;

    my $rd= SMT::Mirror::RegData->new(element => "productdata",
                                      table   => "Products",
                                      key     => "PRODUCTDATAID");
    my $res = $rd->sync();

=head1 DESCRIPTION

Sync data from registration server

=head1 METHODS

=over 4

=item new([%params])

Create a new SMT::Mirror::RegData object:

  my $rd = SMT::Mirror::RegData->new();

Arguments are an anonymous hash array of parameters:

=over 4

=item vblevel <level>

Set the verbose level.

=item log

Logfile handle

=item element

Requested element name

=item table

Table name

=item key

Primary key of the table. If more then one column build the primary key, provide
a array reference.

=item fromdir

Data are in fromdir. Do not contact registration server to get the data.

=item todir

Write data into todir. Do not update the database.

=back

=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    $self->{URI}   = undef;
    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{MIGRATE} = 0;

    $self->{MAX_REDIRECTS} = 5;

    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";

    if (! defined $opt{fromdir} ) {
        $self->{SMTGUID} = SMT::Utils::getSMTGuid();
    }

    $self->{TEMPDIR} = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);

    $self->{ELEMENT} = "";
    $self->{TABLE}   = "";
    $self->{KEYNAME}     = [];

    $self->{XML}->{DATA}    = {};

    $self->{FROMDIR} = undef;
    $self->{TODIR}   = undef;

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{element} && defined $opt{element} && $opt{element} ne "")
    {
        $self->{ELEMENT} = $opt{element};
    }

    if(exists $opt{table} && defined $opt{table} && $opt{table} ne "")
    {
        $self->{TABLE} = $opt{table};
    }

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
	    $self->{FROMDIR} = $opt{fromdir};
    }
    elsif(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
	    $self->{TODIR} = $opt{todir};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    $self->{USERAGENT}  = SMT::Utils::createUserAgent(log => $self->{LOG}, vblevel => $self->{VBLEVEL});
    $self->{USERAGENT}->protocols_allowed( [ 'https'] );

    my ($ruri, $authuser, $authpass) = SMT::Utils::getLocalRegInfos();

    $self->{URI} = $ruri;
    #$self->{USERINFO} = $rguid.":".$rsecret;

    $self->{AUTHUSER} = $authuser;
    $self->{AUTHPASS} = $authpass;

    bless($self);

    if(exists $opt{key} && defined $opt{key})
    {
        $self->key($opt{key});
    }

    return $self;
}

=item vblevel([level])

Set or get the verbose level.

=cut

sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }
    return $self->{VBLEVEL};
}

=item migrate(1/0)

Enable or disable migration mode. The migration mode
convert NCC data existing in DB into SCC data.

=cut

sub migrate
{
    my $self = shift;
    if (@_) { $self->{MIGRATE} = shift }
    return $self->{MIGRATE};
}

=item element([name])

Set or get the element name

=cut
sub element
{
    my $self = shift;
    if (@_) { $self->{ELEMENT} = shift }

    return $self->{ELEMENT};
}

=item table([name])

Set or get the table name

=cut
sub table
{
    my $self = shift;
    if (@_) { $self->{TABLE} = shift }

    return $self->{TABLE};
}

=item key([$key|@key])

Set or get the key name(s).

=cut
sub key
{
    my $self = shift;
    if (@_)
    {
        my $data = shift;
        if(ref($data) eq "ARRAY")
        {
            $self->{KEYNAME} = $data;
        }
        elsif(ref($data) eq "")
        {
            $self->{KEYNAME} = [$data];
        }
    }
    return $self->{KEYNAME};
}


=item sync

Start the sync process

=cut
sub sync
{
    my $self = shift;
    my $xmlfile = "";

    if(defined $self->{FROMDIR} && -d $self->{FROMDIR})
    {
	    $xmlfile = $self->{FROMDIR}."/".$self->{ELEMENT}.".xml";
    }
    else
    {
    	$xmlfile = $self->_requestData();
    	if(!$xmlfile)
    	{
        	return 1;
    	}
    }

    if(defined $self->{TODIR})
    {
	    return 0;
    }
    else
    {
    	my $ret = $self->_parseXML($xmlfile);
        if($ret)
        {
            return $ret;
        }
        $ret = $self->_updateDB();
        delete $self->{XML}->{DATA}->{$self->{ELEMENT}};
        return $ret;
    }
}

=item canMigrate

Check, if SMT could be migrated back to NCC
Return:
0 if a migration is possible.
1 internal server error
2 migration not possible because clients exists with incompatible GUID
3 migration not possible because clients exists which uses products not provided by NCC
4 migration not possible because clients exists which uses repositories not provided by NCC

=cut
sub canMigrate
{
    my $self = shift;
    my $xmlfile = "";
    my $errors = 0;

    my $dbh = SMT::Utils::db_connect();
    if(!defined $dbh)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }

    #
    # registration with SUSEConnect cannot be migrated to NCC.
    # The UUID with SCC_ prefix is not accepted by NCC.
    #
    my $sql = "SELECT r.GUID
                 FROM Registration r
                WHERE r.GUID like 'SCC_%'";
    my $guids = $dbh->selectcol_arrayref($sql);

    if(exists $guids->[0])
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Found registrations with SUSEConnect which are not supported by NCC. Migration is not possible."));
        return 2;
    }

    my $element = $self->element();
    my $table = $self->table();
    my $key = $self->key();
    $self->element("productdata");
    $self->table("Products");
    $self->key("PRODUCTDATAID");

    if(defined $self->{FROMDIR} && -d $self->{FROMDIR})
    {
        $xmlfile = $self->{FROMDIR}."/".$self->{ELEMENT}.".xml";
    }
    else
    {
        $xmlfile = $self->_requestData();
        if(!$xmlfile)
        {
            $self->element($element);
            $self->table($table);
            $self->key($key);
            return 1;
        }
    }

    my $ret = $self->_parseXML($xmlfile);
    if($ret)
    {
        $self->element($element);
        $self->table($table);
        $self->key($key);
        return 1;
    }

    #
    # new registration server need to support all locally used
    # products. SCC will import all products of a product_class
    #
    $sql = "SELECT DISTINCT p.PRODUCT_CLASS
              FROM Products p, Registration r
             WHERE r.PRODUCTID=p.ID";
    my $classes = $dbh->selectall_arrayref($sql, {Slice => {}});

    foreach my $c (@{$classes})
    {
        my $found = 0;
        foreach my $product (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
        {
            $c->{PRODUCT_CLASS} = "" if(not $c->{PRODUCT_CLASS});
            if ( $c->{PRODUCT_CLASS} eq $product->{PRODUCT_CLASS} )
            {
                $found = 1;
                last;
            }
        }
        if ( ! $found )
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
                     sprintf("'%s' not found in registration server. Migration not possible.",
                             $c->{PRODUCT_CLASS}), 0, 1);
            $errors++;
        }
    }
    if ($errors)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Products found which are not supported by NCC. Migration is not possible."));
        $self->element($element);
        $self->table($table);
        $self->key($key);
        return 3;
    }
    delete $self->{XML}->{DATA}->{$self->{ELEMENT}};

    $self->element("catalogs");
    $self->table("Catalogs");
    $self->key("CATALOGID");

    if(defined $self->{FROMDIR} && -d $self->{FROMDIR})
    {
        $xmlfile = $self->{FROMDIR}."/".$self->{ELEMENT}.".xml";
    }
    else
    {
        $xmlfile = $self->_requestData();
        if(!$xmlfile)
        {
            $self->element($element);
            $self->table($table);
            $self->key($key);
            return 1;
        }
    }

    $ret = $self->_parseXML($xmlfile);
    if($ret)
    {
        $self->element($element);
        $self->table($table);
        $self->key($key);
        return 1;
    }

    #
    # All locally mirrored SCC repos need to be accessible via
    # the new registration server
    #
    $sql = "SELECT ID, NAME, TARGET FROM Catalogs
             WHERE DOMIRROR='Y'
               AND MIRRORABLE='Y'
               AND SRC = 'S'";
    my $catalogs = $dbh->selectall_hashref($sql, 'ID');
    foreach my $needed_cid (keys %{$catalogs})
    {
        my $found = 0;
        foreach my $repo (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
        {
            if ($catalogs->{$needed_cid}->{NAME} eq $repo->{NAME} &&
                $catalogs->{$needed_cid}->{TARGET} eq $repo->{TARGET})
            {
                $found = 1;
                last;
            }
        }
        if ( ! $found )
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
                     sprintf("Repository '%s-%s' not found in registration server. Migration not possible.",
                             $catalogs->{$needed_cid}->{NAME},
                             $catalogs->{$needed_cid}->{TARGET}
                     ), 0, 1);
            $errors++;
        }
    }
    if ($errors)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Used repositories found which are not supported by NCC. Migration is not possible."));
        $self->element($element);
        $self->table($table);
        $self->key($key);
        return 4;
    }
    delete $self->{XML}->{DATA}->{$self->{ELEMENT}};
    $self->element($element);
    $self->table($table);
    $self->key($key);
    return 0;
}


sub _requestData
{
    my $self    = shift;

    my $destdir = $self->{TEMPDIR};
    if(defined $self->{TODIR} && -d $self->{TODIR})
    {
         $destdir = $self->{TODIR};
    }

    my $uri = URI->new($self->{URI});
    $uri->query("command=regdata&lang=en-US&version=1.0");

    my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
             "client_version" => "1.2.3",
             "lang" => "en");

    my $content = "";
    my $writer = new XML::Writer(NEWLINES => 0, OUTPUT => \$content);
    $writer->xmlDecl();
    $writer->startTag($self->{ELEMENT}, %a);

    $writer->startTag("authuser");
    $writer->characters($self->{AUTHUSER});
    $writer->endTag("authuser");

    $writer->startTag("authpass");
    $writer->characters($self->{AUTHPASS});
    $writer->endTag("authpass");

    $writer->startTag("smtguid");
    $writer->characters($self->{SMTGUID});
    $writer->endTag("smtguid");

    $writer->endTag($self->{ELEMENT});

    my $response = "";
    my $redirects = 0;

    do
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Send to '$uri' content: $content") ;

        eval
        {
            $response = $self->{USERAGENT}->post( $uri->as_string(), 'Content-Type' => 'text/xml',
                                                  'Content' => $content,
                                                  ':content_file' => $destdir."/".$self->{ELEMENT}.".xml");
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf(__("Failed to POST '%s'"),
                                                    $uri->as_string()));
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, $@);
            return undef;
        }

        # enable this if you want to have a trace
        #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, Data::Dumper->Dump([$response]));

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Result: ".$response->code()." ".$response->message()) ;

        if ( $response->is_redirect )
        {
            $redirects++;
            if($redirects > $self->{MAX_REDIRECTS})
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Reach maximal redirects. Abort");
                return undef;
            }

            my $newuri = $response->header("location");

            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Redirected to $newuri") ;
            $uri = URI->new($newuri);
        }
    } while($response->is_redirect);

    if( $response->is_success && -e $destdir."/".$self->{ELEMENT}.".xml")
    {
        if($self->vblevel() & LOG_DEBUG)
        {
            open(CONT, "< $destdir/".$self->{ELEMENT}.".xml") and do
            {
                my @c = <CONT>;
                close CONT;
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Content:".join("\n", @c));
            };
        }

        return $destdir."/".$self->{ELEMENT}.".xml";
    }
    else
    {
        # FIXME: was 'die'; check if we should stop if a download failed
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Failed to POST '".$uri->as_string()."': ".$response->status_line);
        return undef;
    }
}

sub _parseXML
{
    my $self    = shift;
    my $xmlfile = shift;

    if(! -e $xmlfile)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File '$xmlfile' does not exist.");
        return 1;
    }
    my $dbh = SMT::Utils::db_connect();

    my $parser = SMT::Parser::RegData->new();
    my $err = $parser->parse($xmlfile, sub { ncc_handler($self, $dbh, @_); });

    return $err;
}

sub ncc_handler
{
    my $self = shift;
    my $dbh  = shift;
    my $data = shift;

    my $root = $data->{MAINELEMENT};
    delete $data->{MAINELEMENT};

    if(lc($root) eq "productdata")
    {
        $data->{PRODUCTLOWER} = undef;
        $data->{VERSIONLOWER} = undef;
        $data->{RELLOWER}     = undef;
        $data->{ARCHLOWER}    = undef;

        if(exists $data->{RELEASE} && defined $data->{RELEASE})
        {
            # fix RELEASE => REL
            $data->{REL} = $data->{RELEASE};
            delete $data->{RELEASE};
        }

        if(exists $data->{PARAM} && defined $data->{PARAM})
        {
            # fix PARAM => PARAMLIST
            $data->{PARAMLIST} = $data->{PARAM};
            delete $data->{PARAM};
        }


        $data->{PRODUCTLOWER} = lc($data->{PRODUCT}) if(exists $data->{PRODUCT} && defined $data->{PRODUCT});
        $data->{VERSIONLOWER} = lc($data->{VERSION}) if(exists $data->{VERSION} && defined $data->{VERSION});
        $data->{RELLOWER}     = lc($data->{REL}) if(exists $data->{REL} && defined $data->{REL});
        $data->{ARCHLOWER}    = lc($data->{ARCH}) if(exists $data->{ARCH} && defined $data->{ARCH});
    }
    elsif(lc($root) eq "productcatalogs")
    {
        # we now use the ID columns tso we need to translate first
        if(exists $data->{PRODUCTDATAID} && $data->{PRODUCTDATAID})
        {
            $data->{PRODUCTID} = SMT::Utils::lookupProductIdByDataId($dbh, $data->{PRODUCTDATAID});
            delete $data->{PRODUCTDATAID};
        }
        if(exists $data->{CATALOGID} && $data->{CATALOGID})
        {
            $data->{CATALOGID} = SMT::Utils::lookupCatalogIdByDataId($dbh, $data->{CATALOGID});
        }
        if (!($data->{PRODUCTID} && $data->{CATALOGID}))
        {
            # one value is undef, so skip the data set
            return;
        }
    }

    push @{$self->{XML}->{DATA}->{$root}}, $data;
}



sub _updateDB
{
    my $self  = shift;

    my $table = $self->{TABLE};
    my $key   = $self->{KEYNAME};

    if(!defined $table || $table eq "")
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid table name");
        return 1;
    }
    if(!defined $key || ref($key) ne "ARRAY")
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid key element.");
        return 1;
    }

    if(! exists $self->{XML}->{DATA}->{$self->{ELEMENT}})
    {
        # data not available; no need to update the database
        printLog($self->{LOG}, $self->vblevel(), LOG_WARN, "No $self->{ELEMENT} returned.");
        return 0;
    }

    my $dbh = SMT::Utils::db_connect();
    if(!defined $dbh)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }

    my @q_key = ();
    foreach my $k (@$key)
    {
        push @q_key, $dbh->quote_identifier($k);
    }

    # get all datasets which are from NCC
    my $stm = sprintf("SELECT %s FROM %s WHERE SRC='N'", join(',', @q_key),  $dbh->quote_identifier($table));
    if ($self->migrate)
    {
        $stm = sprintf("SELECT %s FROM %s WHERE SRC='S'", join(',', @q_key),  $dbh->quote_identifier($table));
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $stm") ;

    my $alln = $dbh->selectall_arrayref($stm, {Slice=>{}});

    my $allhash = {};

    foreach my $sv (@{$alln})
    {
        my $str = "";
        my $j=0;
        foreach my $k (@$key)
        {
            $str .= "=-=" if($j > 0);
            $str .= $sv->{$k};
            $j++;
        }
        $allhash->{$str} = 1;
    }

    foreach my $row (@{$self->{XML}->{DATA}->{$self->{ELEMENT}}})
    {
        my @primkeys_where = ();
        my $str = "";
        my $j=0;
        foreach (@$key)
        {
            if ($row->{$_})
            {
                push @primkeys_where, $dbh->quote_identifier($_)."=".$dbh->quote($row->{$_});
            }
            else
            {
                push @primkeys_where, $dbh->quote_identifier($_)." is NULL";
            }
            $str .= '=-=' if($j > 0);
            $str .= $row->{$_};
            $j++;
        }

        delete $allhash->{$str} if(exists $allhash->{$str});

        # does the key exists in the db?
        my $st = sprintf("SELECT %s FROM %s WHERE %s",
                         join(',', @q_key), $dbh->quote_identifier($table), join(' AND ', @primkeys_where));
        #if ($self->migrate())
        #{
            # migrate from SCC to NCC so lets search for SCC entries
        #    $st .= " AND SRC = 'S'";
        #}
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $st") ;

        my $all = $dbh->selectall_arrayref($st);

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, Data::Dumper->Dump([$all]))  ;

        # special handling for catalogs table
        # LOCALPATH is required
        if(lc($table) eq "catalogs")
        {
            if(lc($row->{CATALOGTYPE}) eq "nu" || lc($row->{CATALOGTYPE}) eq "yum")
            {
                $row->{LOCALPATH} = '$RCE/'.$row->{NAME}."/".$row->{TARGET};
            }
            else
            {
                # we need to check if this is ATI or NVidia SP1 repos and have to rename it

                if($row->{NAME} eq "ATI-Drivers" && $row->{EXTURL} =~ /sle10sp1/)
                {
                    $row->{NAME} = $row->{NAME}."-SP1";
                }
                elsif($row->{NAME} eq "nVidia-Drivers" && $row->{EXTURL} =~ /sle10sp1/)
                {
                    $row->{NAME} = $row->{NAME}."-SP1";
                }

                $row->{LOCALPATH} = 'RPMMD/'.$row->{NAME};
            }
        }


        # PRIMARY KEY exists in DB, do update
        if(@$all == 1)
        {
            my $statement = sprintf("UPDATE %s SET SRC='N', ", $dbh->quote_identifier($table));
            my @pairs = ();
            foreach my $cn (keys %$row)
            {
                next if( grep( ($_ eq $cn), @$key ) );

                if(!defined $row->{$cn} || lc($row->{$cn}) eq "null")
                {
                    push @pairs, $dbh->quote_identifier($cn)." = NULL";
                }
                else
                {
                    push @pairs, $dbh->quote_identifier($cn)." = ".$dbh->quote($row->{$cn});
                }
            }

            # if all columns of a table are part of the primary key
            # no update is needed. We found this with the select above.
            # This row is up-to-date.
            next if(@pairs == 0);

            $statement .= join(', ', @pairs);

            $statement .= " WHERE ".join(' AND ', @primkeys_where);

            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement") ;

            eval
            {
                $dbh->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            }
        }
        # PRIMARY KEY does not exists in DB, do insert
        elsif(@$all == 0)
        {
            my $statement = sprintf("INSERT INTO %s (", $dbh->quote_identifier($table));
            my @k = ();
            my @v = ();
            foreach my $cn (keys %$row)
            {
                push @k, $dbh->quote_identifier($cn);
                if(!defined $row->{$cn} || lc($row->{$cn}) eq "null")
                {
                    push @v, "NULL";
                }
                else
                {
                    push @v, $dbh->quote($row->{$cn});
                }
            }

            $statement .= join(',', @k);
            $statement .= ") VALUES (";
            $statement .= join(',', @v);
            $statement .= ")";

            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement") ;

            eval
            {
                $dbh->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            }
        }
        else
        {
            # more then one element by selecting the keyvalue - evil
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "ERROR: invalid key value '$key'");
        }
    }

    #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "ALLHASH END: ".Data::Dumper->Dump([$allhash]));

    # delete all which where not touched but from NCC and no custom value
    foreach my $set (keys %{$allhash})
    {
        my @primkeys_where = ();
        if(@$key > 1)
        {
            my @vals = split(/=-=/, $set);

            for(my $j=0; $j < @vals; $j++)
            {
                if ($vals[$j])
                {
                    push @primkeys_where, $dbh->quote_identifier($key->[$j])." = ".$dbh->quote($vals[$j]);
                }
                else
                {
                    push @primkeys_where, $dbh->quote_identifier($key->[$j])." is NULL";
                }
            }
        }
        elsif(@$key == 1)
        {
            # primary key == NULL should not happen :-)
            push @primkeys_where, $dbh->quote_identifier($key->[0])." = ".$dbh->quote($set);
        }

        my $delstr = sprintf("DELETE from %s where %s", $dbh->quote_identifier($table), join(' AND ', @primkeys_where));

        my $res = $dbh->do($delstr);

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $delstr Result: $res") ;
    }

    $dbh->disconnect;
    return 0;
}

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2007-2012 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;
