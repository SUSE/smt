package SMT::RegistrationSharing;

use strict;
use warnings;

use Apache2::Log;
use Apache2::RequestRec ();
use Apache2::ServerUtil ();
use DBI qw(:sql_types);
use File::Slurp;
use File::Temp;
use File::Touch;
use SMT::Utils;
use WWW::Curl::Easy;
use XML::LibXML;

# A somewhat random number per thread avoid log and lock contention
my $anyNumber = int(rand(1000));

#
# called from handler in Registration module if registration is shared
# from another SMT server
# command=shareregistration argument given
sub addSharedRegistration
{
    my $r     = shift;
    my $hargs = shift;

    my $apache = Apache2::ServerUtil->server;
    my $acceptRequest = _verifySenderAllowed($r);
    if ($acceptRequest != 1) {
        return $acceptRequest;
    }
    # Process the registration request
    my $regData = SMT::Utils::read_post($r);
    my $regXML = _getXMLFromPostData($regData);
    if (! $regXML)
    {
        my $msg = "Received invalid data:\n$@\n";
        $apache->log_error($msg);
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);

    }
    my $dbh = SMT::Utils::db_connect();
    my @tableEntries = $regXML->getElementsByTagName('tableData');
    for my $entry (@tableEntries) {
        my $guid = _getGUIDfromTableEntry($entry);
        my $tableName = $entry->getAttribute('table');
        if ($tableName eq 'Clients' && SMT::Utils::lookupClientByGUID($dbh, $guid)) {
            $apache->log->info("Already have entry for '$guid' nothing to do for Clients record");
            next;
        }
        my $statement = _createInsertSQLfromXML($r, $dbh, $entry);
        if (! $statement) {
            $dbh->disconnect();
            my $msg = 'Could not generate SQL statement to insert '
                . 'registration';
            $r->log_error($msg);
            return SMT::Utils::http_fail($r, 400, $msg);
        }
        eval {
            $dbh->do($statement)
        };
        if ($@) {
            $dbh->disconnect();
            $r->log_error('Unable to insert registration into SMT database');
            my $msg = 'Registration insert failed:\n'
                . "STATEMENT: $statement\n"
                . "Error: $@";
            $apache->log_error($msg);
            return SMT::Utils::http_fail($r, 400, $msg);
        }
    }
    $dbh->disconnect();
    return;
}

#
# called from handler in Registration module if registration is shared
# from another SMT server
# command=deltesharedregistration argument given
sub deleteSharedRegistration
{
    my $r     = shift;
    my $hargs = shift;

    my $apache = Apache2::ServerUtil->server;
    my $acceptRequest = _verifySenderAllowed($r);
    if ($acceptRequest != 1) {
        return $acceptRequest;
    }
    # Process the delete request
    my $guidData = SMT::Utils::read_post($r);
    my $delXML = _getXMLFromPostData($guidData);
    if (! $delXML)
    {
        my $msg = "Received invalid data:\n$@\n";
        $apache->log_error($msg);
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);
    }
    my @guids = $delXML->getElementsByTagName('guid');
    # There is only one guid element in the XML
    my $guid = $guids[0]->textContent();
    if (! $guid)
    {
        my $msg = 'No GUID received for deletion';
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);
    }
    my $dbh = SMT::Utils::db_connect();
    my $found = 0;
    my $where = sprintf("GUID = %s", $dbh->quote( $guid ) );
    my $statement = "DELETE FROM Registration where ".$where;
    my $res = $dbh->do($statement);
    if ( $res > 0)
    {
        $found = 1;
    }
    $statement = "DELETE FROM Clients where ".$where;
    $res = $dbh->do($statement);
    $statement = "DELETE FROM MachineData where ".$where;
    $res = $dbh->do($statement);
    $dbh->disconnect();

    if(! $found)
    {
        $apache->log->info("No registration with $guid found.");
    }

    return;
}

