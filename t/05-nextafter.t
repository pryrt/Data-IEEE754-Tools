########################################################################
# Verifies the following functions:
#   :ulp
#       nextafter(v, dir)
#   (other :ulp coverage in other .t files)
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-07-07 13:37:19 -0700 (Thu, 07 Jul 2016) $
#   $Revision: 222 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/05-nextafter.t $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/t/05-nextafter.t 222 2016-07-07 20:37:19Z pryrtmx $
#   $Id: 05-nextafter.t 222 2016-07-07 20:37:19Z pryrtmx $
########################################################################
use 5.008005;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:raw754 :ulp :floatingpoint/;

my ($h,$u,$v);

sub f2test {
    my $fn = shift;
    my $f = \&{$fn};                        # strict refs doesn't allow &$fn(arg) directly
    my $h = shift;
    my $dh = shift;
    my $x = shift;
    my $v = hexstr754_to_double($h);
    my $d = hexstr754_to_double($dh);
    my $u = $f->($v,$d);
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

# nextafter(): +NAN to anything
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_ZERO)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_ZERO)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '0000000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_DENORM_1)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '8000000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_DENORM_1)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '000FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_DENORM_F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '800FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_DENORM_F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '0010000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_x1x0)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '8010000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_x1x0)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '001FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_x1xF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '801FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_x1xF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '034FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_x34F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '834FFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_x34F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '0350000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_x350)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '8350000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_x350)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FE0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_xFx0)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFE0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_xFx0)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_NORM_xFxF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_NORM_xFxF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_INF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_INF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF0000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_SNAN_01)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF0000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_SNAN_01)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF7FFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_SNAN_7F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF7FFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_SNAN_7F)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF8000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_IND_80)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF8000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_IND_80)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF8000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_QNAN_81)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF8000000000001', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_QNAN_81)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, POS_QNAN_FF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(+NAN, NEG_QNAN_FF)" };

# nextafter(): anything to +NAN
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_ZERO, +NAN)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_ZERO, +NAN)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_DENORM_1, +NAN)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_DENORM_1, +NAN)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_DENORM_F, +NAN)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_DENORM_F, +NAN)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1x0, +NAN)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1x0, +NAN)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1xF, +NAN)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1xF, +NAN)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x34F, +NAN)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x34F, +NAN)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x350, +NAN)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x350, +NAN)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFx0, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFx0, +NAN)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFxF, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFxF, +NAN)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, +NAN)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, +NAN)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, +NAN)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, +NAN)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, +NAN)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, +NAN)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, +NAN)" };

# nextafter(): anything to itself
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '0000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_ZERO, ITSELF)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '8000000000000000', expect => hexstr754_to_double('8000000000000000'),    name => "nextafter(NEG_ZERO, ITSELF)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '0000000000000001', expect => hexstr754_to_double('0000000000000001'),    name => "nextafter(POS_DENORM_1, ITSELF)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '8000000000000001', expect => hexstr754_to_double('8000000000000001'),    name => "nextafter(NEG_DENORM_1, ITSELF)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '000FFFFFFFFFFFFF', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextafter(POS_DENORM_F, ITSELF)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '800FFFFFFFFFFFFF', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextafter(NEG_DENORM_F, ITSELF)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '0010000000000000', expect => hexstr754_to_double('0010000000000000'),    name => "nextafter(POS_NORM_x1x0, ITSELF)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '8010000000000000', expect => hexstr754_to_double('8010000000000000'),    name => "nextafter(NEG_NORM_x1x0, ITSELF)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '001FFFFFFFFFFFFF', expect => hexstr754_to_double('001FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1xF, ITSELF)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '801FFFFFFFFFFFFF', expect => hexstr754_to_double('801FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1xF, ITSELF)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '034FFFFFFFFFFFFF', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x34F, ITSELF)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '834FFFFFFFFFFFFF', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x34F, ITSELF)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '0350000000000000', expect => hexstr754_to_double('0350000000000000'),    name => "nextafter(POS_NORM_x350, ITSELF)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '8350000000000000', expect => hexstr754_to_double('8350000000000000'),    name => "nextafter(NEG_NORM_x350, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '7FE0000000000000', expect => hexstr754_to_double('7FE0000000000000'),    name => "nextafter(POS_NORM_xFx0, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => 'FFE0000000000000', expect => hexstr754_to_double('FFE0000000000000'),    name => "nextafter(NEG_NORM_xFx0, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFxF, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFxF, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF0000000000000'),    name => "nextafter(POS_INF, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF0000000000000'),    name => "nextafter(NEG_INF, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '7FF0000000000001', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => 'FFF0000000000001', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '7FF7FFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => 'FFF7FFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '7FF8000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => 'FFF8000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '7FF8000000000001', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => 'FFF8000000000001', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, ITSELF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FFFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, ITSELF)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => 'FFFFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, ITSELF)" };

