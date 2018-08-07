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
    my $guid = _getGUIDfromTableEntry($tableEntries[0]);
    if (SMT::Utils::lookupClientByGUID($dbh, $guid)) {
        $dbh->disconnect();
        $apache->log->info("Already have entry for '$guid' nothing to do");
        return;
    }
    for my $entry (@tableEntries) {
        $guid = _getGUIDfromTableEntry($entry);
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
        my $regData = $dbh->selectrow_hashref($statement);
        if (! $regData) {
            next;
        }
        my $skip;
        if ($table eq 'Clients') {
            my @skipColumn = ('ID');
            $skip = \@skipColumn;
        }
        $regXML .= "<tableData table='$table'>"
            . _getXMLFromRowData($regData, $skip)
            . '</tableData>';
    }
    $regXML .= '</registrationData>';

    # Send the registration data to the configured SMT siblings
    if ( $regXML =~ /GUID/) {
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
                my $guidMsg = "Could not share registration for $regGUID";
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
                    _logShareRecord($smtServer,$url,$regXML);
                }

            } else {
                _sharePreviousRegistrations($smtServer, $log);
            }
        }
    }
    $dbh->disconnect();
    return;
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
    my $apache = Apache2::ServerUtil->server;
    my $tableName = $element->getAttribute('table');
    if (! $tableName) {
        $dbh->disconnect();
        my $msg = "Could not determine table name for insertion from XML\n";
        $r->log_error($msg);
        return SMT::Utils::http_fail($r, 400, $msg);
    }
    my $sql = "INSERT into $tableName (";
    my $vals = 'VALUES (';
    for my $entry ($element->getElementsByTagName('entry')) {
        $sql .= $entry->getAttribute('comulmnName')
            . ', ';
        my $val = $dbh->quote($entry->getAttribute('value'));
        $vals .= "$val"
            . ', ';
    }
    chop $sql; # remove trailing space
    chop $sql; # remove trailing comma
    chop $vals; # remove trailing space
    chop $vals; # remove trailing comma

    $sql .= ') ' . $vals . ')';

    return $sql;
}

#
# Get the Global ID for the given DB entry
#
sub _getGUIDfromTableEntry
{
    my $tableXML = shift;
    for my $entry ($tableXML->getElementsByTagName('entry')) {
        if ($entry->getAttribute('comulmnName') eq 'GUID') {
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
sub _getXMLFromRowData
{
    my $rowData     = shift;
    my $skipEntries = shift;
    my %skip = map { ($_ => 1) } @{$skipEntries};
    my %data = %{$rowData};
    my @entries = keys %data;
    my $xml = '';
    for my $entry (@entries) {
        if ($skip{$entry}) {
            next;
        }
        if ($data{$entry}) {
            $xml .= "<entry comulmnName='$entry' value='"
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
    my $apache = Apache2::ServerUtil->server;

    if (! -d '/var/lib/wwwrun/smt') {
        my $status = mkdir '/var/lib/wwwrun/smt';
        if (! $status) {
            my $msg = 'Could not create "/var/lib/wwwrun/smt" to log failed '
                . 'shared registration record.';
            $apache->warn($msg);
            return;
        }
    }
    my $log = "/var/lib/wwwrun/smt/$logFileName";
    my $lockFile = $log . '.lock';
    while (-e $lockFile) {
        sleep 1;
    }
    touch($lockFile);
    my $status = open my $LOGFILE, '>>', $log;
    if (! $status) {
        my $msg = "Could not open log '$logFileName' for writing";
        $apache->warn($msg);
        my $errMsg = 'Could not create record in replay file. '
            . 'The following must be added manually to the '
            . 'configured sibling servers:'
            . "\n$regXML";
        $apache->error($errMsg);
        unlink $lockFile;
        return;
    }
    print $LOGFILE "$url";
    print $LOGFILE '+++'; # Arbitrary separator used on playback
    print $LOGFILE "$regXML\n";
    close $LOGFILE;
    unlink $lockFile;
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

    my $replayLog = "/var/lib/wwwrun/smt/$logFileName";
    if (! -e $replayLog) {
        return;
    }

    if ($log) {
        unlink $replayLog;
        return;
    }

    my $lockFile = $replayLog . '.lock';
    while (-e $lockFile) {
        sleep 1;
    }
    touch($lockFile);

    my @undeliverdRecords;
    my @records = File::Slurp::read_file($replayLog);
    for my $record (@records) {
        (my $url, my $regXML) = split /\+\+\+/, $record;
        my $response = _sendData($url, $regXML, $log);
        if (! $response) {
            return;
        }
        if (! $response->is_success ) {
            push @undeliverdRecords, $record;
        }
    }
    unlink $lockFile;
    unlink $replayLog;
    if (@undeliverdRecords) {
        for my $record (@undeliverdRecords) {
            (my $url, my $regXML) = split /\+\+\+/, $record;
            _logShareRecord($logFileName,$url,$regXML);
        }
    }
}

#
# Verify that it is OK to accept the request
#
sub _verifySenderAllowed
{
    my $r = shift;

    my $apache = Apache2::ServerUtil->server;
    my $senderName = $r->hostname();
    my $senderIP = $r->connection()->remote_ip();
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
