########################################################################
# Verifies load is okay
########################################################################
use 5.008005;
use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok( 'Data::IEEE754::Tools' ) || print "Bail out!\n";
}

#diag( "DIAG: Testing Data::IEEE754::Tools $Data::IEEE754::Tools::VERSION, Perl $], $^X" );
