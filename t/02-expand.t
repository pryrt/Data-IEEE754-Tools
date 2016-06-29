########################################################################
# Verifies proper functioning of expand_ieee754 and its config options
#       * verifies default values in %EXPAND_OPTS
#       * verifies all combinations of blank vs default for passing the options
#       * verifies options can be passed as any of
#           expand_ieee754( arg, opt => val, ... )
#           expand_ieee754( arg, {opt => val, ...} )
#           set %EXPAND_OPTS; call expand_ieee754( arg )
#       * verifies all combinations of (bin/dec/hex) x (reduce) x (drawFraction)
#       * verifies all of the bases qw/binary bin b decimal dec d hexadecimal hex h x/
#       * verifies pos and neg values
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-06-28 15:20:03 -0700 (Tue, 28 Jun 2016) $
#   $Revision: 197 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/02-expand.t $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/02-expand.t 197 2016-06-28 22:20:03Z pryrtmx $
#   $Id: 02-expand.t 197 2016-06-28 22:20:03Z pryrtmx $
########################################################################
use 5.008005;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:expand :options/;

my @tests = ();

# all 36 combos of reducable negative { 4x(_,bin,dec,hex), 3x(_,0,1), 3x(_,0,1) }
#   This makes sure the defaults work in every column
push @tests, { args => [-1.5,                                              ], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5,                             drawFraction => 0], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5,                             drawFraction => 1], expect => "  [     0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**0) = -1.5\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-1.5,                reduce => 0                   ], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5,                reduce => 0, drawFraction => 0], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5,                reduce => 0, drawFraction => 1], expect => "  [     0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**0) = -1.5\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-1.5,                reduce => 1                   ], expect => "-0b1.1 * (2**0)" };
push @tests, { args => [-1.5,                reduce => 1, drawFraction => 0], expect => "-0b1.1 * (2**0)" };
push @tests, { args => [-1.5,                reduce => 1, drawFraction => 1], expect => "  [     0b01 ]\n- [ 1 + ---- ] * (2**0) = -1.5\n  [     0b10 ]" };
push @tests, { args => [-1.5, base => 'bin',                               ], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin',              drawFraction => 0], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin',              drawFraction => 1], expect => "  [     0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**0) = -1.5\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-1.5, base => 'bin', reduce => 0                   ], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin', reduce => 0, drawFraction => 0], expect => "-0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin', reduce => 0, drawFraction => 1], expect => "  [     0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**0) = -1.5\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-1.5, base => 'bin', reduce => 1                   ], expect => "-0b1.1 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin', reduce => 1, drawFraction => 0], expect => "-0b1.1 * (2**0)" };
push @tests, { args => [-1.5, base => 'bin', reduce => 1, drawFraction => 1], expect => "  [     0b01 ]\n- [ 1 + ---- ] * (2**0) = -1.5\n  [     0b10 ]" };
push @tests, { args => [-1.5, base => 'dec',                               ], expect => "-1.500_000_000_000_000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec',              drawFraction => 0], expect => "-1.500_000_000_000_000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec',              drawFraction => 1], expect => "  [     2,251,799,813,685,248 ]\n- [ 1 + --------------------- ] * (2**0) = -1.5\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [-1.5, base => 'dec', reduce => 0,                  ], expect => "-1.500_000_000_000_000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec', reduce => 0, drawFraction => 0], expect => "-1.500_000_000_000_000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec', reduce => 0, drawFraction => 1], expect => "  [     2,251,799,813,685,248 ]\n- [ 1 + --------------------- ] * (2**0) = -1.5\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [-1.5, base => 'dec', reduce => 1,                  ], expect => "-1.5 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec', reduce => 1, drawFraction => 0], expect => "-1.5 * (2**0)" };
push @tests, { args => [-1.5, base => 'dec', reduce => 1, drawFraction => 1], expect => "  [     1 ]\n- [ 1 + - ] * (2**0) = -1.5\n  [     2 ]" };
push @tests, { args => [-1.5, base => 'hex',                               ], expect => "-0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex',              drawFraction => 0], expect => "-0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex',              drawFraction => 1], expect => "  [     0x0800_0000_0000_00 ]\n- [ 1 + ------------------- ] * (2**0) = -1.5\n  [     0x1000_0000_0000_00 ]" };
push @tests, { args => [-1.5, base => 'hex', reduce => 0,                  ], expect => "-0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex', reduce => 0, drawFraction => 0], expect => "-0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex', reduce => 0, drawFraction => 1], expect => "  [     0x0800_0000_0000_00 ]\n- [ 1 + ------------------- ] * (2**0) = -1.5\n  [     0x1000_0000_0000_00 ]" };
push @tests, { args => [-1.5, base => 'hex', reduce => 1                   ], expect => "-0x1.8 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex', reduce => 1, drawFraction => 0], expect => "-0x1.8 * (2**0)" };
push @tests, { args => [-1.5, base => 'hex', reduce => 1, drawFraction => 1], expect => "  [     0x08 ]\n- [ 1 + ---- ] * (2**0) = -1.5\n  [     0x10 ]" };

# change sign; don't need the "blanks" for the options any more, because those just define whether the internal options strings are chosen correctly, and the sign of the value doesn't affect that logic
push @tests, { args => [+1.5, base => 'bin', reduce => 0, drawFraction => 0], expect => "+0b1.1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 * (2**0)" };
push @tests, { args => [+1.5, base => 'bin', reduce => 0, drawFraction => 1], expect => "  [     0b0100_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]\n+ [ 1 + -------------------------------------------------------------------- ] * (2**0) = 1.5\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [+1.5, base => 'bin', reduce => 1, drawFraction => 0], expect => "+0b1.1 * (2**0)" };
push @tests, { args => [+1.5, base => 'bin', reduce => 1, drawFraction => 1], expect => "  [     0b01 ]\n+ [ 1 + ---- ] * (2**0) = 1.5\n  [     0b10 ]" };
push @tests, { args => [+1.5, base => 'dec', reduce => 0, drawFraction => 0], expect => "+1.500_000_000_000_000_0 * (2**0)" };
push @tests, { args => [+1.5, base => 'dec', reduce => 0, drawFraction => 1], expect => "  [     2,251,799,813,685,248 ]\n+ [ 1 + --------------------- ] * (2**0) = 1.5\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [+1.5, base => 'dec', reduce => 1, drawFraction => 0], expect => "+1.5 * (2**0)" };
push @tests, { args => [+1.5, base => 'dec', reduce => 1, drawFraction => 1], expect => "  [     1 ]\n+ [ 1 + - ] * (2**0) = 1.5\n  [     2 ]" };
push @tests, { args => [+1.5, base => 'hex', reduce => 0, drawFraction => 0], expect => "+0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [+1.5, base => 'hex', reduce => 0, drawFraction => 1], expect => "  [     0x0800_0000_0000_00 ]\n+ [ 1 + ------------------- ] * (2**0) = 1.5\n  [     0x1000_0000_0000_00 ]" };
push @tests, { args => [+1.5, base => 'hex', reduce => 1, drawFraction => 0], expect => "+0x1.8 * (2**0)" };
push @tests, { args => [+1.5, base => 'hex', reduce => 1, drawFraction => 1], expect => "  [     0x08 ]\n+ [ 1 + ---- ] * (2**0) = 1.5\n  [     0x10 ]" };

# try non-reducable, both signs (12 combos each)
push @tests, { args => [+0.16, base => 'bin', drawFraction => 0, reduce => 0], expect => "+0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [+0.16, base => 'bin', drawFraction => 0, reduce => 1], expect => "+0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [+0.16, base => 'bin', drawFraction => 1, reduce => 0], expect => "  [     0b0010_0011_1101_0111_0000_1010_0011_1101_0111_0000_1010_0011_1101_1 ]\n+ [ 1 + -------------------------------------------------------------------- ] * (2**-3) = 0.16\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [+0.16, base => 'bin', drawFraction => 1, reduce => 1], expect => "  [     0b0010_0011_1101_0111_0000_1010_0011_1101_0111_0000_1010_0011_1101_1 ]\n+ [ 1 + -------------------------------------------------------------------- ] * (2**-3) = 0.16\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [+0.16, base => 'dec', drawFraction => 0, reduce => 0], expect => "+1.280_000_000_000_000_0 * (2**-3)" };
push @tests, { args => [+0.16, base => 'dec', drawFraction => 0, reduce => 1], expect => "+1.28 * (2**-3)" };
push @tests, { args => [+0.16, base => 'dec', drawFraction => 1, reduce => 0], expect => "  [     1,261,007,895,663,739 ]\n+ [ 1 + --------------------- ] * (2**-3) = 0.16\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [+0.16, base => 'dec', drawFraction => 1, reduce => 1], expect => "  [     1,261,007,895,663,739 ]\n+ [ 1 + --------------------- ] * (2**-3) = 0.16\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [+0.16, base => 'hex', drawFraction => 0, reduce => 0], expect => "+0x1.47AE_147A_E147_B * (2**-3)" };
push @tests, { args => [+0.16, base => 'hex', drawFraction => 0, reduce => 1], expect => "+0x1.47AE_147A_E147_B * (2**-3)" };
push @tests, { args => [+0.16, base => 'hex', drawFraction => 1, reduce => 0], expect => "  [     0x047A_E147_AE14_7B ]\n+ [ 1 + ------------------- ] * (2**-3) = 0.16\n  [     0x1000_0000_0000_00 ]" };
push @tests, { args => [+0.16, base => 'hex', drawFraction => 1, reduce => 1], expect => "  [     0x047A_E147_AE14_7B ]\n+ [ 1 + ------------------- ] * (2**-3) = 0.16\n  [     0x1000_0000_0000_00 ]" };

push @tests, { args => [-0.16, base => 'bin', drawFraction => 0, reduce => 0], expect => "-0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [-0.16, base => 'bin', drawFraction => 0, reduce => 1], expect => "-0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [-0.16, base => 'bin', drawFraction => 1, reduce => 0], expect => "  [     0b0010_0011_1101_0111_0000_1010_0011_1101_0111_0000_1010_0011_1101_1 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**-3) = -0.16\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-0.16, base => 'bin', drawFraction => 1, reduce => 1], expect => "  [     0b0010_0011_1101_0111_0000_1010_0011_1101_0111_0000_1010_0011_1101_1 ]\n- [ 1 + -------------------------------------------------------------------- ] * (2**-3) = -0.16\n  [     0b1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0 ]" };
push @tests, { args => [-0.16, base => 'dec', drawFraction => 0, reduce => 0], expect => "-1.280_000_000_000_000_0 * (2**-3)" };
push @tests, { args => [-0.16, base => 'dec', drawFraction => 0, reduce => 1], expect => "-1.28 * (2**-3)" };
push @tests, { args => [-0.16, base => 'dec', drawFraction => 1, reduce => 0], expect => "  [     1,261,007,895,663,739 ]\n- [ 1 + --------------------- ] * (2**-3) = -0.16\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [-0.16, base => 'dec', drawFraction => 1, reduce => 1], expect => "  [     1,261,007,895,663,739 ]\n- [ 1 + --------------------- ] * (2**-3) = -0.16\n  [     4,503,599,627,370,496 ]" };
push @tests, { args => [-0.16, base => 'hex', drawFraction => 0, reduce => 0], expect => "-0x1.47AE_147A_E147_B * (2**-3)" };
push @tests, { args => [-0.16, base => 'hex', drawFraction => 0, reduce => 1], expect => "-0x1.47AE_147A_E147_B * (2**-3)" };
push @tests, { args => [-0.16, base => 'hex', drawFraction => 1, reduce => 0], expect => "  [     0x047A_E147_AE14_7B ]\n- [ 1 + ------------------- ] * (2**-3) = -0.16\n  [     0x1000_0000_0000_00 ]" };
push @tests, { args => [-0.16, base => 'hex', drawFraction => 1, reduce => 1], expect => "  [     0x047A_E147_AE14_7B ]\n- [ 1 + ------------------- ] * (2**-3) = -0.16\n  [     0x1000_0000_0000_00 ]" };

# try each of the possible qw/binary bin b decimal dec d hexadecimal hex h x/
#   only need one of each, because sign, drawFraction, and reduce are irrelevant to the processing of the option{base} into the internal single-character version
push @tests, { args => [+0.16, base => 'binary'     ], expect => "+0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [+0.16, base => 'bin'        ], expect => "+0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [+0.16, base => 'b'          ], expect => "+0b1.0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 * (2**-3)" };
push @tests, { args => [-0.16, base => 'decimal'    ], expect => "-1.280_000_000_000_000_0 * (2**-3)" };
push @tests, { args => [-0.16, base => 'dec'        ], expect => "-1.280_000_000_000_000_0 * (2**-3)" };
push @tests, { args => [-0.16, base => 'd'          ], expect => "-1.280_000_000_000_000_0 * (2**-3)" };
push @tests, { args => [+1.50, base => 'hexadecimal'], expect => "+0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [+1.50, base => 'hex'        ], expect => "+0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [+1.50, base => 'h'          ], expect => "+0x1.8000_0000_0000_0 * (2**0)" };
push @tests, { args => [+1.50, base => 'x'          ], expect => "+0x1.8000_0000_0000_0 * (2**0)" };

plan tests => 3 + 3 * scalar @tests;

# verify the default option list is correct
is( $EXPAND_OPTS{base}          , 'b' , "default options{base}" );
is( $EXPAND_OPTS{drawFraction}  , 0   , "default options{drawFraction}" );
is( $EXPAND_OPTS{reduce}        , 0   , "default options{reduce}" );

foreach my $test ( @tests ) {
    my ($val, @args) = @{ $test->{args} };
    my $name = "expand_ieee754(" . join(', ', $val, @args) . ")";

    # verify arguments as plain hash
    is( expand_ieee754( $val,   @args   ), $test->{expect} , $name );

    # verify arguments as hashref
    is( expand_ieee754( $val, { @args } ), $test->{expect} , $name . " {hashref}" );

    # verify arguments by overriding appropriate EXPAND_OPTS elements
    my %hash = %{ +{ @args } };
    foreach my $opt (keys %EXPAND_OPTS) {
        $EXPAND_OPTS{$opt} = $hash{$opt} if exists $hash{$opt};
    }
    is( expand_ieee754( $val            ), $test->{expect} , $name . " {options}" );

    # restore defaults
    $EXPAND_OPTS{base} = 'b';
    $EXPAND_OPTS{drawFraction} = 0;
    $EXPAND_OPTS{reduce} = 0;
}

exit;
