########################################################################
# Verifies the following functions:
#   :ulp
#       nextup(v)
#       nextdown(v)
#   (other :ulp tests in other .t files)
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-07-07 13:37:19 -0700 (Thu, 07 Jul 2016) $
#   $Revision: 222 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/04-nextupdown.t $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/04-nextupdown.t 222 2016-07-07 20:37:19Z pryrtmx $
#   $Id: 04-nextupdown.t 222 2016-07-07 20:37:19Z pryrtmx $
########################################################################
use 5.008005;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :ulp :floatingpoint/;

my ($h,$u,$v);

sub fntest {
    my $fn = shift;
    my $f = \&{$fn};                        # strict refs doesn't allow &$fn(arg) directly
    my $h = shift;
    my $x = shift;
    my $v = hexstr754_to_double($h);
    my $u = $f->($v); # works strict refs    # &$fn($v) and $fn->($v) fail strict refs; &$f($v) would also work
    $u = '<undef>' unless defined $u;
    my $n = shift || "$fn(0x$h => $v)";
    my $tada = shift;
    my $r = undef;
    note '';
    note "===== ${n} =====";
    if($tada) {
        TODO: {
            local $TODO = $tada;
            if( $u =~ /(?:NAN|INF|IND)/i or $x =~ /(?:NAN|INF|IND)/i ) {
                $r = cmp_ok( $u, 'eq', $x, $n );
            } else {
                $r = cmp_ok( $u, '==', $x, $n );
            }
        }
    } else {
            if( $u =~ /(?:NAN|INF|IND)/i or $x =~ /(?:NAN|INF|IND)/i ) {
                $r = cmp_ok( $u, 'eq', $x, $n );
            } else {
                $r = cmp_ok( $u, '==', $x, $n );
            }
    }
    unless($r) {
        diag '';
        diag "$n:";
        diag sprintf "ORIGINAL: hex(%-30s) = %s", to_dec_floatingpoint($v), $h;
        diag sprintf "EXPECT:   hex(%-30s) = %s", to_dec_floatingpoint($x), hexstr754_from_double($x);
        diag sprintf "ANSWER:   hex(%-30s) = %s", to_dec_floatingpoint($u), hexstr754_from_double($u);
        diag '';
    }
    note '-'x80;
}

my @tests = ();

