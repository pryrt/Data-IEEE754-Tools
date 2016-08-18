########################################################################
# Verifies the following functions:
#   :signbit
#       copySign(v)
#   other functions from info in other test files
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :floatingpoint :constants :info :signbit/;

my @constants = (
    NEG_QNAN_LAST      ,
    NEG_QNAN_FIRST     ,
    NEG_IND            ,
    NEG_SNAN_LAST      ,
    NEG_SNAN_FIRST     ,
    NEG_INF            ,
    NEG_NORM_BIGGEST   ,
    NEG_NORM_SMALLEST  ,
    NEG_DENORM_BIGGEST ,
    NEG_DENORM_SMALLEST,
    NEG_ZERO           ,
    POS_ZERO           ,
    POS_DENORM_SMALLEST,
    POS_DENORM_BIGGEST ,
    POS_NORM_SMALLEST  ,
    POS_NORM_BIGGEST   ,
    POS_INF            ,
    POS_SNAN_FIRST     ,
    POS_SNAN_LAST      ,
    POS_IND            ,
    POS_QNAN_FIRST     ,
    POS_QNAN_LAST
);

plan tests => (scalar @constants)**2 * 2;

foreach my $x (@constants) {
    my $xsign = isSignMinus($x);
    foreach my $y (@constants) {
        my $ysign = isSignMinus($y);

        my $z = copySign($x, $y);
        my $zsign = isSignMinus($z);

        is( $zsign , $ysign , sprintf('copySign(%-24.24s,%-24.24s): sign compare', to_hex_floatingpoint($x), to_hex_floatingpoint($y)) );
        is( abs($z), abs($x), sprintf('copySign(%-24.24s,%-24.24s): abs compare',  to_hex_floatingpoint($x), to_hex_floatingpoint($y)) );
    }
}

exit;