# nextafter(): anything to +INF
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('0000000000000001'),    name => "nextafter(POS_ZERO, +INF)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('0000000000000001'),    name => "nextafter(NEG_ZERO, +INF)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('0000000000000002'),    name => "nextafter(POS_DENORM_1, +INF)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('8000000000000000'),    name => "nextafter(NEG_DENORM_1, +INF)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('0010000000000000'),    name => "nextafter(POS_DENORM_F, +INF)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFE'),    name => "nextafter(NEG_DENORM_F, +INF)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('0010000000000001'),    name => "nextafter(POS_NORM_x1x0, +INF)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1x0, +INF)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('0020000000000000'),    name => "nextafter(POS_NORM_x1xF, +INF)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('801FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x1xF, +INF)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('0350000000000000'),    name => "nextafter(POS_NORM_x34F, +INF)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x34F, +INF)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('0350000000000001'),    name => "nextafter(POS_NORM_x350, +INF)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x350, +INF)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('7FE0000000000001'),    name => "nextafter(POS_NORM_xFx0, +INF)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('FFDFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFx0, +INF)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF0000000000000'),    name => "nextafter(POS_NORM_xFxF, +INF)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_xFxF, +INF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF0000000000000'),    name => "nextafter(POS_INF, +INF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, +INF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, +INF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, +INF)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, +INF)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, +INF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, +INF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => '7FF0000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, +INF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, +INF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => '7FF0000000000000', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, +INF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, +INF)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => '7FF0000000000000', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, +INF)" };

# nextafter(): anything to +MAXNUM
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0000000000000001'),    name => "nextafter(POS_ZERO, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0000000000000001'),    name => "nextafter(NEG_ZERO, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0000000000000002'),    name => "nextafter(POS_DENORM_1, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('8000000000000000'),    name => "nextafter(NEG_DENORM_1, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0010000000000000'),    name => "nextafter(POS_DENORM_F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('800FFFFFFFFFFFFE'),    name => "nextafter(NEG_DENORM_F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0010000000000001'),    name => "nextafter(POS_NORM_x1x0, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1x0, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0020000000000000'),    name => "nextafter(POS_NORM_x1xF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('801FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x1xF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0350000000000000'),    name => "nextafter(POS_NORM_x34F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('834FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x34F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('0350000000000001'),    name => "nextafter(POS_NORM_x350, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x350, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FE0000000000001'),    name => "nextafter(POS_NORM_xFx0, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFDFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFx0, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFxF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_xFxF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, +MAXNUM) == BUGGY" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, +MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, +MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => '7FEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, +MAXNUM)" };

# nextafter(): anything to +ZERO
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '0000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_ZERO, +ZERO)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '0000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(NEG_ZERO, +ZERO)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '0000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_DENORM_1, +ZERO)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '0000000000000000', expect => hexstr754_to_double('8000000000000000'),    name => "nextafter(NEG_DENORM_1, +ZERO)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFE'),    name => "nextafter(POS_DENORM_F, +ZERO)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFE'),    name => "nextafter(NEG_DENORM_F, +ZERO)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '0000000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1x0, +ZERO)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '0000000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1x0, +ZERO)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('001FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x1xF, +ZERO)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('801FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x1xF, +ZERO)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x34F, +ZERO)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x34F, +ZERO)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '0000000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x350, +ZERO)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '0000000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x350, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '0000000000000000', expect => hexstr754_to_double('7FDFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFx0, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => '0000000000000000', expect => hexstr754_to_double('FFDFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFx0, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_xFxF, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_xFxF, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '0000000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, +ZERO) == BUGGY" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => '0000000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '0000000000000000', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => '0000000000000000', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '0000000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => '0000000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '0000000000000000', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => '0000000000000000', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, +ZERO)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, +ZERO)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => '0000000000000000', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, +ZERO)" };

