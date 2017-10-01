########################################################################
# Verifies the following functions:
#   :convertToString
#       convertToHexString(v)
#       convertToDecimalString(v)
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :convertToString/;

sub fptest {
    local $\ = "\n";
    my $h = shift;
    my $val = hexstr754_to_double($h->{src});
    my ($got, $exp, $name);
    $exp = quotemeta( $h->{exp_hex} );
    $exp =~ s/SNAN/[SQ]NAN/;
    if(exists $h->{convSpec}) {
        like( $got = convertToHexString($val, $h->{convSpec}),
            qr/$exp/,
            $name = sprintf('convertToHexString    (ieee754(%-16.16s) = %-+24.16e, %s)',
                $h->{src}, $val,
                defined $h->{convSpec} ? $h->{convSpec} : '<undef>')
        );
    } else {
        like( $got = convertToHexString($val),
            qr/$exp/,
            $name = sprintf('convertToHexString    (ieee754(%-16.16s) = %-+24.16e)',
                $h->{src}, $val)
        );
    }
    $exp = quotemeta( $h->{exp_dec} );
    $exp =~ s/SNAN/[SQ]NAN/;
    if(exists $h->{convSpec}) {
        like( $got = convertToDecimalString($val, $h->{convSpec}),
            qr/$exp/,
            $name = sprintf('convertToDecimalString(ieee754(%-16.16s) = %-+24.16e, %s)',
                $h->{src}, $val,
                defined $h->{convSpec} ? $h->{convSpec} : '<undef>')
        );
    } else {
        like( $got = convertToDecimalString($val),
            qr/$exp/,
            $name = sprintf('convertToDecimalString(ieee754(%-16.16s) = %-+24.16e)',
                $h->{src}, $val)
        );
    }
}

