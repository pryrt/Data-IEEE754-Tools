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

plan skip_all => 'tests to be developed';

#### originally t\08; need to convert to copySign functionality
plan tests => (scalar @constants)**2 * 2;

sub habs($) {
    my $h = shift;
    my $s = substr $h, 0, 1;
    $s = sprintf '%1.1X', (hex($s)&0x7);        # mask OUT sign bit
    substr $h, 0, 1, $s;
    return $h;
}
foreach my $i (0 .. $#constants) {
    my $x = $constants[$i];
    my $hx = hexstr754_from_double($x);
    my $hax = habs($hx);
    my $ax = hexstr754_to_double($hax);
    foreach my $j (0 .. $#constants) {
        my $y = $constants[$j];
        my $hy = hexstr754_from_double($y);
        my $hay = habs($hy);
        my $ay = hexstr754_to_double($hay);
        local $, = ", ";
        local $\ = "\n";
        my $got = totalOrder( $x, $y );
        my $exp = ($i <= $j) || 0;
        is( $got, $exp, sprintf('totalOrder   (%s,%s) = %s vs %s', $hx, $hy, $got, $exp) );

        $got = totalOrderMag( $x, $y );
        $exp = ( ($i<11 ? 21-$i : $i) <= ($j<11 ? 21-$j : $j) ) || 0;
        is( $got, $exp, sprintf('totalOrderMag(%s,%s) = %s vs %s', $hax, $hay, $got, $exp) );
    }
}

exit;