# nextafter(): anything to -ZERO
push @tests, { func => 'nextafter', val => '0000000000000000', dir => '8000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_ZERO, -ZERO)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => '8000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(NEG_ZERO, -ZERO)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => '8000000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_DENORM_1, -ZERO)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => '8000000000000000', expect => hexstr754_to_double('8000000000000000'),    name => "nextafter(NEG_DENORM_1, -ZERO)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFE'),    name => "nextafter(POS_DENORM_F, -ZERO)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFE'),    name => "nextafter(NEG_DENORM_F, -ZERO)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => '8000000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1x0, -ZERO)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => '8000000000000000', expect => hexstr754_to_double('800FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x1x0, -ZERO)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('001FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x1xF, -ZERO)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('801FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x1xF, -ZERO)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x34F, -ZERO)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_x34F, -ZERO)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => '8000000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x350, -ZERO)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => '8000000000000000', expect => hexstr754_to_double('834FFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_x350, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => '8000000000000000', expect => hexstr754_to_double('7FDFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFx0, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => '8000000000000000', expect => hexstr754_to_double('FFDFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFx0, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_xFxF, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFE'),    name => "nextafter(NEG_NORM_xFxF, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => '8000000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => '8000000000000000', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => '8000000000000000', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => '8000000000000000', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => '8000000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => '8000000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => '8000000000000000', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => '8000000000000000', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, -ZERO)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, -ZERO)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => '8000000000000000', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, -ZERO)" };

