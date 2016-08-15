########################################################################
# Verifies the following functions:
#   :general
#       isXXXX(v)
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :floatingpoint :constants :general/;

my @tests = ();
#            [CONSTANT           , 'NAME               ', -, N, F, Z, s, I, !, S, 'C', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_ZERO           , 'POS_ZERO           ', 0, 0, 1, 1, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_DENORM_SMALLEST, 'POS_DENORM_SMALLEST', 0, 0, 1, 0, 1, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_DENORM_BIGGEST , 'POS_DENORM_BIGGEST ', 0, 0, 1, 0, 1, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_NORM_SMALLEST  , 'POS_NORM_SMALLEST  ', 0, 1, 1, 0, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_NORM_BIGGEST   , 'POS_NORM_BIGGEST   ', 0, 1, 1, 0, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_INF            , 'POS_INF            ', 0, 0, 0, 0, 0, 1, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_SNAN_FIRST     , 'POS_SNAN_FIRST     ', 0, 0, 0, 0, 0, 0, 1, 1, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_SNAN_LAST      , 'POS_SNAN_LAST      ', 0, 0, 0, 0, 0, 0, 1, 1, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_IND            , 'POS_IND            ', 0, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_QNAN_FIRST     , 'POS_QNAN_FIRST     ', 0, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [POS_QNAN_LAST      , 'POS_QNAN_LAST      ', 0, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];

push @tests, [NEG_ZERO           , 'NEG_ZERO           ', 1, 0, 1, 1, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_DENORM_SMALLEST, 'NEG_DENORM_SMALLEST', 1, 0, 1, 0, 1, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_DENORM_BIGGEST , 'NEG_DENORM_BIGGEST ', 1, 0, 1, 0, 1, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_NORM_SMALLEST  , 'NEG_NORM_SMALLEST  ', 1, 1, 1, 0, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_NORM_BIGGEST   , 'NEG_NORM_BIGGEST   ', 1, 1, 1, 0, 0, 0, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_INF            , 'NEG_INF            ', 1, 0, 0, 0, 0, 1, 0, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_SNAN_FIRST     , 'NEG_SNAN_FIRST     ', 1, 0, 0, 0, 0, 0, 1, 1, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_SNAN_LAST      , 'NEG_SNAN_LAST      ', 1, 0, 0, 0, 0, 0, 1, 1, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_IND            , 'NEG_IND            ', 1, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_QNAN_FIRST     , 'NEG_QNAN_FIRST     ', 1, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];
push @tests, [NEG_QNAN_LAST      , 'NEG_QNAN_LAST      ', 1, 0, 0, 0, 0, 0, 1, 0, '?', 'class', 'radix', 'totalOrder', 'totalOrderMag'];

my @flist = qw(isSignMinus isNormal isFinite isZero isSubnormal isInfinite isNaN isSignaling isCanonical class radix totalOrder totalOrderMag);

plan tests => scalar(@tests) * 7; #scalar(@flist);

foreach my $t ( @tests ) {
    my ($c, $name, @x) = @$t;
    my $mi = (@flist >= @x) ? $#flist : $#x;
$mi = 6; # ignore beyond isNaN for now
    foreach my $i ( 0 .. $mi ) {
        my $fn = $flist[$i];
        my $xi = $x[$i];
        my $f = \&{$fn};
        cmp_ok( $f->($c), 'eq', $xi, sprintf('%-20.20s(%-20.20s)', $fn, $name) );
    }
}

exit;