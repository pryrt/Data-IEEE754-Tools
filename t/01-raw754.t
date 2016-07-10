########################################################################
# Verifies the following functions:
#   :raw754
#       hexstr754_from_double()
#       binstr754_from_double()
#       hexstr754_to_double()
#       binstr754_to_double()
########################################################################
use 5.008005;
use warnings;
use strict;
use Test::More tests => 4+22*2;
use Data::IEEE754::Tools qw/:raw754/;

my ($src, $got, $expect_v, $expect_b, $expect_h);

$expect_b = '1011111111000100011110101110000101000111101011100001010001111011';
$expect_h = 'BFC47AE147AE147B';
$expect_v = -0.16;

$src = $expect_v;
$got = hexstr754_from_double($src);
cmp_ok( $got, 'eq', $expect_h, "hexstr754_from_double($src)" );

$src = $expect_h;
$got = hexstr754_to_double($src);
cmp_ok( $got, '==', $expect_v, "hexstr754_to_double($src)" );

$src = $expect_v;
$got = binstr754_from_double($src);
cmp_ok( $got, 'eq', $expect_b, "binstr754_from_double($src)" );

$src = $expect_b;
$got = binstr754_to_double($src);
cmp_ok( $got, '==', $expect_v, "binstr754_to_double($src)" );

# http://perlmonks.org/?node_id=984255
use constant {
    POS_ZERO        => '0'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    POS_DENORM_1ST  => '0'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    POS_DENORM_LST  => '0'.'00000000000'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    POS_NORM_1ST    => '0'.'00000000001'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    POS_NORM_LST    => '0'.'11111111110'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    POS_INF         => '0'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    POS_SNAN_1ST    => '0'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    POS_SNAN_LST    => '0'.'11111111111'.'0111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    POS_IND         => '0'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    POS_QNAN_1ST    => '0'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    POS_QNAN_LST    => '0'.'11111111111'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    NEG_ZERO        => '1'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    NEG_DENORM_1ST  => '1'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    NEG_DENORM_LST  => '1'.'00000000000'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    NEG_NORM_1ST    => '1'.'00000000001'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    NEG_NORM_LST    => '1'.'11111111110'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    NEG_INF         => '1'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    NEG_SNAN_1ST    => '1'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    NEG_SNAN_LST    => '1'.'11111111111'.'0111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
    NEG_IND         => '1'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000',
    NEG_QNAN_1ST    => '1'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001',
    NEG_QNAN_LST    => '1'.'11111111111'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111',
};
my %cmpmap;
foreach (
        POS_ZERO, POS_DENORM_1ST, POS_DENORM_LST, POS_NORM_1ST, POS_NORM_LST,
        POS_INF,
        POS_IND, POS_QNAN_1ST, POS_QNAN_LST,
        NEG_ZERO, NEG_DENORM_1ST, NEG_DENORM_LST, NEG_NORM_1ST, NEG_NORM_LST,
        NEG_INF,
        NEG_IND, NEG_QNAN_1ST, NEG_QNAN_LST
    )
{
    $cmpmap{$_} = $_;
}
foreach (
        POS_SNAN_1ST, POS_SNAN_LST,
        NEG_SNAN_1ST, NEG_SNAN_LST
    )
{
    $cmpmap{$_} = $_;
    substr $cmpmap{$_}, 12, 1, '.';       # ignore signal-vs-quiet bit: see http://perlmonks.org/?node_id=1166429 for in depth discussion: the short of it is, something in perl and/or compiler puts the SNAN thru a FP register, which quiets a SNAN.
}

# these subs force a little-endian universe
sub bitsToDouble{ unpack 'd',  pack 'b64', scalar reverse $_[0] }           # BrowserUK's conversion (http://perlmonks.org/?node_id=984255)
sub bitsToInts{   reverse unpack 'VV', pack 'b64', scalar reverse $_[0] }   # BrowserUK's conversion (http://perlmonks.org/?node_id=984255)
use constant DEBUG => 0;
if(DEBUG) {
    diag sprintf "%23.16g : %08x%08x\n", bitsToDouble( $_ ), bitsToInts( $_ ) for list;
}

foreach my $bits ( sort keys %cmpmap ) {
    $expect_v   = bitsToDouble( $bits );    # use BrowserUK's conversion to generated expected values

    $src        = $bits;
    $got        = binstr754_to_double($src);
    cmp_ok( $got, ( '1'x11 eq substr $bits, 1, 11 ) ? 'eq' : '==', $expect_v, "binstr754_to_double($bits)");

    $expect_b   = qr/$cmpmap{$bits}/;
    $src        = $expect_v;
    $got        = binstr754_from_double($src);
    like( $got, $expect_b, "binstr754_to_double($bits)");
}

exit;
