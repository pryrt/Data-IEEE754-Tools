########################################################################
# Verifies the following functions:
#   :raw754
#       hexstr754_from_double()
#       binstr754_from_double()
#       hexstr754_to_double()
#       binstr754_to_double()
########################################################################
use 5.006;
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
cmp_ok( sprintf('%+24.16e',$got), 'eq', sprintf('%+24.16e',$expect_v), "hexstr754_to_double($src)" );  # v0.011_002: failed for $got == $expect_v when Config{nvsize}>8

$src = $expect_v;
$got = binstr754_from_double($src);
cmp_ok( $got, 'eq', $expect_b, "binstr754_from_double($src)" );

$src = $expect_b;
$got = binstr754_to_double($src);
cmp_ok( sprintf('%+24.16e',$got), 'eq', sprintf('%+24.16e',$expect_v), "binstr754_to_double($src)" );  # v0.011_002: failed for $got == $expect_v when Config{nvsize}>8

# http://perlmonks.org/?node_id=984255                                                                  # v0.011_002: convert from use constant { hash }; to make compatible with perl 5.6
use constant STR_POS_ZERO        => '0'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_POS_DENORM_1ST  => '0'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_POS_DENORM_LST  => '0'.'00000000000'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_POS_NORM_1ST    => '0'.'00000000001'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_POS_NORM_LST    => '0'.'11111111110'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_POS_INF         => '0'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_POS_SNAN_1ST    => '0'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_POS_SNAN_LST    => '0'.'11111111111'.'0111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_POS_IND         => '0'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_POS_QNAN_1ST    => '0'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_POS_QNAN_LST    => '0'.'11111111111'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_NEG_ZERO        => '1'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_NEG_DENORM_1ST  => '1'.'00000000000'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_NEG_DENORM_LST  => '1'.'00000000000'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_NEG_NORM_1ST    => '1'.'00000000001'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_NEG_NORM_LST    => '1'.'11111111110'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_NEG_INF         => '1'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_NEG_SNAN_1ST    => '1'.'11111111111'.'0000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_NEG_SNAN_LST    => '1'.'11111111111'.'0111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';
use constant STR_NEG_IND         => '1'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000';
use constant STR_NEG_QNAN_1ST    => '1'.'11111111111'.'1000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000000'.'00000001';
use constant STR_NEG_QNAN_LST    => '1'.'11111111111'.'1111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111'.'11111111';

my %cmpmap;
foreach (
        STR_POS_ZERO, STR_POS_DENORM_1ST, STR_POS_DENORM_LST, STR_POS_NORM_1ST, STR_POS_NORM_LST,
        STR_POS_INF,
        STR_POS_IND, STR_POS_QNAN_1ST, STR_POS_QNAN_LST,
        STR_NEG_ZERO, STR_NEG_DENORM_1ST, STR_NEG_DENORM_LST, STR_NEG_NORM_1ST, STR_NEG_NORM_LST,
        STR_NEG_INF,
        STR_NEG_IND, STR_NEG_QNAN_1ST, STR_NEG_QNAN_LST
    )
{
    $cmpmap{$_} = $_;
}
foreach (
        STR_POS_SNAN_1ST, STR_POS_SNAN_LST,
        STR_NEG_SNAN_1ST, STR_NEG_SNAN_LST
    )
{
    $cmpmap{$_} = $_;
    substr $cmpmap{$_}, 12, 1, '.';       # ignore signal-vs-quiet bit: see http://perlmonks.org/?node_id=1166429 for in depth discussion: the short of it is, something in perl and/or compiler puts the SNAN thru a FP register, which quiets a SNAN.
}

my %valmap; @valmap{ sort keys %cmpmap } = (
    "\0\0\0\0\0\0\0\0",
    "\1\0\0\0\0\0\0\0",
    "\377\377\377\377\377\377\17\0",
    "\0\0\0\0\0\0\20\0",
    "\377\377\377\377\377\377\357\177",
    "\0\0\0\0\0\0\360\177",
    "\1\0\0\0\0\0\360\177",
    "\377\377\377\377\377\377\367\177",
    "\0\0\0\0\0\0\370\177",
    "\1\0\0\0\0\0\370\177",
    "\377\377\377\377\377\377\377\177",
    "\0\0\0\0\0\0\0\200",
    "\1\0\0\0\0\0\0\200",
    "\377\377\377\377\377\377\17\200",
    "\0\0\0\0\0\0\20\200",
    "\377\377\377\377\377\377\357\377",
    "\0\0\0\0\0\0\360\377",
    "\1\0\0\0\0\0\360\377",
    "\377\377\377\377\377\377\367\377",
    "\0\0\0\0\0\0\370\377",
    "\1\0\0\0\0\0\370\377",
    "\377\377\377\377\377\377\377\377"
);

# these subs force a little-endian universe
use constant DEBUG => 0;
if(DEBUG) {
    sub bitsToDouble{ unpack 'd',  pack 'b64', scalar reverse $_[0] }           # BrowserUK's conversion (http://perlmonks.org/?node_id=984255)
    sub bitsToInts{   reverse unpack 'VV', pack 'b64', scalar reverse $_[0] }   # BrowserUK's conversion (http://perlmonks.org/?node_id=984255)
    use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Useqq=1;
    diag sprintf "%64.64sb => %23.16g : %08x%08x\n\t| %s\n\t| %s\n", $_ , bitsToDouble( $_ ), bitsToInts( $_ ), Dumper(pack b64 => scalar reverse $_), Dumper($valmap{$_}) for sort keys %cmpmap;
    die;
}

foreach my $bits ( sort keys %cmpmap ) {
    $expect_v   = unpack 'd', $valmap{ $bits };     # replaced bitsToDouble with unpacking the hardcoded valmap strings (hopefully avoids problems with certain machines)

    $src        = $bits;
    $got        = binstr754_to_double($src);
    cmp_ok( $got, ( '1'x11 eq substr $bits, 1, 11 ) ? 'eq' : '==', $expect_v, "binstr754_to_double($bits)");

    $expect_b   = qr/$cmpmap{$bits}/;
    $src        = $expect_v;
    $got        = binstr754_from_double($src);
    like( $got, $expect_b, sprintf("binstr754_from_double(%26.16g)", $src));
}

exit;
