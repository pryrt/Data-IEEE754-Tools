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

sub core_abs($) { CORE::abs(shift) }

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

my @flist = qw(negate absolute core_abs);
plan tests => scalar(@tests) * (scalar(@flist)+1)*2;

my $isCoreAbsWrongForNegNaN = isCoreAbsWrongForNegNaN();

foreach my $t ( @tests ) {
    my ($c, $name, @x) = @$t;
    my $mi = (@flist >= @x) ? $#flist : $#x;
    my $bool = $isCoreAbsWrongForNegNaN && ($name =~ /^NEG_[QS]NAN/i) || 0;
        # TODO = v0.013_008 negate(NEG_IND) is confirmed on perl v5.16.0:
        #   either debug or determine to just skip it on NEG_IND, too.
    foreach my $i ( 0 .. $mi ) {
        my $fn = $flist[$i];
        my $xi = $x[$i];
        my $f = \&{$fn};
        SKIP: {
            skip sprintf('CORE::abs() gives wrong value for abs(-NaN): '.$fn), 2 if $bool && ($fn eq 'core_abs');
            is( ($f->($c)), ($xi), sprintf('%-20.20s(%-20.20s)', $fn, $name ) );
            is( to_hex_floatingpoint($f->($c)), to_hex_floatingpoint($xi), sprintf('%-20.20s(%-20.20s)', $fn, $name ) );
        }
    }
    SKIP: {
        skip sprintf('CORE::abs() gives wrong value for abs(-NaN): absolute vs CORE::abs'), 2 if $bool;
        is( (absolute($c)), (core_abs($c)), sprintf('%-20.20s(%-20.20s) for CORE::abs(x) vs Data::IEEE754::Tools::absolute(x)', 'compare', $name) );
        is( to_hex_floatingpoint(absolute($c)), to_hex_floatingpoint(core_abs($c)), sprintf('%-20.20s(%-20.20s) for CORE::abs(x) vs Data::IEEE754::Tools::absolute(x)', 'compare', $name) );
    }
}

if( $isCoreAbsWrongForNegNaN ) {
    # set the environment variable to a TRUE value to see the extra proof
    if( exists $ENV{PROVE_CORE_ABS_WRONG} && $ENV{PROVE_CORE_ABS_WRONG} ) {
        foreach my $c ( qw(NEG_QNAN_LAST POS_QNAN_LAST NEG_INF POS_INF) ) {
    	    my $f = \&{$c};
            my $x = $f->();
            my $y = abs($x);
            diag("\n");
            foreach($x,$y) { diag( join "\t", $c,$_,isSignMinus($_),hexstr754_from_double($_)); };
        }
    }

    diag( "\n" );
    diag( "\n" );
    diag( "*"x80 );
    diag( 'WARNING: CORE::abs() gives wrong value for negative NaN values:');
    diag( '         It should clear the sign bit, but it does not.');
    diag( '         If this matters to you, use Data::IEEE754::Tools::absolute()');
    diag( '         instead of CORE::abs() for computing the absolute value of a');
    diag( '         floating-point that might be a negative NaN');
    diag( "*"x80 );
    diag( "\n" );
    diag( "\n" );
}

exit;