# nextafter(): anything to -MAXNUM
push @tests, { func => 'nextafter', val => '0000000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8000000000000001'),    name => "nextafter(POS_ZERO, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8000000000000001'),    name => "nextafter(NEG_ZERO, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_DENORM_1, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8000000000000002'),    name => "nextafter(NEG_DENORM_1, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('000FFFFFFFFFFFFE'),    name => "nextafter(POS_DENORM_F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8010000000000000'),    name => "nextafter(NEG_DENORM_F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1x0, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8010000000000001'),    name => "nextafter(NEG_NORM_x1x0, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('001FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x1xF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8020000000000000'),    name => "nextafter(NEG_NORM_x1xF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('034FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x34F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8350000000000000'),    name => "nextafter(NEG_NORM_x34F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x350, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('8350000000000001'),    name => "nextafter(NEG_NORM_x350, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FDFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFx0, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFE0000000000001'),    name => "nextafter(NEG_NORM_xFx0, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_xFxF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_NORM_xFxF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFEFFFFFFFFFFFFF'),    name => "nextafter(NEG_INF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, -MAXNUM)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, -MAXNUM)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => 'FFEFFFFFFFFFFFFF', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, -MAXNUM)" };

# nextafter(): anything to -INF
push @tests, { func => 'nextafter', val => '0000000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('8000000000000001'),    name => "nextafter(POS_ZERO, -INF)" };
push @tests, { func => 'nextafter', val => '8000000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('8000000000000001'),    name => "nextafter(NEG_ZERO, -INF)" };
push @tests, { func => 'nextafter', val => '0000000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('0000000000000000'),    name => "nextafter(POS_DENORM_1, -INF)" };
push @tests, { func => 'nextafter', val => '8000000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('8000000000000002'),    name => "nextafter(NEG_DENORM_1, -INF)" };
push @tests, { func => 'nextafter', val => '000FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFE'),    name => "nextafter(POS_DENORM_F, -INF)" };
push @tests, { func => 'nextafter', val => '800FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('8010000000000000'),    name => "nextafter(NEG_DENORM_F, -INF)" };
push @tests, { func => 'nextafter', val => '0010000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('000FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x1x0, -INF)" };
push @tests, { func => 'nextafter', val => '8010000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('8010000000000001'),    name => "nextafter(NEG_NORM_x1x0, -INF)" };
push @tests, { func => 'nextafter', val => '001FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('001FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x1xF, -INF)" };
push @tests, { func => 'nextafter', val => '801FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('8020000000000000'),    name => "nextafter(NEG_NORM_x1xF, -INF)" };
push @tests, { func => 'nextafter', val => '034FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_x34F, -INF)" };
push @tests, { func => 'nextafter', val => '834FFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('8350000000000000'),    name => "nextafter(NEG_NORM_x34F, -INF)" };
push @tests, { func => 'nextafter', val => '0350000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('034FFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_x350, -INF)" };
push @tests, { func => 'nextafter', val => '8350000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('8350000000000001'),    name => "nextafter(NEG_NORM_x350, -INF)" };
push @tests, { func => 'nextafter', val => '7FE0000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FDFFFFFFFFFFFFF'),    name => "nextafter(POS_NORM_xFx0, -INF)" };
push @tests, { func => 'nextafter', val => 'FFE0000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFE0000000000001'),    name => "nextafter(NEG_NORM_xFx0, -INF)" };
push @tests, { func => 'nextafter', val => '7FEFFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFE'),    name => "nextafter(POS_NORM_xFxF, -INF)" };
push @tests, { func => 'nextafter', val => 'FFEFFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF0000000000000'),    name => "nextafter(NEG_NORM_xFxF, -INF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FEFFFFFFFFFFFFF'),    name => "nextafter(POS_INF, -INF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF0000000000000'),    name => "nextafter(NEG_INF, -INF)" };
push @tests, { func => 'nextafter', val => '7FF0000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FF0000000000001'),    name => "nextafter(POS_SNAN_01, -INF)" };
push @tests, { func => 'nextafter', val => 'FFF0000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF0000000000001'),    name => "nextafter(NEG_SNAN_01, -INF)" };
push @tests, { func => 'nextafter', val => '7FF7FFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FF7FFFFFFFFFFFF'),    name => "nextafter(POS_SNAN_7F, -INF)" };
push @tests, { func => 'nextafter', val => 'FFF7FFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF7FFFFFFFFFFFF'),    name => "nextafter(NEG_SNAN_7F, -INF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FF8000000000000'),    name => "nextafter(POS_IND_80, -INF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000000', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF8000000000000'),    name => "nextafter(NEG_IND_80, -INF)" };
push @tests, { func => 'nextafter', val => '7FF8000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FF8000000000001'),    name => "nextafter(POS_QNAN_81, -INF)" };
push @tests, { func => 'nextafter', val => 'FFF8000000000001', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFF8000000000001'),    name => "nextafter(NEG_QNAN_81, -INF)" };
push @tests, { func => 'nextafter', val => '7FFFFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('7FFFFFFFFFFFFFFF'),    name => "nextafter(POS_QNAN_FF, -INF)" };
push @tests, { func => 'nextafter', val => 'FFFFFFFFFFFFFFFF', dir => 'FFF0000000000000', expect => hexstr754_to_double('FFFFFFFFFFFFFFFF'),    name => "nextafter(NEG_QNAN_FF, -INF)" };

# plan and execute
plan tests => scalar @tests;
f2test( $_->{func}, $_->{val}, $_->{dir}, $_->{expect}, $_->{name}, $_->{todo} ) foreach @tests;

exit;