#
# called from NCCRegTools::NCCDeleteRegistration if registration is shared
# with another SMT server
#
sub deleteSiblingRegistration
{
    my $regGUID = shift;
    my $logfile = shift;
    my $log = SMT::Utils::openLog($logfile);
    my $cfg;
    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        my $msg = 'Cannot read the SMT configuration file: '.$@;
        print $log $msg;
        return;
    }
    my $shareRegDataTargets = $cfg->val('LOCAL', 'shareRegistrations');
    if (! $shareRegDataTargets) {
        return 1;
    }
    my $guidXML = '<?xml version="1.0" encoding="UTF-8"?>'
        . '<deleteRegistrationData>'
        . '<guid>'
        . $regGUID
        . '</guid>'
        . '</deleteRegistrationData>';
    # SSL handling
    my $certPath = $cfg->val('LOCAL', 'siblingCertDir');
    # Send the registration data to the configured SMT siblings
    my @smtSiblings = split /,/, $shareRegDataTargets;
    for my $smtServer (@smtSiblings) {
        my $ua = SMT::Utils::createUserAgent();
        if ($certPath) {
            $ua->setopt(CURLOPT_CAPATH, $certPath);
        }
        my $url = "https://$smtServer/center/regsvc"
            . '?command=deltesharedregistration'
            . '&lang=en-US&version=1.0';
        my $response = $ua->post($url, Content=>$guidXML);
        if (! $response->is_success ) {
            my $msg = $response->message;
            my $details = $response->content;
            my $guidMsg = "Could not delete shared registration for $regGUID";
            my $responseMsg = "Response: $msg";
            my $detailsMsg = "Response: $details";
            print $log $guidMsg . "\n";
            print $log $responseMsg . "\n";
            print $log $detailsMsg . "\n";
        }
    }
    return;
}

#
# called from register in Registration module if registration is shared
# with another SMT server. The log argument is an indicator if the
# registration sharing is triggered from a command line tool.
#
sub shareRegistration
{
    my $regGUID = shift;
    my $log     = shift;
    my $dbh = SMT::Utils::db_connect();
    # Setup the registration data as an XML string
    my @tableData = ('Clients', 'Registration');
    my $regXML = '<?xml version="1.0" encoding="UTF-8"?>'
        . '<registrationData>';
    # Get the registration data
    for my $table (@tableData) {
        my $statement = sprintf("SELECT * from %s where GUID=%s",
                                $table,
                                $dbh->quote($regGUID));
        my $regDataArrayRef = $dbh->selectall_arrayref($statement, { Slice => {} });
        if (!@$regDataArrayRef) {
            next;
        }
        my $skip;
        if ($table eq 'Clients') {
            my @skipColumn = ('ID');
            $skip = \@skipColumn;
        }

        foreach my $regData (@$regDataArrayRef) {
            $regXML .= "<tableData table='$table'>"
                . _getXMLFromRowData($regData, $skip)
                . '</tableData>';
        }
    }
    $regXML .= '</registrationData>';
    $dbh->disconnect();
    _sendRegData($regXML, $log);
}

#
# Share a single product registration. In the SCC paradigm products/modules
# are registered one at a time and we do not know when the client considers
# registration to be complete. Thus we share every product as a registration
#
sub shareProductRegistration
{
    my $regGUID = shift;
    my $prodID = shift;
    my $apache = Apache2::ServerUtil->server;
    my $dbh = SMT::Utils::db_connect();
    my $regXML = '<?xml version="1.0" encoding="UTF-8"?>'
        . '<registrationData>';
    # Get the registration data
    my $statement = sprintf("SELECT * from Registration where GUID=%s and PRODUCTID=%s",
                            $dbh->quote($regGUID),
                            $dbh->quote($prodID));
    my $regData = $dbh->selectrow_hashref($statement);
    if (! $regData) {
        my $msg = "No product registration found for product '$prodID' and "
            . "ID '$regGUID'. This will create a data inconsistency on the "
            . 'sibling server';
        $apache->warn($msg);
        return;
    }
    # Look up the PRODUCTDATAID, which is provided by SCC and is always
    # consistent across all SMT servers. A quesry based on the PRODUCTDATAID
    # is used on the sibling server to get the PRODUCTID (a sequential
    # auto-increment ID) for the Registration table.
    # The logic is that on the sending server we use the PRODUCTID used for
    # registration to get the universal PRODUCTDATAID (aka the SCC product
    # id). On the sibling we then use that PRODUCTDATAID to look up the
    # PRODUCTID for the Registration table.
    $statement = sprintf("SELECT PRODUCTDATAID from Products where id=%s",
                         $dbh->quote($prodID));
    my $prodData = $dbh->selectcol_arrayref($statement);
    my $sccProdID = $prodData->[0];
    my $foreign_query =
        "SELECT ID from Products where PRODUCTDATAID=$sccProdID";
    my $foreignEntries = { 'PRODUCTID' => $foreign_query };
    $regXML .= "<tableData table='Registration'>"
            . _getXMLFromRowData($regData, undef, $foreignEntries)
            . '</tableData>';
    $regXML .= '</registrationData>';
    $dbh->disconnect();
    _sendRegData($regXML);
}

