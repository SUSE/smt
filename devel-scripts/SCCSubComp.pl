#! /usr/bin/perl 

use strict;
use XML::Writer;
use SMT::NCCRegTools;
use SMT::Mirror::RegData;
use SMT::Utils;
#use Date::Parse;
use POSIX qw(strftime);
use Data::Dumper;

use SMT::SCCAPI;

my $self = {
  'AUTHUSER' => $ARGV[0] || 'UC7',
  'AUTHPASS' => $ARGV[1] || 'a48210ea39',
  'SMTGUID'  => '5100dfd0f6bf4fc9a672bb670ef07dd3',
  'SUBSCRIPTIONS' => {},
  'NCCPRDID2NAME' => {},
  'SCCPRDID2NAME' => {}
};
my $SCCURL = $ARGV[2] || 'https://scc.suse.com/connect';

print "SCCSubComp.pl [<mirrorcred username> <mirrorcred password> [SCC URL]]\n";
print "Using: ".$self->{AUTHUSER}." with SCC: ".$SCCURL."\n";

my $vblevel  = LOG_ERROR|LOG_WARN|LOG_INFO1;
#$vblevel = LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2|LOG_DEBUG|LOG_DEBUG2;
my $LOG = SMT::Utils::openLog("/tmp/SCCComp.log");



my $rd= SMT::Mirror::RegData->new(vblevel => $vblevel,
                                  log     => $LOG,
                                  element => "productdata",
                                  table   => "Products",
                                  key     => "PRODUCTDATAID");

$rd->{URI} = "https://secure-www.novell.com/center/regsvc/";
$rd->{AUTHUSER} = $self->{AUTHUSER};
$rd->{AUTHPASS} = $self->{AUTHPASS};

print "requesting NCC product data\n";
my $xmlfile = $rd->_requestData();
my $ret = $rd->_parseXML($xmlfile);
foreach my $prddata (@{$rd->{XML}->{DATA}->{productdata}})
{
    $self->{NCCPRDID2NAME}->{$prddata->{PRODUCTDATAID}} = sprintf("%s-%s-%s.%s",
        $prddata->{PRODUCTLOWER},
        $prddata->{VERSIONLOWER},
        $prddata->{RELLOWER},
        $prddata->{ARCHLOWER});
#    print "ADD:".$prddata->{PRODUCTDATAID}." = ".$self->{NCCPRDID2NAME}->{$prddata->{PRODUCTDATAID}}."\n";
}

my $output = "";
my %a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
         "lang" => "en",
         "client_version" => "1.2.3");

my $writer = new XML::Writer(OUTPUT => \$output);
$writer->xmlDecl("UTF-8");
$writer->startTag("listregistrations", %a);

$writer->startTag("authuser");
$writer->characters($self->{AUTHUSER});
$writer->endTag("authuser");

$writer->startTag("authpass");
$writer->characters($self->{AUTHPASS});
$writer->endTag("authpass");

$writer->startTag("smtguid");
$writer->characters($self->{SMTGUID});
$writer->endTag("smtguid");

$writer->endTag("listregistrations");

my $lr= SMT::NCCRegTools->new(vblevel => $vblevel,
                              log     => $LOG);

print "requesting NCC registration data\n";
$lr->{URI} = "https://secure-www.novell.com/center/regsvc/";

my $destreg = "/tmp/listregistrations.xml";
my $ok = $lr->_sendData($output, "command=listregistrations", $destreg);

$output = "";
%a = ("xmlns" => "http://www.novell.com/xml/center/regsvc-1_0",
      "lang" => "en",
      "client_version" => "1.2.3", "includeall" => "yes");

$writer = new XML::Writer(OUTPUT => \$output);
$writer->xmlDecl("UTF-8");
$writer->startTag("listsubscriptions", %a);

$writer->startTag("authuser");
$writer->characters($self->{AUTHUSER});
$writer->endTag("authuser");

$writer->startTag("authpass");
$writer->characters($self->{AUTHPASS});
$writer->endTag("authpass");

$writer->startTag("smtguid");
$writer->characters($self->{SMTGUID});
$writer->endTag("smtguid");

$writer->endTag("listsubscriptions");

print "requesting NCC subscription data\n";

my $destsub = "/tmp/listsubscriptions.xml";
$ok = $lr->_sendData($output, "command=listsubscriptions", $destsub);

my $parser = new SMT::Parser::ListSubscriptions(log => $self->{LOG});
my $err = $parser->parse($destsub, sub{ _listsub_myhandler($self, @_)});

$parser = new SMT::Parser::ListReg(log => $self->{LOG});
$err = $parser->parse($destreg, sub{ _listreg_myhandler($self, @_)});

