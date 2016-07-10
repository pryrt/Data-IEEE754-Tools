########################################################################
# Verifies load is okay
# Also verifies that system uses 64bit NV:
#   if it's not an IEEE 64bit double, all bets are off
########################################################################
use 5.008005;
use strict;
use warnings;
use Test::More tests => 2;
use Config;

BEGIN {
    use_ok( 'Data::IEEE754::Tools' ) or diag "Couldn't even load Data::IEEE754::Tools";
}

is( $Config{nvsize} , 8 , "Perl NV uses 64bit double" )
    or diag(
        sprintf "Sorry, your system uses a native floating-point with %d bits;\nData::IEEE754::Tools requires %d bits",
            $Config{nvsize}*8, 64
    );
