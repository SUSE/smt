package SMT::Parser::RpmMdRepomd;
use strict;
use URI;
use XML::Simple;
use SMT::Utils;
use IO::Zlib;

use Data::Dumper;


=head1 NAME

SMT::Parser::RpmMdRepomd - parsers rpm-md repomd.xml file

=head1 SYNOPSIS

  $parser = SMT::Parser::RpmMdRepomd->new();
  $parser->resource('/path/to/repository/directory/');
  $result = $parser->parse("repodata/repomd.xml");

=head1 DESCRIPTION

Parses repomd.xml of a rpm-md repository and return the result as
a data structure

=head1 METHODS

=over 4

=item new()

Create a new SMT::Parser::RpmMdRepomd object:

=over 4

=item parse

Parse the file and return the content as structure:

{
  'xmlns' => 'http://linux.duke.edu/metadata/repo',
  'revision' => '1396006659',
  'xmlns:rpm' => 'http://linux.duke.edu/metadata/rpm',
  'data' => {
            'filelists' => {
                           'checksum' => {
                                         'content' => '22d67474a1fbb897352c725b7d8b5056ea6c1707bca020240d8221c0157033bc',
                                         'type' => 'sha256'
                                       },
                           'location' => {
                                         'href' => 'repodata/22d67474a1fbb897352c725b7d8b5056ea6c1707bca020240d8221c0157033bc-filelists.xml.gz'
                                       },
                           'timestamp' => '1396006659',
                           'open-size' => '4503',
                           'open-checksum' => {
                                              'content' => 'dd8b976b39341785b3c134c3a0d08f61134c8d7df1fcd3badc9739553b0b0925',
                                              'type' => 'sha256'
                                            },
                           'size' => '906'
                         },
            'other' => {
                       'checksum' => {
                                     'content' => '19c0e73957413e8b22d905dc0d1bac758903de38d7cf9674231659f36a5b8643',
                                     'type' => 'sha256'
                                   },
                       'location' => {
                                     'href' => 'repodata/19c0e73957413e8b22d905dc0d1bac758903de38d7cf9674231659f36a5b8643-other.xml.gz'
                                   },
                       'timestamp' => '1396006659',
                       'open-size' => '8242',
                       'open-checksum' => {
                                          'content' => '050cef566d2df7c13ac3b34d08d71fd05e30153f31c4d1b8541aee75d1f9da6b',
                                          'type' => 'sha256'
                                        },
                       'size' => '1720'
                     },
            'updateinfo' => {
                            'checksum' => {
                                          'content' => '8a4ef27db46855d2134a5bf37585f4e4e04977b54dcbce4b6db20e8cc5602e60',
                                          'type' => 'sha256'
                                        },
                            'location' => {
                                          'href' => 'repodata/8a4ef27db46855d2134a5bf37585f4e4e04977b54dcbce4b6db20e8cc5602e60-updateinfo.xml.gz'
                                        },
                            'timestamp' => '1396006660',
                            'open-checksum' => {
                                               'content' => '746f22c7a8b433016ef6beaed1ce929092c31b43edf238e3b844e4a47a6cbe69',
                                               'type' => 'sha256'
                                             },
                            'size' => '609'
                          },
            'primary' => {
                         'checksum' => {
                                       'content' => '580d5470dde9319847b2d98cc400e5cae78d770d306aed094eea407734e4bb98',
                                       'type' => 'sha256'
                                     },
                         'location' => {
                                       'href' => 'repodata/580d5470dde9319847b2d98cc400e5cae78d770d306aed094eea407734e4bb98-primary.xml.gz'
                                     },
                         'timestamp' => '1396006659',
                         'open-size' => '8397',
                         'open-checksum' => {
                                            'content' => 'fe364420254d9856bd3438f1f0775963afd2f18ef994dd6f982b61066330d1a7',
                                            'type' => 'sha256'
                                          },
                         'size' => '1870'
                       },
            'deltainfo' => {
                           'checksum' => {
                                         'content' => 'ebf2123e1621223331c7737c164e3eeffa51c6842fe53e80fdc1d4852607acb4',
                                         'type' => 'sha256'
                                       },
                           'location' => {
                                         'href' => 'repodata/ebf2123e1621223331c7737c164e3eeffa51c6842fe53e80fdc1d4852607acb4-deltainfo.xml.gz'
                                       },
                           'timestamp' => '1396006660',
                           'open-checksum' => {
                                              'content' => 'a0b87484348d92150fb3260c13b9dfd324913350f5bda1186a47ffc6ae4cdc2b',
                                              'type' => 'sha256'
                                            },
                           'size' => '271'
                         },
            'susedata' => {
                          'checksum' => {
                                        'content' => 'b51d883b71668e384cfacd0d3a0231ab9e32ff3278f728ffd062275864dada97',
                                        'type' => 'sha256'
                                      },
                          'location' => {
                                        'href' => 'repodata/b51d883b71668e384cfacd0d3a0231ab9e32ff3278f728ffd062275864dada97-susedata.xml.gz'
                                      },
                          'timestamp' => '1396006661',
                          'open-checksum' => {
                                             'content' => '626875d43483a1cdb4835ee7e077ea2682afa9a38bf2259e7768c140a506dc9b',
                                             'type' => 'sha256'
                                           },
                          'size' => '295'
                        },
            'suseinfo' => {
                          'checksum' => {
                                        'content' => '5afc6cb78c11733eb7ae0cd9dfefc5a37fba3d6530ec285484cf419be9bc7e84',
                                        'type' => 'sha256'
                                      },
                          'location' => {
                                        'href' => 'repodata/5afc6cb78c11733eb7ae0cd9dfefc5a37fba3d6530ec285484cf419be9bc7e84-suseinfo.xml.gz'
                                      },
                          'timestamp' => '1396006660',
                          'open-checksum' => {
                                             'content' => 'f3848374e7d385d6d3eb88e927be074b6d2edb5579751e6717e4ece4ea3be5e3',
                                             'type' => 'sha256'
                                           },
                          'size' => '102'
                        }
          }
};

