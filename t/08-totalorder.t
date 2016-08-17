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

plan skip_all => 'not yet implemented';
__END__
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

# TODO rework the test suite: i = each @constants, j = each @constants; run totalOrder and totalOrderMag on all N**2 ordered pairs
sub habs($) {
    my $h = shift;
    my $s = substr $h, 0, 1;
    $s = sprintf '%1.1X', (hex($s)|0x8);
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
        print STDERR $hx, $hy, $hax, $hay;
    }
}

__END__

my @tests = ();
#            [CONSTANT           , 'NAME               ', -, N, F, Z, s, I, !, S, C, 'class'            , R];
push @tests, [POS_ZERO           , 'POS_ZERO           ', 0, 0, 1, 1, 0, 0, 0, 0, 1, 'positiveZero'     , 2];
push @tests, [POS_DENORM_SMALLEST, 'POS_DENORM_SMALLEST', 0, 0, 1, 0, 1, 0, 0, 0, 1, 'positiveSubnormal', 2];
push @tests, [POS_DENORM_BIGGEST , 'POS_DENORM_BIGGEST ', 0, 0, 1, 0, 1, 0, 0, 0, 1, 'positiveSubnormal', 2];
push @tests, [POS_NORM_SMALLEST  , 'POS_NORM_SMALLEST  ', 0, 1, 1, 0, 0, 0, 0, 0, 1, 'positiveNormal'   , 2];
push @tests, [POS_NORM_BIGGEST   , 'POS_NORM_BIGGEST   ', 0, 1, 1, 0, 0, 0, 0, 0, 1, 'positiveNormal'   , 2];
push @tests, [POS_INF            , 'POS_INF            ', 0, 0, 0, 0, 0, 1, 0, 0, 1, 'positiveInfinity' , 2];
push @tests, [POS_SNAN_FIRST     , 'POS_SNAN_FIRST     ', 0, 0, 0, 0, 0, 0, 1, 1, 1, 'signalingNaN'     , 2];
push @tests, [POS_SNAN_LAST      , 'POS_SNAN_LAST      ', 0, 0, 0, 0, 0, 0, 1, 1, 1, 'signalingNaN'     , 2];
push @tests, [POS_IND            , 'POS_IND            ', 0, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];
push @tests, [POS_QNAN_FIRST     , 'POS_QNAN_FIRST     ', 0, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];
push @tests, [POS_QNAN_LAST      , 'POS_QNAN_LAST      ', 0, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];

push @tests, [NEG_ZERO           , 'NEG_ZERO           ', 1, 0, 1, 1, 0, 0, 0, 0, 1, 'negativeZero'     , 2];
push @tests, [NEG_DENORM_SMALLEST, 'NEG_DENORM_SMALLEST', 1, 0, 1, 0, 1, 0, 0, 0, 1, 'negativeSubnormal', 2];
push @tests, [NEG_DENORM_BIGGEST , 'NEG_DENORM_BIGGEST ', 1, 0, 1, 0, 1, 0, 0, 0, 1, 'negativeSubnormal', 2];
push @tests, [NEG_NORM_SMALLEST  , 'NEG_NORM_SMALLEST  ', 1, 1, 1, 0, 0, 0, 0, 0, 1, 'negativeNormal'   , 2];
push @tests, [NEG_NORM_BIGGEST   , 'NEG_NORM_BIGGEST   ', 1, 1, 1, 0, 0, 0, 0, 0, 1, 'negativeNormal'   , 2];
push @tests, [NEG_INF            , 'NEG_INF            ', 1, 0, 0, 0, 0, 1, 0, 0, 1, 'negativeInfinity' , 2];
push @tests, [NEG_SNAN_FIRST     , 'NEG_SNAN_FIRST     ', 1, 0, 0, 0, 0, 0, 1, 1, 1, 'signalingNaN'     , 2];
push @tests, [NEG_SNAN_LAST      , 'NEG_SNAN_LAST      ', 1, 0, 0, 0, 0, 0, 1, 1, 1, 'signalingNaN'     , 2];
push @tests, [NEG_IND            , 'NEG_IND            ', 1, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];
push @tests, [NEG_QNAN_FIRST     , 'NEG_QNAN_FIRST     ', 1, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];
push @tests, [NEG_QNAN_LAST      , 'NEG_QNAN_LAST      ', 1, 0, 0, 0, 0, 0, 1, 0, 1, 'quietNaN'         , 2];

my @flist = qw(isSignMinus isNormal isFinite isZero isSubnormal isInfinite isNaN isSignaling isCanonical class radix);

plan tests => scalar(@tests) * scalar(@flist);

foreach my $t ( @tests ) {
    my ($c, $name, @x) = @$t;
    my $mi = (@flist >= @x) ? $#flist : $#x;
    foreach my $i ( 0 .. $mi ) {
        my $fn = $flist[$i];
        my $xi = $x[$i];
        my $f = \&{$fn};
        cmp_ok( $f->($c), 'eq', $xi, sprintf('%-20.20s(%-20.20s) = %s', $fn, $name, $f->($c) ) );
    }
}

exit;