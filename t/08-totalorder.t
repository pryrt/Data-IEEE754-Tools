########################################################################
# Verifies the following functions:
#   :info
#       totalOrder(v)
#       totalOrderMag(v)
#   other functions from info in other test files
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :floatingpoint :constants :info/;

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

my $skip_reason = '';
if( isSignalingConvertedToQuiet() ) {
    $skip_reason = sprintf 'Signaling NaN are converted to QuietNaN by your perl: v%vd', $^V;
    eval { require 'Config' };
    $skip_reason .= " for $Config::Config{myuname}" unless ($@);
}

sub hQuiet($) {     # it's quiet if the exponent is 7FF or FFF and the first nibble is 0x8-0xF
    local $_ = shift;
    /^[7F]FF[89A-F]/i
}

sub hSignal($) {    # it's signaling if the exponent is 7FF/FFF, the first nibble is 0-7, and the whole significand isn't 0s (all 0s means +/-INF)
    local $_ = shift;
    /^[7F]FF[0-7]/i && !/^[7F]FF0000000000000/i
}

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

        SKIP: {
            skip $skip_reason, 2    if isSignalingConvertedToQuiet() && (
                # if Signalling converted to Quiet, order will be messed up if both are NaN but one each of signal and quiet
                (hQuiet($hx) && hSignal($hy)) ||    # x quiet && y signaling
                (hQuiet($hy) && hSignal($hx))       # y quiet && x signaling
            );
            # this will still compare either NaN to anything else (INF, NORM, SUB, ZERO), and will also compare
            # signaling to signaling and quiet to quiet

            my $got = totalOrder( $x, $y );
            my $exp = ($i <= $j) || 0;
            is( $got, $exp, sprintf('totalOrder   (%s,%s) = %s vs %s [i,j=$i,$j]', $hx, $hy, $got, $exp) );

            $got = totalOrderMag( $x, $y );
            $exp = ( ($i<11 ? 21-$i : $i) <= ($j<11 ? 21-$j : $j) ) || 0;
            is( $got, $exp, sprintf('totalOrderMag(%s,%s) = %s vs %s [i,j=$i,$j]', $hax, $hay, $got, $exp) );
        }
    }
}

exit;