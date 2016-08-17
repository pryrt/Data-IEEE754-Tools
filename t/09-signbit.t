########################################################################
# Verifies the following functions:
#   :signbit
#       negate(v)
#       absolute(v)
# Will require separate test procedure:
#       copySign(v)
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :floatingpoint :constants :signbit/;

my @tests = ();
#            [CONSTANT           , 'NAME               ', negate()           , absolute()         , CORE::abs()        ];
push @tests, [POS_ZERO           , 'POS_ZERO           ', NEG_ZERO           , POS_ZERO           , POS_ZERO           ];
push @tests, [POS_DENORM_SMALLEST, 'POS_DENORM_SMALLEST', NEG_DENORM_SMALLEST, POS_DENORM_SMALLEST, POS_DENORM_SMALLEST];
push @tests, [POS_DENORM_BIGGEST , 'POS_DENORM_BIGGEST ', NEG_DENORM_BIGGEST , POS_DENORM_BIGGEST , POS_DENORM_BIGGEST ];
push @tests, [POS_NORM_SMALLEST  , 'POS_NORM_SMALLEST  ', NEG_NORM_SMALLEST  , POS_NORM_SMALLEST  , POS_NORM_SMALLEST  ];
push @tests, [POS_NORM_BIGGEST   , 'POS_NORM_BIGGEST   ', NEG_NORM_BIGGEST   , POS_NORM_BIGGEST   , POS_NORM_BIGGEST   ];
push @tests, [POS_INF            , 'POS_INF            ', NEG_INF            , POS_INF            , POS_INF            ];
push @tests, [POS_SNAN_FIRST     , 'POS_SNAN_FIRST     ', NEG_SNAN_FIRST     , POS_SNAN_FIRST     , POS_SNAN_FIRST     ];
push @tests, [POS_SNAN_LAST      , 'POS_SNAN_LAST      ', NEG_SNAN_LAST      , POS_SNAN_LAST      , POS_SNAN_LAST      ];
push @tests, [POS_IND            , 'POS_IND            ', NEG_IND            , POS_IND            , POS_IND            ];
push @tests, [POS_QNAN_FIRST     , 'POS_QNAN_FIRST     ', NEG_QNAN_FIRST     , POS_QNAN_FIRST     , POS_QNAN_FIRST     ];
push @tests, [POS_QNAN_LAST      , 'POS_QNAN_LAST      ', NEG_QNAN_LAST      , POS_QNAN_LAST      , POS_QNAN_LAST      ];

push @tests, [NEG_ZERO           , 'NEG_ZERO           ', POS_ZERO           , POS_ZERO           , POS_ZERO           ];
push @tests, [NEG_DENORM_SMALLEST, 'NEG_DENORM_SMALLEST', POS_DENORM_SMALLEST, POS_DENORM_SMALLEST, POS_DENORM_SMALLEST];
push @tests, [NEG_DENORM_BIGGEST , 'NEG_DENORM_BIGGEST ', POS_DENORM_BIGGEST , POS_DENORM_BIGGEST , POS_DENORM_BIGGEST ];
push @tests, [NEG_NORM_SMALLEST  , 'NEG_NORM_SMALLEST  ', POS_NORM_SMALLEST  , POS_NORM_SMALLEST  , POS_NORM_SMALLEST  ];
push @tests, [NEG_NORM_BIGGEST   , 'NEG_NORM_BIGGEST   ', POS_NORM_BIGGEST   , POS_NORM_BIGGEST   , POS_NORM_BIGGEST   ];
push @tests, [NEG_INF            , 'NEG_INF            ', POS_INF            , POS_INF            , POS_INF            ];
push @tests, [NEG_SNAN_FIRST     , 'NEG_SNAN_FIRST     ', POS_SNAN_FIRST     , POS_SNAN_FIRST     , POS_SNAN_FIRST     ];
push @tests, [NEG_SNAN_LAST      , 'NEG_SNAN_LAST      ', POS_SNAN_LAST      , POS_SNAN_LAST      , POS_SNAN_LAST      ];
push @tests, [NEG_IND            , 'NEG_IND            ', POS_IND            , POS_IND            , POS_IND            ];
push @tests, [NEG_QNAN_FIRST     , 'NEG_QNAN_FIRST     ', POS_QNAN_FIRST     , POS_QNAN_FIRST     , POS_QNAN_FIRST     ];
push @tests, [NEG_QNAN_LAST      , 'NEG_QNAN_LAST      ', POS_QNAN_LAST      , POS_QNAN_LAST      , POS_QNAN_LAST      ];

my @flist = qw(negate absolute CORE::abs);

plan tests => scalar(@tests) * scalar(@flist);

foreach my $t ( @tests ) {
    my ($c, $name, @x) = @$t;
    my $mi = (@flist >= @x) ? $#flist : $#x;
    foreach my $i ( 0 .. $mi ) {
        my $fn = $flist[$i];
        my $xi = $x[$i];
        my $f = \&{$fn};
        cmp_ok( $f->($c), 'eq', $xi, sprintf('%-20.20s(%-20.20s)', $fn, $name ) );
    }
}

exit;