#
# Private
#
#
# Generate the SQL statement to insert the registration that is being shared
# into the DB
#
sub _createInsertSQLfromXML
{
    my $r       = shift;
    my $dbh     = shift;
    my $element = shift;

    my $tableName = $element->getAttribute('table');
    if (! $tableName) {
        $dbh->disconnect();
        my $msg = "Could not determine table name for insertion from XML\n";
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);
    }
    if ($tableName ne 'Clients' && $tableName ne 'Registration') {
        $dbh->disconnect();
        my $msg = "Attempting insert into table '$tableName' not permitted\n";
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);
    }

    my %hash;
    my @columns;

    for my $entry ($element->getElementsByTagName('entry')) {
        my $col = $entry->getAttribute('columnName');
        push(@columns, $col);
        $hash{$col} = $dbh->quote($entry->getAttribute('value'));
    }

    for my $entry ($element->getElementsByTagName('foreign_entry')) {
        my $col = $entry->getAttribute('columnName');
        push(@columns, $col);
        my $statement = $entry->getAttribute('value');
        my $values = $dbh->selectcol_arrayref($statement);
        $hash{$col} = $dbh->quote($values->[0]);
    }

    my $sql = sprintf(
        "INSERT INTO %s (%s) VALUES (%s) ON DUPLICATE KEY UPDATE %s",
        $tableName,
        join(", ", @columns),
        join(", ", map { $hash{$_} } @columns),
        join(", ", map { "$_ = $hash{$_}" } @columns)
    );

    return $sql;
}

#
# Get the Global ID for the given DB entry
#
sub _getGUIDfromTableEntry
{
    my $tableXML = shift;
    for my $entry ($tableXML->getElementsByTagName('entry')) {
        if ($entry->getAttribute('columnName') eq 'GUID') {
            return $entry->getAttribute('value');
        }
    }
    return;
}

#
# Process the received data and turn it into an XML object
#
sub _getXMLFromPostData
{
    my $postData = shift;
    my $xml;
    my $parser = XML::LibXML->new();
    $parser->expand_entities(0);
    $parser->load_ext_dtd(0);
    eval {
        # load_xml not available on SLES 11 SP3 due to version of
        # LibXML and underlying libxml2
        #$xm = XML::LibXML->load_xml(string => $postData);
        my $POSTDATAFL = File::Temp->new(SUFFIX=>'.txt');
        $POSTDATAFL->write($postData);
        $POSTDATAFL->flush();
        seek $POSTDATAFL, 0,0;
        $xml = $parser->parse_fh($POSTDATAFL);
    };

    if ($@) {
        return;
    }
    return $xml;
}

