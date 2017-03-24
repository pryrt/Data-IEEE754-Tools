########################################################################
# AuthorTest: Verifies each of the import tags are okay -- that
#   they only import exactly what I expect, no more, no less
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 11;
use Config;
use Data::IEEE754::Tools ();

my @SUBS = qw(
    binary64_convertToInternalHexString         convertToInternalHexString          hexstr754_from_double
    binary64_convertToInternalBinaryString      convertToInternalBinaryString       binstr754_from_double
    binary64_convertFromInternalHexString       convertFromInternalHexString        hexstr754_to_double
    binary64_convertFromInternalBinaryString    convertFromInternalBinaryString     binstr754_to_double
    binary64_convertToHexCharacter              convertToHexCharacter               to_hex_floatingpoint
    binary64_convertToDecimalCharacter          convertToDecimalCharacter           to_dec_floatingpoint
    POS_ZERO
    POS_DENORM_SMALLEST
    POS_DENORM_BIGGEST
    POS_NORM_SMALLEST
    POS_NORM_BIGGEST
    POS_INF
    POS_SNAN_FIRST
    POS_SNAN_LAST
    POS_IND
    POS_QNAN_FIRST
    POS_QNAN_LAST
    NEG_ZERO
    NEG_DENORM_SMALLEST
    NEG_DENORM_BIGGEST
    NEG_NORM_SMALLEST
    NEG_NORM_BIGGEST
    NEG_INF
    NEG_SNAN_FIRST
    NEG_SNAN_LAST
    NEG_IND
    NEG_QNAN_FIRST
    NEG_QNAN_LAST
    ulp
    toggle_ulp
    nextUp
    nextDown
    nextAfter
    isSignMinus
    isNormal
    isFinite
    isZero
    isSubnormal
    isInfinite
    isNaN
    isSignaling
    isSignalingConvertedToQuiet
    isCanonical
    class
    radix
    totalOrder
    totalOrderMag
    compareFloatingValue
    compareFloatingMag
    copy
    negate
    abs
    copySign
);

sub run_test {
    my ($tag, $exp) = @_;
    Data::IEEE754::Tools->import($tag);
    my $got = [];
    push @$got, grep { defined &{$_} } @SUBS;
    $got = [sort @$got];
    is_deeply( $got, $exp, $tag );
    # { local $" = ","; diag ''; diag "$tag\n     got(@$got)\n      vs(@$exp)\n";  diag '';}

    # unimport the functions that were found in @$got (inspired by http://stackoverflow.com/a/10307113/5508606)
    my $pkg = \%::;
    delete $pkg->{$_} for @$got;
}

my @tests = ();
push @tests, [':convertToCharacter' => [sort qw(
    convertToHexCharacter
    convertToDecimalCharacter
)]];
push @tests, [':floating'           => [sort qw(
    to_hex_floatingpoint
    to_dec_floatingpoint
)]];
push @tests, [':floatingpoint'      => [sort qw(
    to_hex_floatingpoint
    to_dec_floatingpoint
)]];
push @tests, [':internalString'     => [sort qw(
    convertToInternalHexString
    convertToInternalBinaryString
    convertFromInternalHexString
    convertFromInternalBinaryString
)]];
push @tests, [':raw754'             => [sort qw(
    hexstr754_from_double
    hexstr754_to_double
    binstr754_from_double
    binstr754_to_double
)]];
push @tests, [':ulp'                => [sort qw(
    ulp
    toggle_ulp
    nextUp
    nextDown
    nextAfter
)]];
push @tests, [':constants'          => [sort qw(
    POS_ZERO
    POS_DENORM_SMALLEST
    POS_DENORM_BIGGEST
    POS_NORM_SMALLEST
    POS_NORM_BIGGEST
    POS_INF
    POS_SNAN_FIRST
    POS_SNAN_LAST
    POS_IND
    POS_QNAN_FIRST
    POS_QNAN_LAST
    NEG_ZERO
    NEG_DENORM_SMALLEST
    NEG_DENORM_BIGGEST
    NEG_NORM_SMALLEST
    NEG_NORM_BIGGEST
    NEG_INF
    NEG_SNAN_FIRST
    NEG_SNAN_LAST
    NEG_IND
    NEG_QNAN_FIRST
    NEG_QNAN_LAST
)]];
push @tests, [':info'               => [sort qw(
    isSignMinus
    isNormal
    isFinite
    isZero
    isSubnormal
    isInfinite
    isNaN
    isSignaling
    isSignalingConvertedToQuiet
    isCanonical
    class
    radix
    totalOrder
    totalOrderMag
    compareFloatingValue
    compareFloatingMag
)]];
push @tests, [':signbit'            => [sort qw(
    copy
    negate
    abs
    copySign
    isSignMinus
)]];
push @tests, [':binary64'           => [sort qw(
    binary64_convertToInternalHexString
    binary64_convertFromInternalHexString
    binary64_convertToInternalBinaryString
    binary64_convertFromInternalBinaryString
    binary64_convertToHexCharacter
    binary64_convertToDecimalCharacter
)]];
push @tests, [':all'                => [sort @SUBS]];

run_test(@$_) foreach @tests;