sub _listsub_myhandler
{
    my $self     = shift;
    my $data     = shift;

    # Filter out subscriptions not managed by SCC
    foreach my $unsup (('18962','ZLM7','OES2','SLM','NAM-AGA','NAM-APP','MONO', 'Moblin-2.1-MSI', 'DSMP', 'XACCESS', '20082'))
    {
        if ($data->{PRODUCTCLASS} =~ /$unsup/)
        {
            #print "skip $unsup\n";
            return;
        }
    }                     

    #print "timestamp: ".$data->{STARTDATE}." == ".strftime("%FT%T.000Z", gmtime($data->{STARTDATE}))."\n";

    my $sub = {
      'starts_at' => (($data->{STARTDATE} > 0)?strftime("%FT%T.000Z", gmtime($data->{STARTDATE})):""),
      'regcode'   => $data->{REGCODE},
      'virtual_count' => undef,
      'product_ids' => [],
      'status' => $data->{STATUS},
      'expires_at' => (($data->{ENDDATE} > 0)?strftime("%FT%T.000Z", gmtime($data->{ENDDATE})):""),
      'name' => $data->{NAME},
      'systems_count' => $data->{CONSUMED},
      'system_limit' => $data->{NODECOUNT},
      'product_classes' => [split(/,/, $data->{PRODUCTCLASS})],
      'type' => lc($data->{TYPE}),
      'systems' => [],
      'id' => $data->{SUBID}
    };

    my @productids = ();
    foreach my $pdid (split(/,/, $data->{PRODUCTLIST}))
    {
        push @productids, $self->{NCCPRDID2NAME}->{$pdid};
    }
    $sub->{product_ids} = [sort(@productids)];

    $self->{SUBSCRIPTIONS}->{$data->{SUBID}} = $sub;
    return;
}

sub _listreg_myhandler
{
    my $self     = shift;
    my $data     = shift;

    my $guid = $data->{GUID};
    foreach my $subid (@{$data->{SUBREF}})
    {
        if (exists $self->{SUBSCRIPTION}->{$subid})
        {
            push @{$self->{SUBSCRIPTION}->{$subid}->{systems}}, $guid;
        }
    }
}

my $NCCoutname = "/tmp/".$self->{AUTHUSER}."_NCCsubscriptions.json";
print "Writing NCC output to $NCCoutname\n";

my $outarr = [sort({$a->{regcode} cmp $b->{regcode}} values %{$self->{SUBSCRIPTIONS}})];

#print Data::Dumper->Dump([$outarr])."\n";

open(NCCOUT, "> $NCCoutname") or die "Cannot open $NCCoutname: $!";

print NCCOUT "[\n";
foreach my $subscription (@{$outarr})
{
    print NCCOUT "  {\n";
    foreach my $key (('regcode','starts_at','expires_at','status','type','system_limit','systems_count','name'))
    {
        print NCCOUT sprintf("    \"%s\":\"%s\",\n", $key, $subscription->{$key});
    }
    print NCCOUT "    \"product_ids\": [\n";


    foreach my $prd (@{$subscription->{product_ids}})
    {
        print NCCOUT "      \"$prd\",\n";
    }
    print NCCOUT "    ],\n";
    print NCCOUT "    \"product_classes\": [\n";

    foreach my $class (@{$subscription->{product_classes}})
    {
        print NCCOUT "      \"$class\",\n";
    }
    print NCCOUT "    ]\n";
    print NCCOUT "  },\n";
}
print NCCOUT "]\n";


##############################################################################################################
########### SCC 
##############################################################################################################

print "requesting SCC product data\n";
my $api = SMT::SCCAPI->new(vblevel => $vblevel,
                           log     => $LOG,
                           url => $SCCURL,
                           #url => 'https://krummelmonster.scc.suse.de/connect',
                           authuser => $self->{AUTHUSER},
                           authpass => $self->{AUTHPASS},
                           ident => $self->{SMTGUID}
                          );
my $sccprds = $api->org_products();
foreach my $product (@$sccprds)
{
    $self->{SCCPRDID2NAME}->{$product->{id}} = sprintf("%s-%s-%s.%s",
        lc($product->{identifier}),
        lc($product->{version}),
        lc($product->{release_type}),
        lc($product->{arch}));
#    print "ADD:".$product->{id}." = ".$self->{SCCPRDID2NAME}->{$product->{id}}."\n";
}

print "requesting SCC subscription data\n";
my $subs = $api->org_subscriptions();

my $SCCoutname = "/tmp/".$self->{AUTHUSER}."_SCCsubscriptions.json";
print "Writing SCC output to $SCCoutname\n";
$outarr = [sort({$a->{regcode} cmp $b->{regcode}} @{$subs})];

open(NCCOUT, "> $SCCoutname") or die "Cannot open $SCCoutname: $!";

print NCCOUT "[\n";
foreach my $subscription (@{$outarr})
{
    print NCCOUT "  {\n";
    foreach my $key (('regcode','starts_at','expires_at','status','type','system_limit','systems_count','name'))
    {
        print NCCOUT sprintf("    \"%s\":\"%s\",\n", $key, $subscription->{$key});
    }

    my @productids = ();
    foreach my $pdid (@{$subscription->{product_ids}})
    {
        push @productids, $self->{SCCPRDID2NAME}->{$pdid};
    }
    $subscription->{product_ids} = [sort(@productids)];


    print NCCOUT "    \"product_ids\": [\n";
    foreach my $prd (@{$subscription->{product_ids}})
    {
        print NCCOUT "      \"$prd\",\n";
    }
    print NCCOUT "    ],\n";
    print NCCOUT "    \"product_classes\": [\n";

    $subscription->{product_classes} = [sort(@{$subscription->{product_classes}})];
    foreach my $class (@{$subscription->{product_classes}})
    {
        print NCCOUT "      \"$class\",\n";
    }
    print NCCOUT "    ]\n";
    print NCCOUT "  },\n";
}
print NCCOUT "]\n";