=back

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;
    my $self  = {};

    $self->{CURRENT}   = undef;
    $self->{STORE}     = [];
    $self->{RESULT}    = {};
    $self->{RESOURCE}  = undef;
    $self->{LOG}    = 0;
    $self->{VBLEVEL}   = 0;
    $self->{ERRORS}   = 0;

    if(exists $opt{log} && defined $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    bless($self);
    return $self;
}

sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }
    return $self->{VBLEVEL};
}

sub resource
{
    my $self = shift;
    if (@_) { $self->{RESOURCE} = shift }
    return $self->{RESOURCE};
}

# parses a xml resource
sub parse
{
    my $self     = shift;
    my $repodata = shift;

    my $path     = undef;

    if(!defined $self->{RESOURCE})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Invalid resource");
        return undef;
    }

    $path = $self->{RESOURCE}."/$repodata";

    # for security reason strip all | characters.
    # XML::Parser ->parsefile( $path ) might be problematic
    $path =~ s/\|//g;
    if(!-e $path)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "File not found $path");
        return undef;
    }

    # if we need these data sometimes later then we have to find
    # a new solution. But this save us 80% time.
    return undef if($repodata =~ /other\.xml[\.gz]*$/);
    return undef if($repodata =~ /filelists\.xml[\.gz]*$/);
    return undef if($repodata =~ /updateinfo\.xml[\.gz]*$/);
    return undef if($repodata =~ /susedata\.xml[\.gz]*$/);

    my $parser;

    $parser = XML::Simple->new();

    if ( $path =~ /(.+)\.gz/ )
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdRepomd '$path' must not be compressed");
        return undef;
    }
    eval {
        $self->{RESULT} = $parser->XMLin( $path, KeyAttr => {data => 'type'} );
    };
    if($@) {
        # ignore the errors, but print them
        chomp($@);
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "SMT::Parser::RpmMdLocation Invalid XML in '$path': $@");
        return undef;
    }
    return $self->{RESULT};
}
1;