#
# Turn DB data into XML format
#
# rowData is expected to be a hashref returned by a selectrow_hashref db query
# skipEntries may be an array ref that will contain column names that should
#             not be considered for XML data generation
# foreignEntries is a hasref that contains column names as keys and a sql query
#                as the value for each key. The SQL query will be used to
#                substitute the value for the column on the sibling server.
#                The provided query must make sense for a selectcol_arrayref
sub _getXMLFromRowData
{
    my $rowData     = shift;
    my $skipEntries = shift;
    my $foreignEntries = shift;
    my %skip = map { ($_ => 1) } @{$skipEntries};
    my %data = %{$rowData};
    my @entries = keys %data;
    my $xml = '';
    for my $entry (@entries) {
        if ($skip{$entry}) {
            next;
        }
        if ($foreignEntries->{$entry}) {
            $xml .= "<foreign_entry columnName='$entry' value='"
                . $foreignEntries->{$entry}
                . "'/>";
            next;
        }
        if ($data{$entry}) {
            $xml .= "<entry columnName='$entry' value='"
                . $data{$entry}
                . "'/>";
        }
    }
    return $xml;
}

#
# log a record to be shared such that it can be replayed once the
# sibling server is back online
#
sub _logShareRecord{
    my $logFileName = shift;
    my $url         = shift;
    my $regXML      = shift;
    my $log         = shift;

    my $apache;
    if (! $log) {
        $apache = Apache2::ServerUtil->server;
    }

    if (! -d '/var/lib/wwwrun/smt') {
        my $status = mkdir '/var/lib/wwwrun/smt';
        if (! $status) {
            my $msg = 'Could not create "/var/lib/wwwrun/smt" to log failed '
                . 'shared registration record.';
            $apache->warn($msg);
            return;
        }
    }
    my $shareLog = "/var/lib/wwwrun/smt/$logFileName.$anyNumber.share.log";
    my $status = open my $LOGFILE, '>>', $shareLog;
    if (! $status) {
        my $msg = "Could not open log '$logFileName' for writing";
        if ($log) {
            print $log $msg;
        }
        else
        {
            $apache->warn($msg);
        }
        my $errMsg = 'Could not create record in any replay log '
            . 'file. The following must be added manually to the '
            . 'configured sibling servers:'
            . "\n$regXML";
        if ($log) {
            print $log $errMsg;
        }
        else
        {
            $apache->log_error($errMsg);
        }
        return;
    }
    print $LOGFILE "$url";
    print $LOGFILE '+++'; # Arbitrary separator used on playback
    print $LOGFILE "$regXML\n";
    close $LOGFILE;
    return 1;
}

#
# Send given data to the given url. The log argument is an indicator if the
# registration sharing is triggered from a command line tool.
#
sub _sendData{
    my $url  = shift;
    my $data = shift;
    my $log  = shift;

    my $apache;
    if (! $log) {
        $apache = Apache2::ServerUtil->server;
    }
    # Get the configuration
    my $cfg;
    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        my $msg = 'Cannot read the SMT configuration file: '.$@
            . "\nUnable to read cert data for ssl handling.";
        if ($log) {
            print $log $msg;
        } else {
            $apache->log_error($msg);
        }
        return;
    }

    my $certPath = $cfg->val('LOCAL', 'siblingCertDir');
    my $ua = SMT::Utils::createUserAgent();
    if ($certPath) {
        $ua->setopt(CURLOPT_CAPATH, $certPath);
    }

    return $ua->post($url, Content=>$data);
}

sub _sendRegData
{
    my $regXML = shift;
    my $log     = shift;
    my $apache;
    if (! $log) {
        $apache = Apache2::ServerUtil->server;
    }
        # Get the configuration
    my $cfg;
    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        my $msg = 'Cannot read the SMT configuration file: '.$@;
        if ($log) {
            print $log $msg;
        } else {
            $apache->log_error($msg);
        }
        return;
    }
    my $shareRegDataTargets = $cfg->val('LOCAL', 'shareRegistrations');
    if (! $shareRegDataTargets) {
        return 1;
    }

    # Send the registration data to the configured SMT siblings
    my @smtSiblings = split /,/, $shareRegDataTargets;
    for my $smtServer (@smtSiblings) {
        my $url = "https://$smtServer/center/regsvc"
            . '?command=shareregistration'
            . '&lang=en-US&version=1.0';
        my $response = _sendData($url, $regXML, $log);
        if (! $response ) {
            return;
        }
        if (! $response->is_success ) {
            my $msg = $response->message;
            my $details = $response->content;
            my $guidMsg = "Could not share registration for $regXML";
            my $responseMsg = "Response: $msg";
            my $detailsMsg = "Response: $details";
            if ($log) {
                print $log $guidMsg . "\n";
                print $log $responseMsg . "\n";
                print $log $detailsMsg . "\n";
            } else {
                $apache->warn($guidMsg);
                $apache->warn($responseMsg);
                $apache->warn($detailsMsg);
                _logShareRecord($smtServer,$url,$regXML,$log);
            }

        } else {
            _sharePreviousRegistrations($smtServer, $log);
        }
    }

    return;
}