# now test all the nextup()
push @tests, { func => 'nextup', arg => '0000000000000000', expect => hexstr754_to_double('0000000000000001'),    name => "nextup(POS_ZERO)" };
push @tests, { func => 'nextup', arg => '8000000000000000', expect => hexstr754_to_double('0000000000000001'),    name => "nextup(NEG_ZERO)" };
push @tests, { func => 'nextup', arg => '0000000000000001', expect => hexstr754_to_double('0000000000000002'),    name => "nextup(POS_DENORM_1)" };
push @tests, { func => 'nextup', arg => '8000000000000001', expect => hexstr754_to_double('8000000000000000'),    name => "nextup(NEG_DENORM_1)" };
push @tests, { func => 'nextup', arg => '000FFFFFFFFFFFFF', expect => hexstr754_to_double('0010000000000000'),    name => "nextup(POS_DENORM_F)" };
push @tests, { func => 'nextup', arg => '800FFFFFFFFFFFFF', expect => hexstr754_to_double('800FFFFFFFFFFFFE'),    name => "nextup(NEG_DENORM_F)" };
push @tests, { func => 'nextup', arg => '0010000000000000', expect => hexstr754_to_double('0010000000000001'),    name => "nextup(POS_NORM_x1x0)" };
push @tests, { func => 'nextup', arg => '8010000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextup(NEG_NORM_x1x0)" };
push @tests, { func => 'nextup', arg => '001FFFFFFFFFFFFF', expect => hexstr754_to_double('0020000000000000'),    name => "nextup(POS_NORM_x1xF)" };
push @tests, { func => 'nextup', arg => '801FFFFFFFFFFFFF', expect => hexstr754_to_double('801FFFFFFFFFFFFE'),    name => "nextup(NEG_NORM_x1xF)" };
push @tests, { func => 'nextup', arg => '034FFFFFFFFFFFFF', expect => hexstr754_to_double('0350000000000000'),    name => "nextup(POS_NORM_x34F): last denormal ulp" };
push @tests, { func => 'nextup', arg => '834FFFFFFFFFFFFF', expect => hexstr754_to_double('834FFFFFFFFFFFFE'),    name => "nextup(NEG_NORM_x34F): last denormal ulp" };
push @tests, { func => 'nextup', arg => '0350000000000000', expect => hexstr754_to_double('0350000000000001'),    name => "nextup(POS_NORM_x350): first normal ulp" };
push @tests, { func => 'nextup', arg => '8350000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextup(NEG_NORM_x350): first normal ulp" };
push @tests, { func => 'nextup', arg => '7FE0000000000000', expect => hexstr754_to_double('7FE0000000000001'),    name => "nextup(POS_NORM_xFx0)" };
push @tests, { func => 'nextup', arg => 'FFE0000000000000', expect => hexstr754_to_double('FFDFFFFFFFFFFFFF'),    name => "nextup(NEG_NORM_xFx0)" };
push @tests, { func => 'nextup', arg => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF0000000000000'),    name => "nextup(POS_NORM_xFxF)" };
push @tests, { func => 'nextup', arg => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFE'),    name => "nextup(NEG_NORM_xFxF)" };
push @tests, { func => 'nextup', arg => '7FF0000000000000', expect => hexstr754_to_double('7FF0000000000000'),    name => "nextup(POS_INF)" };
push @tests, { func => 'nextup', arg => 'FFF0000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextup(NEG_INF)" };
push @tests, { func => 'nextup', arg => '7FF0000000000001', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextup(POS_SNAN_01)" };
push @tests, { func => 'nextup', arg => 'FFF0000000000001', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextup(NEG_SNAN_01)" };
push @tests, { func => 'nextup', arg => '7FF7FFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextup(POS_SNAN_7F)" };
push @tests, { func => 'nextup', arg => 'FFF7FFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextup(NEG_SNAN_7F)" };
push @tests, { func => 'nextup', arg => '7FF8000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextup(POS_IND_80)" };
push @tests, { func => 'nextup', arg => 'FFF8000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextup(NEG_IND_80)" };
push @tests, { func => 'nextup', arg => '7FF8000000000001', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextup(POS_QNAN_81)" };
push @tests, { func => 'nextup', arg => 'FFF8000000000001', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextup(NEG_QNAN_81)" };
push @tests, { func => 'nextup', arg => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextup(POS_QNAN_FF)" };
push @tests, { func => 'nextup', arg => 'FFFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextup(NEG_QNAN_FF)" };

# now test all the nextdown()
push @tests, { func => 'nextdown', arg => '0000000000000000', expect => hexstr754_to_double('8000000000000001'),    name => "nextdown(POS_ZERO)" };
push @tests, { func => 'nextdown', arg => '8000000000000000', expect => hexstr754_to_double('8000000000000001'),    name => "nextdown(NEG_ZERO)" };
push @tests, { func => 'nextdown', arg => '0000000000000001', expect => hexstr754_to_double('0000000000000000'),    name => "nextdown(POS_DENORM_1)" };
push @tests, { func => 'nextdown', arg => '8000000000000001', expect => hexstr754_to_double('8000000000000002'),    name => "nextdown(NEG_DENORM_1)" };
push @tests, { func => 'nextdown', arg => '000FFFFFFFFFFFFF', expect => hexstr754_to_double('000FFFFFFFFFFFFE'),    name => "nextdown(POS_DENORM_F)" };
push @tests, { func => 'nextdown', arg => '800FFFFFFFFFFFFF', expect => hexstr754_to_double('8010000000000000'),    name => "nextdown(NEG_DENORM_F)" };
push @tests, { func => 'nextdown', arg => '0010000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextdown(POS_NORM_x1x0)" };
push @tests, { func => 'nextdown', arg => '8010000000000000', expect => hexstr754_to_double('8010000000000001'),    name => "nextdown(NEG_NORM_x1x0)" };
push @tests, { func => 'nextdown', arg => '001FFFFFFFFFFFFF', expect => hexstr754_to_double('001FFFFFFFFFFFFE'),    name => "nextdown(POS_NORM_x1xF)" };
push @tests, { func => 'nextdown', arg => '801FFFFFFFFFFFFF', expect => hexstr754_to_double('8020000000000000'),    name => "nextdown(NEG_NORM_x1xF)" };
push @tests, { func => 'nextdown', arg => '034FFFFFFFFFFFFF', expect => hexstr754_to_double('034FFFFFFFFFFFFE'),    name => "nextdown(POS_NORM_x34F): last denormal ulp" };
push @tests, { func => 'nextdown', arg => '834FFFFFFFFFFFFF', expect => hexstr754_to_double('8350000000000000'),    name => "nextdown(NEG_NORM_x34F): last denormal ulp" };
push @tests, { func => 'nextdown', arg => '0350000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextdown(POS_NORM_x350): first normal ulp" };
push @tests, { func => 'nextdown', arg => '8350000000000000', expect => hexstr754_to_double('8350000000000001'),    name => "nextdown(NEG_NORM_x350): first normal ulp" };
push @tests, { func => 'nextdown', arg => '7FE0000000000000', expect => hexstr754_to_double('7FDFFFFFFFFFFFFF'),    name => "nextdown(POS_NORM_xFx0)" };
push @tests, { func => 'nextdown', arg => 'FFE0000000000000', expect => hexstr754_to_double('FFE0000000000001'),    name => "nextdown(NEG_NORM_xFx0)" };
push @tests, { func => 'nextdown', arg => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFE'),    name => "nextdown(POS_NORM_xFxF)" };
push @tests, { func => 'nextdown', arg => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF0000000000000'),    name => "nextdown(NEG_NORM_xFxF)" };
push @tests, { func => 'nextdown', arg => '7FF0000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextdown(POS_INF)" };
push @tests, { func => 'nextdown', arg => 'FFF0000000000000', expect => hexstr754_to_double('FFF0000000000000'),    name => "nextdown(NEG_INF)" };
push @tests, { func => 'nextdown', arg => '7FF0000000000001', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextdown(POS_SNAN_01)" };
push @tests, { func => 'nextdown', arg => 'FFF0000000000001', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextdown(NEG_SNAN_01)" };
push @tests, { func => 'nextdown', arg => '7FF7FFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextdown(POS_SNAN_7F)" };
push @tests, { func => 'nextdown', arg => 'FFF7FFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextdown(NEG_SNAN_7F)" };
push @tests, { func => 'nextdown', arg => '7FF8000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextdown(POS_IND_80)" };
push @tests, { func => 'nextdown', arg => 'FFF8000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextdown(NEG_IND_80)" };
push @tests, { func => 'nextdown', arg => '7FF8000000000001', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextdown(POS_QNAN_81)" };
push @tests, { func => 'nextdown', arg => 'FFF8000000000001', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextdown(NEG_QNAN_81)" };
push @tests, { func => 'nextdown', arg => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextdown(POS_QNAN_FF)" };
push @tests, { func => 'nextdown', arg => 'FFFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextdown(NEG_QNAN_FF)" };

# plan and execute
plan tests => scalar @tests;

fntest( $_->{func}, $_->{arg}, $_->{expect}, $_->{name}, $_->{todo} ) foreach @tests;

exit;
