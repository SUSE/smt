package YEP::Registration;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK SERVER_ERROR :log);
use APR::Const    -compile => qw(:error SUCCESS);

use YEP::Utils;

use Data::Dumper;
use DBI;
#use HTML::Entities;
use XML::Writer;
use XML::Parser;
use XML::Bare;

sub handler {
    my $r = shift;
    
    $r->content_type('text/xml');

    my $args = $r->args();
    my $hargs = {};
    
    foreach my $a (split(/\&/, $args))
    {
        chomp($a);
        my ($key, $value) = split(/=/, $a, 2);
        $hargs->{$key} = $value;
    }
    $r->warn("Registration called with args: ".Data::Dumper->Dump([$hargs]));
    
    if(exists $hargs->{command} && defined $hargs->{command})
    {
        if($hargs->{command} eq "register")
        {
            YEP::Registration::register($r, $hargs);
        }
        elsif($hargs->{command} eq "listproducts")
        {
            YEP::Registration::listproducts($r, $hargs);
        }
        elsif($hargs->{command} eq "listparams")
        {
            YEP::Registration::listparams($r, $hargs);
        }
        else
        {
            $r->log_error("Unknown command: $hargs->{command}");
            return Apache2::Const::SERVER_ERROR;
        }
    }
    else
    {
        $r->log_error("Missing command");
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
    my $r     = shift;
    my $hargs = shift;

    $r->warn("register called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));

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

    $r->warn("listproducts called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    my $dbh = YEP::Utils::db_connect();
    
    my $sth = $dbh->prepare("SELECT DISTINCT PRODUCT FROM Products where product_list = 'Y'");
    $sth->execute();

    my $writer = new XML::Writer(NEWLINES => 1);
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

    $r->warn("listparams called: ".Data::Dumper->Dump([$r]).",".Data::Dumper->Dump([$hargs]));
    
    my $data = YEP::Utils::read_post($r);
    
    my $products = YEP::Registration::parseListparams($r, $data);
    
    my $dbh = YEP::Utils::db_connect();

    my @paramlist = ();
    foreach my $product (keys %{$products})
    {
        foreach my $cnt (1..3)
        {
            my $statement = "SELECT PARAMLIST FROM Products where ";

            $statement .= "PRODUCTLOWER = ".$dbh->quote(lc($product))." AND ";

            $statement .= "VERSIONLOWER ";

            if(!defined $products->{$product}->{version})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($products->{$product}->{version}))." AND ";
            }
            
            $statement .= "ARCHLOWER ";
            
            if(!defined $products->{$product}->{arch})
            {
                $statement .= "IS NULL AND ";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($products->{$product}->{arch}))." AND ";
            }
            
            $statement .= "RELEASELOWER ";

            if(!defined $products->{$product}->{release})
            {
                $statement .= "IS NULL";
            }
            else
            {
                $statement .= "= ".$dbh->quote(lc($products->{$product}->{release}));
            }
                        
            #$r->log_error("STATEMENT: $statement");
            
            my $pl = $dbh->selectall_arrayref($statement, {Slice => {}});
            
            #$r->log_error("RESULT: ".Data::Dumper->Dump([$pl]));
            #$r->log_error("RESULT: not defined ") if(!defined $pl);
            #$r->log_error("RESULT: empty ") if(@$pl == 0);

            if(@$pl == 0 && $cnt == 1)
            {
                $products->{$product}->{release} = undef;
            }
            elsif(@$pl == 0 && $cnt == 2)
            {
                $products->{$product}->{arch} = undef;
            }
            elsif(@$pl == 0 && $cnt == 3)
            {
                $products->{$product}->{version} = undef;
            }
            elsif(@$pl == 1 && exists $pl->[0]->{PARAMLIST})
            {
                push @paramlist, $pl->[0]->{PARAMLIST};
                last;
            }
        }
    }
    
    my $xml = YEP::Registration::joinParamlist($r, \@paramlist);

    #$r->log_error("XML: $xml");

    print $xml;

    return;
}

sub parseListparams
{
    my $r     = shift;
    my $xml   = shift;
    my $data  = {STATE => 0, PRODUCTS => {}};
    
    my $parser = XML::Parser->new( Handlers =>
                                   { Start=> sub { lp_handle_start_tag($data, @_) },
                                     Char => sub { lp_handle_char($data, @_) },
                                     End=>\&lp_handle_end_tag,
                                   });
    $parser->parse( $xml );
    return $data->{PRODUCTS};
}

sub lp_handle_start_tag
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

sub lp_handle_char
{
    my $data = shift;
    my( $expat, $string) = @_;

    if($data->{STATE} == 1)
    {
        chomp($string);
        foreach (keys %{$data->{CURRENT}})
        {
            $data->{PRODUCTS}->{$string}->{$_} = $data->{CURRENT}->{$_};
        }
        delete $data->{CURRENT};
        $data->{STATE} = 0;
    }
}

sub lp_handle_end_tag
{
    my( $expat, $element, %attrs ) = @_;
}


sub joinParamlist
{
    my $r         = shift;
    my $paramlist = shift;
    
    if(@$paramlist == 1)
    {
        return $paramlist->[0];
    }
    
    my $basedoc = shift @$paramlist;
    
    my $parser = new XML::Bare( text => $basedoc );
    my $root   = $parser->parse( );

    foreach my $other (@$paramlist)
    {
        my $po = new XML::Bare( text => $other );
        my $do = $po->parse( );
        
        foreach my $node (keys %{$do->{paramlist}})
        {
            if($node ne "param" && exists $root->{paramlist}->{$node})
            {
                next;
            }
            elsif($node ne "param" && !exists $root->{paramlist}->{$node})
            {
                # FIXME: is not save to do it this way
                $root->{paramlist}->{$node} = $do->{paramlist}->{$node};
                next;
            }
            # now we have the param node
            
            foreach my $par (@{$do->{paramlist}->{param}})
            {
                if(!$parser->find_node($root->{paramlist}, "param", id => $par->{id}->{value}))
                {
                    #$r->log_error("PARAMNODE: id $par->{id}->{value} does not exist. Add it");

                    # FIXME: is not save to do it this way
                    push @{$root->{paramlist}->{param}}, $par;
                }
            }
        }
    }
    return $parser->xml( $root );
}




1;