#
# Share registrations that may have been logged due to a sibling server
# beeing unreachable at one time.  The log argument is an indicator if the
# registration sharing is triggered from a command line tool.
#
sub _sharePreviousRegistrations{
    my $logFileName = shift;
    my $log         = shift;

    if (! -d '/var/lib/wwwrun/smt') {
        return;
    }

    my @replayLogs = glob "/var/lib/wwwrun/smt/$logFileName.*.share.log";
    if (! scalar @replayLogs) {
        return;
    }

    my $lockFile = "/var/lib/wwwrun/smt/$logFileName.lock";
    if (-e $lockFile) {
        # Another thread is already processing the back log
        return;
    }
    touch($lockFile);
    my @undeliverdRecords;
    my $deliveryCount = 1;
    for my $replayLog (@replayLogs) {
        # Deliver 10 records to avoid lengthy wait times for the client
        # that happens to hit the server at the moment the sibling comes back
        # online
        if ($deliveryCount > 10) {
            last;
        }
        my @records = File::Slurp::read_file($replayLog);
        my $requestCnt = 0;
        for my $record (@records) {
            if ($deliveryCount <= 10) {
                (my $url, my $regXML) = split /\+\+\+/, $record;
                if ($url && $regXML) {
                    my $response = _sendData($url, $regXML, $log);
                    $requestCnt += 1;
                    # Deliver only 2 requests in short succession, then
                    # pause to not overwhelm the sibling server
                    if ($requestCnt == 2) {
                        sleep 1;
                        $requestCnt = 0;
                    }
                    if (! $response) {
                        unlink $lockFile;
                        return;
                    }
                    if (! $response->is_success ) {
                        push @undeliverdRecords, $record;
                    }
                }
                $deliveryCount += 1;
            }
            else
            {
                push @undeliverdRecords, $record;
            }
        }
        unlink $replayLog;
        if (@undeliverdRecords) {
            for my $record (@undeliverdRecords) {
                (my $url, my $regXML) = split /\+\+\+/, $record;
                if ($url && $regXML) {
                    _logShareRecord($logFileName,$url,$regXML);
                }
            }
        }
    }
    unlink $lockFile;
}

#
# Verify that it is OK to accept the request
#
sub _verifySenderAllowed
{
    my $r = shift;

    my $apache = Apache2::ServerUtil->server;
    my $senderName = $r->connection()->get_remote_host();
    my $senderIP = $r->connection()->client_ip();
    my $msg = 'Received shared registration request from '
        . $senderName
        . ':'
        . $senderIP;
    $apache->log->info($msg);

    # Verify that it is OK to accept the registration from this host
    my $cfg;
    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return SMT::Utils::http_fail($r, 500,
           "SMT server is missconfigured. Please contact your administrator.");
    }
    my $allowedSenders = $cfg->val('LOCAL', 'acceptRegistrationSharing');
    my %acceptedProviders;
    if ($allowedSenders) {
        %acceptedProviders = map { ($_ => 1) } split /,/, $allowedSenders;
    }

    if ((! $acceptedProviders{$senderName})
        && (! $acceptedProviders{$senderIP})) {
        $msg = "Registration data not accepted, host $senderIP, not listed "
            . 'as "acceptRegistrationSharing" provider in config file.';
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 403, $msg);
    }

    return 1;
}

1;