my @tests = ();
push @tests, { src => '0000000000000000', exp_hex => '+0x0.0000000000000p+0000', exp_dec => '+0d0.0000000000000000p+0000' };
push @tests, { src => '0000000000000000', exp_hex => '+0x0.0000000000000p+0000', exp_dec => '+0d0.0000000000000000p+0000'   , convSpec => undef };
push @tests, { src => '0000000000000000', exp_hex => '+0x0.0000000000p+0000'   , exp_dec => '+0d0.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '0000000000000000', exp_hex => '+0x0.0000000000000p+0000', exp_dec => '+0d0.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => '8000000000000000', exp_hex => '-0x0.0000000000000p+0000', exp_dec => '-0d0.0000000000000000p+0000' };
push @tests, { src => '8000000000000000', exp_hex => '-0x0.0000000000000p+0000', exp_dec => '-0d0.0000000000000000p+0000'   , convSpec => undef };
push @tests, { src => '8000000000000000', exp_hex => '-0x0.0000000000p+0000'   , exp_dec => '-0d0.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '8000000000000000', exp_hex => '-0x0.0000000000000p+0000', exp_dec => '-0d0.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '0000000000000001', exp_hex => '+0x0.0000000000001p-1022', exp_dec => '+0d0.0000000000000002p-1022' };
push @tests, { src => '0000000000000001', exp_hex => '+0x0.0000000000001p-1022', exp_dec => '+0d0.0000000000000002p-1022'   , convSpec => undef };
push @tests, { src => '0000000000000001', exp_hex => '+0x0.000p-1022'          , exp_dec => '+0d0.000p-1022'                , convSpec => 3     };  # extra: coverage for p<5
push @tests, { src => '0000000000000001', exp_hex => '+0x0.0000000000p-1022'   , exp_dec => '+0d0.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '0000000000000001', exp_hex => '+0x0.0000000000001p-1022', exp_dec => '+0d0.0000000000000p-1022'      , convSpec => 13    };
push @tests, { src => '8000000000000001', exp_hex => '-0x0.0000000000001p-1022', exp_dec => '-0d0.0000000000000002p-1022' };
push @tests, { src => '8000000000000001', exp_hex => '-0x0.0000000000001p-1022', exp_dec => '-0d0.0000000000000002p-1022'   , convSpec => undef };
push @tests, { src => '8000000000000001', exp_hex => '-0x0.000p-1022'          , exp_dec => '-0d0.000p-1022'                , convSpec => 3     };  # extra: coverage for p<5
push @tests, { src => '8000000000000001', exp_hex => '-0x0.0000000000p-1022'   , exp_dec => '-0d0.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '8000000000000001', exp_hex => '-0x0.0000000000001p-1022', exp_dec => '-0d0.0000000000000p-1022'      , convSpec => 13    };

push @tests, { src => '000FFFFFFFFFFFFF', exp_hex => '+0x0.fffffffffffffp-1022', exp_dec => '+0d0.9999999999999998p-1022' };
push @tests, { src => '000FFFFFFFFFFFFF', exp_hex => '+0x0.fffffffffffffp-1022', exp_dec => '+0d0.9999999999999998p-1022'   , convSpec => undef };
push @tests, { src => '000FFFFFFFFFFFFF', exp_hex => '+0x1.000p-1022'          , exp_dec => '+0d1.000p-1022'                , convSpec => 3     };  # extra: coverage for p<5
push @tests, { src => '000FFFFFFFFFFFFF', exp_hex => '+0x1.0000000000p-1022'   , exp_dec => '+0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '000FFFFFFFFFFFFF', exp_hex => '+0x0.fffffffffffffp-1022', exp_dec => '+0d1.0000000000000p-1022'      , convSpec => 13    };
push @tests, { src => '800FFFFFFFFFFFFF', exp_hex => '-0x0.fffffffffffffp-1022', exp_dec => '-0d0.9999999999999998p-1022' };
push @tests, { src => '800FFFFFFFFFFFFF', exp_hex => '-0x0.fffffffffffffp-1022', exp_dec => '-0d0.9999999999999998p-1022'   , convSpec => undef };
push @tests, { src => '800FFFFFFFFFFFFF', exp_hex => '-0x1.000p-1022'          , exp_dec => '-0d1.000p-1022'                , convSpec => 3     };  # extra: coverage for p<5
push @tests, { src => '800FFFFFFFFFFFFF', exp_hex => '-0x1.0000000000p-1022'   , exp_dec => '-0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '800FFFFFFFFFFFFF', exp_hex => '-0x0.fffffffffffffp-1022', exp_dec => '-0d1.0000000000000p-1022'      , convSpec => 13    };

push @tests, { src => '0010000000000000', exp_hex => '+0x1.0000000000000p-1022', exp_dec => '+0d1.0000000000000000p-1022' };
push @tests, { src => '0010000000000000', exp_hex => '+0x1.0000000000000p-1022', exp_dec => '+0d1.0000000000000000p-1022'   , convSpec => undef };
push @tests, { src => '0010000000000000', exp_hex => '+0x1.0000000000p-1022'   , exp_dec => '+0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '0010000000000000', exp_hex => '+0x1.0000000000000p-1022', exp_dec => '+0d1.0000000000000p-1022'      , convSpec => 13    };
push @tests, { src => '8010000000000000', exp_hex => '-0x1.0000000000000p-1022', exp_dec => '-0d1.0000000000000000p-1022' };
push @tests, { src => '8010000000000000', exp_hex => '-0x1.0000000000000p-1022', exp_dec => '-0d1.0000000000000000p-1022'   , convSpec => undef };
push @tests, { src => '8010000000000000', exp_hex => '-0x1.0000000000p-1022'   , exp_dec => '-0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '8010000000000000', exp_hex => '-0x1.0000000000000p-1022', exp_dec => '-0d1.0000000000000p-1022'      , convSpec => 13    };

push @tests, { src => '0010000000000001', exp_hex => '+0x1.0000000000001p-1022', exp_dec => '+0d1.0000000000000002p-1022' };
push @tests, { src => '0010000000000001', exp_hex => '+0x1.0000000000001p-1022', exp_dec => '+0d1.0000000000000002p-1022'   , convSpec => undef };
push @tests, { src => '0010000000000001', exp_hex => '+0x1.0000000000p-1022'   , exp_dec => '+0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '0010000000000001', exp_hex => '+0x1.0000000000001p-1022', exp_dec => '+0d1.0000000000000p-1022'      , convSpec => 13    };
push @tests, { src => '8010000000000001', exp_hex => '-0x1.0000000000001p-1022', exp_dec => '-0d1.0000000000000002p-1022' };
push @tests, { src => '8010000000000001', exp_hex => '-0x1.0000000000001p-1022', exp_dec => '-0d1.0000000000000002p-1022'   , convSpec => undef };
push @tests, { src => '8010000000000001', exp_hex => '-0x1.0000000000p-1022'   , exp_dec => '-0d1.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '8010000000000001', exp_hex => '-0x1.0000000000001p-1022', exp_dec => '-0d1.0000000000000p-1022'      , convSpec => 13    };

push @tests, { src => '001FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp-1022', exp_dec => '+0d1.9999999999999998p-1022' };
push @tests, { src => '001FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp-1022', exp_dec => '+0d1.9999999999999998p-1022'   , convSpec => undef };
push @tests, { src => '001FFFFFFFFFFFFF', exp_hex => '+0x2.0000000000p-1022'   , exp_dec => '+0d2.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '001FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp-1022', exp_dec => '+0d2.0000000000000p-1022'      , convSpec => 13    };
push @tests, { src => '801FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp-1022', exp_dec => '-0d1.9999999999999998p-1022' };
push @tests, { src => '801FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp-1022', exp_dec => '-0d1.9999999999999998p-1022'   , convSpec => undef };
push @tests, { src => '801FFFFFFFFFFFFF', exp_hex => '-0x2.0000000000p-1022'   , exp_dec => '-0d2.0000000000p-1022'         , convSpec => 10    };
push @tests, { src => '801FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp-1022', exp_dec => '-0d2.0000000000000p-1022'      , convSpec => 13    };

push @tests, { src => '3FF0000000000000', exp_hex => '+0x1.0000000000000p+0000', exp_dec => '+0d1.0000000000000000p+0000' };
push @tests, { src => '3FF0000000000000', exp_hex => '+0x1.0000000000000p+0000', exp_dec => '+0d1.0000000000000000p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000000000', exp_hex => '+0x1.0000000000p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000000000', exp_hex => '+0x1.0000000000000p+0000', exp_dec => '+0d1.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000000000', exp_hex => '-0x1.0000000000000p+0000', exp_dec => '-0d1.0000000000000000p+0000' };
push @tests, { src => 'BFF0000000000000', exp_hex => '-0x1.0000000000000p+0000', exp_dec => '-0d1.0000000000000000p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000000000', exp_hex => '-0x1.0000000000p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000000000', exp_hex => '-0x1.0000000000000p+0000', exp_dec => '-0d1.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000000001', exp_hex => '+0x1.0000000000001p+0000', exp_dec => '+0d1.0000000000000002p+0000' };
push @tests, { src => '3FF0000000000001', exp_hex => '+0x1.0000000000001p+0000', exp_dec => '+0d1.0000000000000002p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000000001', exp_hex => '+0x1.0000000000p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000000001', exp_hex => '+0x1.0000000000001p+0000', exp_dec => '+0d1.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000000001', exp_hex => '-0x1.0000000000001p+0000', exp_dec => '-0d1.0000000000000002p+0000' };
push @tests, { src => 'BFF0000000000001', exp_hex => '-0x1.0000000000001p+0000', exp_dec => '-0d1.0000000000000002p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000000001', exp_hex => '-0x1.0000000000p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000000001', exp_hex => '-0x1.0000000000001p+0000', exp_dec => '-0d1.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000000008', exp_hex => '+0x1.0000000000008p+0000', exp_dec => '+0d1.0000000000000018p+0000' };
push @tests, { src => '3FF0000000000008', exp_hex => '+0x1.0000000000008p+0000', exp_dec => '+0d1.0000000000000018p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000000008', exp_hex => '+0x1.0000000000p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000000008', exp_hex => '+0x1.0000000000008p+0000', exp_dec => '+0d1.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000000008', exp_hex => '-0x1.0000000000008p+0000', exp_dec => '-0d1.0000000000000018p+0000' };
push @tests, { src => 'BFF0000000000008', exp_hex => '-0x1.0000000000008p+0000', exp_dec => '-0d1.0000000000000018p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000000008', exp_hex => '-0x1.0000000000p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000000008', exp_hex => '-0x1.0000000000008p+0000', exp_dec => '-0d1.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000000080', exp_hex => '+0x1.0000000000080p+0000', exp_dec => '+0d1.0000000000000284p+0000' };
push @tests, { src => '3FF0000000000080', exp_hex => '+0x1.0000000000080p+0000', exp_dec => '+0d1.0000000000000284p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000000080', exp_hex => '+0x1.0000000000p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000000080', exp_hex => '+0x1.0000000000080p+0000', exp_dec => '+0d1.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000000080', exp_hex => '-0x1.0000000000080p+0000', exp_dec => '-0d1.0000000000000284p+0000' };
push @tests, { src => 'BFF0000000000080', exp_hex => '-0x1.0000000000080p+0000', exp_dec => '-0d1.0000000000000284p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000000080', exp_hex => '-0x1.0000000000p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000000080', exp_hex => '-0x1.0000000000080p+0000', exp_dec => '-0d1.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000000800', exp_hex => '+0x1.0000000000800p+0000', exp_dec => '+0d1.0000000000004547p+0000' };
push @tests, { src => '3FF0000000000800', exp_hex => '+0x1.0000000000800p+0000', exp_dec => '+0d1.0000000000004547p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000000800', exp_hex => '+0x1.0000000001p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000000800', exp_hex => '+0x1.0000000000800p+0000', exp_dec => '+0d1.0000000000005p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000000800', exp_hex => '-0x1.0000000000800p+0000', exp_dec => '-0d1.0000000000004547p+0000' };
push @tests, { src => 'BFF0000000000800', exp_hex => '-0x1.0000000000800p+0000', exp_dec => '-0d1.0000000000004547p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000000800', exp_hex => '-0x1.0000000001p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000000800', exp_hex => '-0x1.0000000000800p+0000', exp_dec => '-0d1.0000000000005p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000008000', exp_hex => '+0x1.0000000008000p+0000', exp_dec => '+0d1.0000000000072760p+0000' };
push @tests, { src => '3FF0000000008000', exp_hex => '+0x1.0000000008000p+0000', exp_dec => '+0d1.0000000000072760p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000008000', exp_hex => '+0x1.0000000008p+0000'   , exp_dec => '+0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000008000', exp_hex => '+0x1.0000000008000p+0000', exp_dec => '+0d1.0000000000073p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000008000', exp_hex => '-0x1.0000000008000p+0000', exp_dec => '-0d1.0000000000072760p+0000' };
push @tests, { src => 'BFF0000000008000', exp_hex => '-0x1.0000000008000p+0000', exp_dec => '-0d1.0000000000072760p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000008000', exp_hex => '-0x1.0000000008p+0000'   , exp_dec => '-0d1.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000008000', exp_hex => '-0x1.0000000008000p+0000', exp_dec => '-0d1.0000000000073p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000080000', exp_hex => '+0x1.0000000080000p+0000', exp_dec => '+0d1.0000000001164153p+0000' };
push @tests, { src => '3FF0000000080000', exp_hex => '+0x1.0000000080000p+0000', exp_dec => '+0d1.0000000001164153p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000080000', exp_hex => '+0x1.0000000080p+0000'   , exp_dec => '+0d1.0000000001p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000080000', exp_hex => '+0x1.0000000080000p+0000', exp_dec => '+0d1.0000000001164p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000080000', exp_hex => '-0x1.0000000080000p+0000', exp_dec => '-0d1.0000000001164153p+0000' };
push @tests, { src => 'BFF0000000080000', exp_hex => '-0x1.0000000080000p+0000', exp_dec => '-0d1.0000000001164153p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000080000', exp_hex => '-0x1.0000000080p+0000'   , exp_dec => '-0d1.0000000001p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000080000', exp_hex => '-0x1.0000000080000p+0000', exp_dec => '-0d1.0000000001164p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000000800000', exp_hex => '+0x1.0000000800000p+0000', exp_dec => '+0d1.0000000018626451p+0000' };
push @tests, { src => '3FF0000000800000', exp_hex => '+0x1.0000000800000p+0000', exp_dec => '+0d1.0000000018626451p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000000800000', exp_hex => '+0x1.0000000800p+0000'   , exp_dec => '+0d1.0000000019p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000000800000', exp_hex => '+0x1.0000000800000p+0000', exp_dec => '+0d1.0000000018626p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000000800000', exp_hex => '-0x1.0000000800000p+0000', exp_dec => '-0d1.0000000018626451p+0000' };
push @tests, { src => 'BFF0000000800000', exp_hex => '-0x1.0000000800000p+0000', exp_dec => '-0d1.0000000018626451p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000000800000', exp_hex => '-0x1.0000000800p+0000'   , exp_dec => '-0d1.0000000019p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000000800000', exp_hex => '-0x1.0000000800000p+0000', exp_dec => '-0d1.0000000018626p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000008000000', exp_hex => '+0x1.0000008000000p+0000', exp_dec => '+0d1.0000000298023224p+0000' };
push @tests, { src => '3FF0000008000000', exp_hex => '+0x1.0000008000000p+0000', exp_dec => '+0d1.0000000298023224p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000008000000', exp_hex => '+0x1.0000008000p+0000'   , exp_dec => '+0d1.0000000298p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000008000000', exp_hex => '+0x1.0000008000000p+0000', exp_dec => '+0d1.0000000298023p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000008000000', exp_hex => '-0x1.0000008000000p+0000', exp_dec => '-0d1.0000000298023224p+0000' };
push @tests, { src => 'BFF0000008000000', exp_hex => '-0x1.0000008000000p+0000', exp_dec => '-0d1.0000000298023224p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000008000000', exp_hex => '-0x1.0000008000p+0000'   , exp_dec => '-0d1.0000000298p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000008000000', exp_hex => '-0x1.0000008000000p+0000', exp_dec => '-0d1.0000000298023p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000080000000', exp_hex => '+0x1.0000080000000p+0000', exp_dec => '+0d1.0000004768371582p+0000' };
push @tests, { src => '3FF0000080000000', exp_hex => '+0x1.0000080000000p+0000', exp_dec => '+0d1.0000004768371582p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000080000000', exp_hex => '+0x1.0000080000p+0000'   , exp_dec => '+0d1.0000004768p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000080000000', exp_hex => '+0x1.0000080000000p+0000', exp_dec => '+0d1.0000004768372p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000080000000', exp_hex => '-0x1.0000080000000p+0000', exp_dec => '-0d1.0000004768371582p+0000' };
push @tests, { src => 'BFF0000080000000', exp_hex => '-0x1.0000080000000p+0000', exp_dec => '-0d1.0000004768371582p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000080000000', exp_hex => '-0x1.0000080000p+0000'   , exp_dec => '-0d1.0000004768p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000080000000', exp_hex => '-0x1.0000080000000p+0000', exp_dec => '-0d1.0000004768372p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0000800000000', exp_hex => '+0x1.0000800000000p+0000', exp_dec => '+0d1.0000076293945312p+0000' };
push @tests, { src => '3FF0000800000000', exp_hex => '+0x1.0000800000000p+0000', exp_dec => '+0d1.0000076293945312p+0000'   , convSpec => undef };
push @tests, { src => '3FF0000800000000', exp_hex => '+0x1.0000800000p+0000'   , exp_dec => '+0d1.0000076294p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0000800000000', exp_hex => '+0x1.0000800000000p+0000', exp_dec => '+0d1.0000076293945p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0000800000000', exp_hex => '-0x1.0000800000000p+0000', exp_dec => '-0d1.0000076293945312p+0000' };
push @tests, { src => 'BFF0000800000000', exp_hex => '-0x1.0000800000000p+0000', exp_dec => '-0d1.0000076293945312p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0000800000000', exp_hex => '-0x1.0000800000p+0000'   , exp_dec => '-0d1.0000076294p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0000800000000', exp_hex => '-0x1.0000800000000p+0000', exp_dec => '-0d1.0000076293945p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0008000000000', exp_hex => '+0x1.0008000000000p+0000', exp_dec => '+0d1.0001220703125000p+0000' };
push @tests, { src => '3FF0008000000000', exp_hex => '+0x1.0008000000000p+0000', exp_dec => '+0d1.0001220703125000p+0000'   , convSpec => undef };
push @tests, { src => '3FF0008000000000', exp_hex => '+0x1.0008000000p+0000'   , exp_dec => '+0d1.0001220703p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0008000000000', exp_hex => '+0x1.0008000000000p+0000', exp_dec => '+0d1.0001220703125p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0008000000000', exp_hex => '-0x1.0008000000000p+0000', exp_dec => '-0d1.0001220703125000p+0000' };
push @tests, { src => 'BFF0008000000000', exp_hex => '-0x1.0008000000000p+0000', exp_dec => '-0d1.0001220703125000p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0008000000000', exp_hex => '-0x1.0008000000p+0000'   , exp_dec => '-0d1.0001220703p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0008000000000', exp_hex => '-0x1.0008000000000p+0000', exp_dec => '-0d1.0001220703125p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0080000000000', exp_hex => '+0x1.0080000000000p+0000', exp_dec => '+0d1.0019531250000000p+0000' };
push @tests, { src => '3FF0080000000000', exp_hex => '+0x1.0080000000000p+0000', exp_dec => '+0d1.0019531250000000p+0000'   , convSpec => undef };
push @tests, { src => '3FF0080000000000', exp_hex => '+0x1.0080000000p+0000'   , exp_dec => '+0d1.0019531250p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0080000000000', exp_hex => '+0x1.0080000000000p+0000', exp_dec => '+0d1.0019531250000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0080000000000', exp_hex => '-0x1.0080000000000p+0000', exp_dec => '-0d1.0019531250000000p+0000' };
push @tests, { src => 'BFF0080000000000', exp_hex => '-0x1.0080000000000p+0000', exp_dec => '-0d1.0019531250000000p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0080000000000', exp_hex => '-0x1.0080000000p+0000'   , exp_dec => '-0d1.0019531250p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0080000000000', exp_hex => '-0x1.0080000000000p+0000', exp_dec => '-0d1.0019531250000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0800000000000', exp_hex => '+0x1.0800000000000p+0000', exp_dec => '+0d1.0312500000000000p+0000' };
push @tests, { src => '3FF0800000000000', exp_hex => '+0x1.0800000000000p+0000', exp_dec => '+0d1.0312500000000000p+0000'   , convSpec => undef };
push @tests, { src => '3FF0800000000000', exp_hex => '+0x1.0800000000p+0000'   , exp_dec => '+0d1.0312500000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF0800000000000', exp_hex => '+0x1.0800000000000p+0000', exp_dec => '+0d1.0312500000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF0800000000000', exp_hex => '-0x1.0800000000000p+0000', exp_dec => '-0d1.0312500000000000p+0000' };
push @tests, { src => 'BFF0800000000000', exp_hex => '-0x1.0800000000000p+0000', exp_dec => '-0d1.0312500000000000p+0000'   , convSpec => undef };
push @tests, { src => 'BFF0800000000000', exp_hex => '-0x1.0800000000p+0000'   , exp_dec => '-0d1.0312500000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF0800000000000', exp_hex => '-0x1.0800000000000p+0000', exp_dec => '-0d1.0312500000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF8000000000000', exp_hex => '+0x1.8000000000000p+0000', exp_dec => '+0d1.5000000000000000p+0000' };
push @tests, { src => '3FF8000000000000', exp_hex => '+0x1.8000000000000p+0000', exp_dec => '+0d1.5000000000000000p+0000'   , convSpec => undef };
push @tests, { src => '3FF8000000000000', exp_hex => '+0x1.8000000000p+0000'   , exp_dec => '+0d1.5000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FF8000000000000', exp_hex => '+0x1.8000000000000p+0000', exp_dec => '+0d1.5000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFF8000000000000', exp_hex => '-0x1.8000000000000p+0000', exp_dec => '-0d1.5000000000000000p+0000' };
push @tests, { src => 'BFF8000000000000', exp_hex => '-0x1.8000000000000p+0000', exp_dec => '-0d1.5000000000000000p+0000'   , convSpec => undef };
push @tests, { src => 'BFF8000000000000', exp_hex => '-0x1.8000000000p+0000'   , exp_dec => '-0d1.5000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFF8000000000000', exp_hex => '-0x1.8000000000000p+0000', exp_dec => '-0d1.5000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0000', exp_dec => '+0d1.9999999999999998p+0000' };
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0000', exp_dec => '+0d1.9999999999999998p+0000'   , convSpec => undef };
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2p+0000'              , exp_dec => '+0d2p+0000'                    , convSpec => 0     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.0p+0000'            , exp_dec => '+0d2.0p+0000'                  , convSpec => 1     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.00p+0000'           , exp_dec => '+0d2.00p+0000'                 , convSpec => 2     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.000p+0000'          , exp_dec => '+0d2.000p+0000'                , convSpec => 3     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.0000p+0000'         , exp_dec => '+0d2.0000p+0000'               , convSpec => 4     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.00000p+0000'        , exp_dec => '+0d2.00000p+0000'              , convSpec => 5     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.000000p+0000'       , exp_dec => '+0d2.000000p+0000'             , convSpec => 6     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.0000000p+0000'      , exp_dec => '+0d2.0000000p+0000'            , convSpec => 7     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.00000000p+0000'     , exp_dec => '+0d2.00000000p+0000'           , convSpec => 8     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.000000000p+0000'    , exp_dec => '+0d2.000000000p+0000'          , convSpec => 9     };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.0000000000p+0000'   , exp_dec => '+0d2.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.00000000000p+0000'  , exp_dec => '+0d2.00000000000p+0000'        , convSpec => 11    };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x2.000000000000p+0000' , exp_dec => '+0d2.000000000000p+0000'       , convSpec => 12    };  # extra: coverage for low number of digits
push @tests, { src => '3FFFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0000', exp_dec => '+0d2.0000000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0000', exp_dec => '-0d1.9999999999999998p+0000' };
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0000', exp_dec => '-0d1.9999999999999998p+0000'   , convSpec => undef };
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.0p+0000'            , exp_dec => '-0d2.0p+0000'                  , convSpec => 1     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.00p+0000'           , exp_dec => '-0d2.00p+0000'                 , convSpec => 2     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.000p+0000'          , exp_dec => '-0d2.000p+0000'                , convSpec => 3     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.0000p+0000'         , exp_dec => '-0d2.0000p+0000'               , convSpec => 4     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.00000p+0000'        , exp_dec => '-0d2.00000p+0000'              , convSpec => 5     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.000000p+0000'       , exp_dec => '-0d2.000000p+0000'             , convSpec => 6     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.0000000p+0000'      , exp_dec => '-0d2.0000000p+0000'            , convSpec => 7     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.00000000p+0000'     , exp_dec => '-0d2.00000000p+0000'           , convSpec => 8     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.000000000p+0000'    , exp_dec => '-0d2.000000000p+0000'          , convSpec => 9     };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.0000000000p+0000'   , exp_dec => '-0d2.0000000000p+0000'         , convSpec => 10    };
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.00000000000p+0000'  , exp_dec => '-0d2.00000000000p+0000'        , convSpec => 11    };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x2.000000000000p+0000' , exp_dec => '-0d2.000000000000p+0000'       , convSpec => 12    };  # extra: coverage for low number of digits
push @tests, { src => 'BFFFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0000', exp_dec => '-0d2.0000000000000p+0000'      , convSpec => 13    };

push @tests, { src => '3FF0FFFFFFFFFFFF', exp_hex => '+0x1.1p+0000'            , exp_dec => '+0d1.1p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF1FFFFFFFFFFFF', exp_hex => '+0x1.2p+0000'            , exp_dec => '+0d1.1p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF2FFFFFFFFFFFF', exp_hex => '+0x1.3p+0000'            , exp_dec => '+0d1.2p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF3FFFFFFFFFFFF', exp_hex => '+0x1.4p+0000'            , exp_dec => '+0d1.2p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF4FFFFFFFFFFFF', exp_hex => '+0x1.5p+0000'            , exp_dec => '+0d1.3p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF5FFFFFFFFFFFF', exp_hex => '+0x1.6p+0000'            , exp_dec => '+0d1.4p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF6FFFFFFFFFFFF', exp_hex => '+0x1.7p+0000'            , exp_dec => '+0d1.4p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF7FFFFFFFFFFFF', exp_hex => '+0x1.8p+0000'            , exp_dec => '+0d1.5p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF8FFFFFFFFFFFF', exp_hex => '+0x1.9p+0000'            , exp_dec => '+0d1.6p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FF9FFFFFFFFFFFF', exp_hex => '+0x1.ap+0000'            , exp_dec => '+0d1.6p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FFAFFFFFFFFFFFF', exp_hex => '+0x1.bp+0000'            , exp_dec => '+0d1.7p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FFBFFFFFFFFFFFF', exp_hex => '+0x1.cp+0000'            , exp_dec => '+0d1.7p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FFCFFFFFFFFFFFF', exp_hex => '+0x1.dp+0000'            , exp_dec => '+0d1.8p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FFDFFFFFFFFFFFF', exp_hex => '+0x1.ep+0000'            , exp_dec => '+0d1.9p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding
push @tests, { src => '3FFEFFFFFFFFFFFF', exp_hex => '+0x1.fp+0000'            , exp_dec => '+0d1.9p+0000'                  , convSpec => 1     };  # extra: coverage for msb rounding

push @tests, { src => '3FF000000FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000001FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000002FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000003FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000004FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000005FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000006FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000007FFFFFFF', exp_hex => '+0x1.00000p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000008FFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF000009FFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF00000AFFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF00000BFFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF00000CFFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF00000DFFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding
push @tests, { src => '3FF00000EFFFFFFF', exp_hex => '+0x1.00001p+0000'        , exp_dec => '+0d1.00000p+0000'              , convSpec => 5     };  # extra: coverage for lsb rounding


push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000000000000p+0001', exp_dec => '+0d1.0000000000000000p+0001' };
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000000000000p+0001', exp_dec => '+0d1.0000000000000000p+0001'   , convSpec => undef };
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0p+0001'            , exp_dec => '+0d1.0p+0001'                  , convSpec => 1     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.00p+0001'           , exp_dec => '+0d1.00p+0001'                 , convSpec => 2     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.000p+0001'          , exp_dec => '+0d1.000p+0001'                , convSpec => 3     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000p+0001'         , exp_dec => '+0d1.0000p+0001'               , convSpec => 4     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.00000p+0001'        , exp_dec => '+0d1.00000p+0001'              , convSpec => 5     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.000000p+0001'       , exp_dec => '+0d1.000000p+0001'             , convSpec => 6     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000000p+0001'      , exp_dec => '+0d1.0000000p+0001'            , convSpec => 7     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.00000000p+0001'     , exp_dec => '+0d1.00000000p+0001'           , convSpec => 8     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.000000000p+0001'    , exp_dec => '+0d1.000000000p+0001'          , convSpec => 9     };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000000000p+0001'   , exp_dec => '+0d1.0000000000p+0001'         , convSpec => 10    };
push @tests, { src => '4000000000000000', exp_hex => '+0x1.00000000000p+0001'  , exp_dec => '+0d1.00000000000p+0001'        , convSpec => 11    };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.000000000000p+0001' , exp_dec => '+0d1.000000000000p+0001'       , convSpec => 12    };  # extra: coverage for low number of digits
push @tests, { src => '4000000000000000', exp_hex => '+0x1.0000000000000p+0001', exp_dec => '+0d1.0000000000000p+0001'      , convSpec => 13    };
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000000000000p+0001', exp_dec => '-0d1.0000000000000000p+0001' };
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000000000000p+0001', exp_dec => '-0d1.0000000000000000p+0001'   , convSpec => undef };
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0p+0001'            , exp_dec => '-0d1.0p+0001'                  , convSpec => 1     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.00p+0001'           , exp_dec => '-0d1.00p+0001'                 , convSpec => 2     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.000p+0001'          , exp_dec => '-0d1.000p+0001'                , convSpec => 3     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000p+0001'         , exp_dec => '-0d1.0000p+0001'               , convSpec => 4     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.00000p+0001'        , exp_dec => '-0d1.00000p+0001'              , convSpec => 5     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.000000p+0001'       , exp_dec => '-0d1.000000p+0001'             , convSpec => 6     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000000p+0001'      , exp_dec => '-0d1.0000000p+0001'            , convSpec => 7     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.00000000p+0001'     , exp_dec => '-0d1.00000000p+0001'           , convSpec => 8     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.000000000p+0001'    , exp_dec => '-0d1.000000000p+0001'          , convSpec => 9     };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000000000p+0001'   , exp_dec => '-0d1.0000000000p+0001'         , convSpec => 10    };
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.00000000000p+0001'  , exp_dec => '-0d1.00000000000p+0001'        , convSpec => 11    };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.000000000000p+0001' , exp_dec => '-0d1.000000000000p+0001'       , convSpec => 12    };  # extra: coverage for low number of digits
push @tests, { src => 'C000000000000000', exp_hex => '-0x1.0000000000000p+0001', exp_dec => '-0d1.0000000000000p+0001'      , convSpec => 13    };

push @tests, { src => '4000000000000001', exp_hex => '+0x1.0000000000001p+0001', exp_dec => '+0d1.0000000000000002p+0001' };
push @tests, { src => '4000000000000001', exp_hex => '+0x1.0000000000001p+0001', exp_dec => '+0d1.0000000000000002p+0001'   , convSpec => undef };
push @tests, { src => '4000000000000001', exp_hex => '+0x1.0000000000p+0001'   , exp_dec => '+0d1.0000000000p+0001'         , convSpec => 10     };
push @tests, { src => '4000000000000001', exp_hex => '+0x1.0000000000001p+0001', exp_dec => '+0d1.0000000000000p+0001'      , convSpec => 13     };
push @tests, { src => 'C000000000000001', exp_hex => '-0x1.0000000000001p+0001', exp_dec => '-0d1.0000000000000002p+0001' };
push @tests, { src => 'C000000000000001', exp_hex => '-0x1.0000000000001p+0001', exp_dec => '-0d1.0000000000000002p+0001'   , convSpec => undef };
push @tests, { src => 'C000000000000001', exp_hex => '-0x1.0000000000p+0001'   , exp_dec => '-0d1.0000000000p+0001'         , convSpec => 10    };
push @tests, { src => 'C000000000000001', exp_hex => '-0x1.0000000000001p+0001', exp_dec => '-0d1.0000000000000p+0001'      , convSpec => 13    };

push @tests, { src => '400FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0001', exp_dec => '+0d1.9999999999999998p+0001' };
push @tests, { src => '400FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0001', exp_dec => '+0d1.9999999999999998p+0001'   , convSpec => undef };
push @tests, { src => '400FFFFFFFFFFFFF', exp_hex => '+0x2.0000000000p+0001'   , exp_dec => '+0d2.0000000000p+0001'         , convSpec => 10    };
push @tests, { src => '400FFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+0001', exp_dec => '+0d2.0000000000000p+0001'      , convSpec => 13    };
push @tests, { src => 'C00FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0001', exp_dec => '-0d1.9999999999999998p+0001' };
push @tests, { src => 'C00FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0001', exp_dec => '-0d1.9999999999999998p+0001'   , convSpec => undef };
push @tests, { src => 'C00FFFFFFFFFFFFF', exp_hex => '-0x2.0000000000p+0001'   , exp_dec => '-0d2.0000000000p+0001'         , convSpec => 10    };
push @tests, { src => 'C00FFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+0001', exp_dec => '-0d2.0000000000000p+0001'      , convSpec => 13    };

push @tests, { src => '7FE0000000000000', exp_hex => '+0x1.0000000000000p+1023', exp_dec => '+0d1.0000000000000000p+1023' };
push @tests, { src => '7FE0000000000000', exp_hex => '+0x1.0000000000000p+1023', exp_dec => '+0d1.0000000000000000p+1023'   , convSpec => undef };
push @tests, { src => '7FE0000000000000', exp_hex => '+0x1.0000000000p+1023'   , exp_dec => '+0d1.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => '7FE0000000000000', exp_hex => '+0x1.0000000000000p+1023', exp_dec => '+0d1.0000000000000p+1023'      , convSpec => 13    };
push @tests, { src => 'FFE0000000000000', exp_hex => '-0x1.0000000000000p+1023', exp_dec => '-0d1.0000000000000000p+1023' };
push @tests, { src => 'FFE0000000000000', exp_hex => '-0x1.0000000000000p+1023', exp_dec => '-0d1.0000000000000000p+1023'   , convSpec => undef };
push @tests, { src => 'FFE0000000000000', exp_hex => '-0x1.0000000000p+1023'   , exp_dec => '-0d1.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => 'FFE0000000000000', exp_hex => '-0x1.0000000000000p+1023', exp_dec => '-0d1.0000000000000p+1023'      , convSpec => 13    };

push @tests, { src => '7FE0000000000001', exp_hex => '+0x1.0000000000001p+1023', exp_dec => '+0d1.0000000000000002p+1023' };
push @tests, { src => '7FE0000000000001', exp_hex => '+0x1.0000000000001p+1023', exp_dec => '+0d1.0000000000000002p+1023'   , convSpec => undef };
push @tests, { src => '7FE0000000000001', exp_hex => '+0x1.0000000000p+1023'   , exp_dec => '+0d1.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => '7FE0000000000001', exp_hex => '+0x1.0000000000001p+1023', exp_dec => '+0d1.0000000000000p+1023'      , convSpec => 13    };
push @tests, { src => 'FFE0000000000001', exp_hex => '-0x1.0000000000001p+1023', exp_dec => '-0d1.0000000000000002p+1023' };
push @tests, { src => 'FFE0000000000001', exp_hex => '-0x1.0000000000001p+1023', exp_dec => '-0d1.0000000000000002p+1023'   , convSpec => undef };
push @tests, { src => 'FFE0000000000001', exp_hex => '-0x1.0000000000p+1023'   , exp_dec => '-0d1.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => 'FFE0000000000001', exp_hex => '-0x1.0000000000001p+1023', exp_dec => '-0d1.0000000000000p+1023'      , convSpec => 13    };

push @tests, { src => '7FEFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+1023', exp_dec => '+0d1.9999999999999998p+1023' };
push @tests, { src => '7FEFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+1023', exp_dec => '+0d1.9999999999999998p+1023'   , convSpec => undef };
push @tests, { src => '7FEFFFFFFFFFFFFF', exp_hex => '+0x2.0000000000p+1023'   , exp_dec => '+0d2.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => '7FEFFFFFFFFFFFFF', exp_hex => '+0x1.fffffffffffffp+1023', exp_dec => '+0d2.0000000000000p+1023'      , convSpec => 13    };
push @tests, { src => 'FFEFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+1023', exp_dec => '-0d1.9999999999999998p+1023' };
push @tests, { src => 'FFEFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+1023', exp_dec => '-0d1.9999999999999998p+1023'   , convSpec => undef };
push @tests, { src => 'FFEFFFFFFFFFFFFF', exp_hex => '-0x2.0000000000p+1023'   , exp_dec => '-0d2.0000000000p+1023'         , convSpec => 10    };
push @tests, { src => 'FFEFFFFFFFFFFFFF', exp_hex => '-0x1.fffffffffffffp+1023', exp_dec => '-0d2.0000000000000p+1023'      , convSpec => 13    };

push @tests, { src => '7FF0000000000000', exp_hex => '+0x1.#INF000000000p+0000', exp_dec => '+0d1.#INF000000000000p+0000' };
push @tests, { src => '7FF0000000000000', exp_hex => '+0x1.#INF000000000p+0000', exp_dec => '+0d1.#INF000000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FF0000000000000', exp_hex => '+0x1.#INFp+0000'         , exp_dec => '+0d1.#INFp+0000'               , convSpec => 3     };
push @tests, { src => '7FF0000000000000', exp_hex => '+0x1.#INF00p+0000'       , exp_dec => '+0d1.#INF00p+0000'             , convSpec => 6     };
push @tests, { src => '7FF0000000000000', exp_hex => '+0x1.#INF000000000p+0000', exp_dec => '+0d1.#INF000000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFF0000000000000', exp_hex => '-0x1.#INF000000000p+0000', exp_dec => '-0d1.#INF000000000000p+0000' };
push @tests, { src => 'FFF0000000000000', exp_hex => '-0x1.#INF000000000p+0000', exp_dec => '-0d1.#INF000000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFF0000000000000', exp_hex => '-0x1.#INFp+0000'         , exp_dec => '-0d1.#INFp+0000'               , convSpec => 3     };
push @tests, { src => 'FFF0000000000000', exp_hex => '-0x1.#INF00p+0000'       , exp_dec => '-0d1.#INF00p+0000'             , convSpec => 6     };
push @tests, { src => 'FFF0000000000000', exp_hex => '-0x1.#INF000000000p+0000', exp_dec => '-0d1.#INF000000000p+0000'      , convSpec => 13    };

push @tests, { src => '7FF0000000000001', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000000p+0000' };
push @tests, { src => '7FF0000000000001', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FF0000000000001', exp_hex => '+0x1.#SNANp+0000'        , exp_dec => '+0d1.#SNANp+0000'              , convSpec => 3     };
push @tests, { src => '7FF0000000000001', exp_hex => '+0x1.#SNAN0p+0000'       , exp_dec => '+0d1.#SNAN0p+0000'             , convSpec => 6     };
push @tests, { src => '7FF0000000000001', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFF0000000000001', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000000p+0000' };
push @tests, { src => 'FFF0000000000001', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFF0000000000001', exp_hex => '-0x1.#SNANp+0000'        , exp_dec => '-0d1.#SNANp+0000'              , convSpec => 3     };
push @tests, { src => 'FFF0000000000001', exp_hex => '-0x1.#SNAN0p+0000'       , exp_dec => '-0d1.#SNAN0p+0000'             , convSpec => 6     };
push @tests, { src => 'FFF0000000000001', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000p+0000'      , convSpec => 13    };

push @tests, { src => '7FF7FFFFFFFFFFFF', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000000p+0000' };
push @tests, { src => '7FF7FFFFFFFFFFFF', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FF7FFFFFFFFFFFF', exp_hex => '+0x1.#SNANp+0000'        , exp_dec => '+0d1.#SNANp+0000'              , convSpec => 3     };
push @tests, { src => '7FF7FFFFFFFFFFFF', exp_hex => '+0x1.#SNAN0p+0000'       , exp_dec => '+0d1.#SNAN0p+0000'             , convSpec => 6     };
push @tests, { src => '7FF7FFFFFFFFFFFF', exp_hex => '+0x1.#SNAN00000000p+0000', exp_dec => '+0d1.#SNAN00000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFF7FFFFFFFFFFFF', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000000p+0000' };
push @tests, { src => 'FFF7FFFFFFFFFFFF', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFF7FFFFFFFFFFFF', exp_hex => '-0x1.#SNANp+0000'        , exp_dec => '-0d1.#SNANp+0000'              , convSpec => 3     };
push @tests, { src => 'FFF7FFFFFFFFFFFF', exp_hex => '-0x1.#SNAN0p+0000'       , exp_dec => '-0d1.#SNAN0p+0000'             , convSpec => 6     };
push @tests, { src => 'FFF7FFFFFFFFFFFF', exp_hex => '-0x1.#SNAN00000000p+0000', exp_dec => '-0d1.#SNAN00000000p+0000'      , convSpec => 13    };

push @tests, { src => '7FF8000000000000', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000' };
push @tests, { src => '7FF8000000000000', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FF8000000000000', exp_hex => '+0x1.#QNANp+0000'        , exp_dec => '+0d1.#QNANp+0000'              , convSpec => 3     };
push @tests, { src => '7FF8000000000000', exp_hex => '+0x1.#QNAN0p+0000'       , exp_dec => '+0d1.#QNAN0p+0000'             , convSpec => 6     };
push @tests, { src => '7FF8000000000000', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFF8000000000000', exp_hex => '-0x1.#IND000000000p+0000', exp_dec => '-0d1.#IND000000000000p+0000' };
push @tests, { src => 'FFF8000000000000', exp_hex => '-0x1.#IND000000000p+0000', exp_dec => '-0d1.#IND000000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFF8000000000000', exp_hex => '-0x1.#INDp+0000'         , exp_dec => '-0d1.#INDp+0000'               , convSpec => 3     };
push @tests, { src => 'FFF8000000000000', exp_hex => '-0x1.#IND00p+0000'       , exp_dec => '-0d1.#IND00p+0000'             , convSpec => 6     };
push @tests, { src => 'FFF8000000000000', exp_hex => '-0x1.#IND000000000p+0000', exp_dec => '-0d1.#IND000000000p+0000'      , convSpec => 13    };

push @tests, { src => '7FF8000000000001', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000' };
push @tests, { src => '7FF8000000000001', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FF8000000000001', exp_hex => '+0x1.#QNANp+0000'        , exp_dec => '+0d1.#QNANp+0000'              , convSpec => 3     };
push @tests, { src => '7FF8000000000001', exp_hex => '+0x1.#QNAN0p+0000'       , exp_dec => '+0d1.#QNAN0p+0000'             , convSpec => 6     };
push @tests, { src => '7FF8000000000001', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFF8000000000001', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000000p+0000' };
push @tests, { src => 'FFF8000000000001', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFF8000000000001', exp_hex => '-0x1.#QNANp+0000'        , exp_dec => '-0d1.#QNANp+0000'              , convSpec => 3     };
push @tests, { src => 'FFF8000000000001', exp_hex => '-0x1.#QNAN0p+0000'       , exp_dec => '-0d1.#QNAN0p+0000'             , convSpec => 6     };
push @tests, { src => 'FFF8000000000001', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000p+0000'      , convSpec => 13    };

push @tests, { src => '7FFFFFFFFFFFFFFF', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000' };
push @tests, { src => '7FFFFFFFFFFFFFFF', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => '7FFFFFFFFFFFFFFF', exp_hex => '+0x1.#QNANp+0000'        , exp_dec => '+0d1.#QNANp+0000'              , convSpec => 3     };
push @tests, { src => '7FFFFFFFFFFFFFFF', exp_hex => '+0x1.#QNAN0p+0000'       , exp_dec => '+0d1.#QNAN0p+0000'             , convSpec => 6     };
push @tests, { src => '7FFFFFFFFFFFFFFF', exp_hex => '+0x1.#QNAN00000000p+0000', exp_dec => '+0d1.#QNAN00000000p+0000'      , convSpec => 13    };
push @tests, { src => 'FFFFFFFFFFFFFFFF', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000000p+0000' };
push @tests, { src => 'FFFFFFFFFFFFFFFF', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000000p+0000'   , convSpec => undef };
push @tests, { src => 'FFFFFFFFFFFFFFFF', exp_hex => '-0x1.#QNANp+0000'        , exp_dec => '-0d1.#QNANp+0000'              , convSpec => 3     };
push @tests, { src => 'FFFFFFFFFFFFFFFF', exp_hex => '-0x1.#QNAN0p+0000'       , exp_dec => '-0d1.#QNAN0p+0000'             , convSpec => 6     };
push @tests, { src => 'FFFFFFFFFFFFFFFF', exp_hex => '-0x1.#QNAN00000000p+0000', exp_dec => '-0d1.#QNAN00000000p+0000'      , convSpec => 13    };

plan tests => 2 * scalar @tests;


fptest( $_ ) foreach (@tests);
exit;
