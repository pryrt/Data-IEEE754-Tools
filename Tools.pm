=pod

=head1 NAME

Data::IEEE754::Tools - Various tools for understanding and manipulating the underlying IEEE-754 representation of floating point values

=head1 SYNOPSIS

    use Data::IEEE754::Tools qw/:floatingpoint :ulp/;

    # return -12.875 as decimal and hexadecimal floating point numbers
    to_dec_floatingpoint(-12.875);          # -0d1.6093750000000000p+0003
    to_hex_floatingpoint(-12.875);          # -0x1.9c00000000000p+0003

    # shows the smallest value you can add or subtract to 16.16 (ulp = "Unit in the Last Place")
    print ulp( 16.16 );                     # 3.5527136788005e-015

    # toggles the ulp: returns a float that has the ULP of 16.16 toggled
    #   (if it was a 1, it will be 0, and vice versa);
    #   running it twice should give the original value
    print $t16 = toggle_ulp( 16.16 );   # 16.159999999999997
    print $v16 = toggle_ulp( $t16 );    # 16.160000000000000

=head1 DESCRIPTION

These tools give access to the underlying IEEE 754 floating-point representation
used by Perl (see L<perlguts>).  They include functions for converting from the
64bit internal representation to a string that shows those bits (either as
hexadecimal or binary) and back, functions for converting that encoded value
into a more human-readable format to give insight into the meaning of the encoded
values, and functions to manipulate the smallest possible change for a given
floating-point value (which is the L<ULP|https://en.wikipedia.org/wiki/Unit_in_the_last_place> or
"Unit in the Last Place").

=head2 IEEE 754 Encoding

The L<IEEE 754|https://en.wikipedia.org/wiki/IEEE_floating_point> standard describes
various floating-point encodings.  The double format (`binary64') is a 64-bit base-2
encoding, and correpsonds to the usual Perl floating value (NV). The format  includes the
sign (s), the power of 2 (q), and a significand (aka, mantissa; the coefficient, c):
C<value = ((-1)**s) * (c) * (2**q)>. The C<(-1)**s> term evaluates to the sign of the
number, where s=0 means the sign is +1 and s=1 means the sign is -1.

For most numbers, the coefficient is an implied 1 plus an encoded fraction,
which is itself encoded as a 52-bit integer divided by an implied 2**52. The range of
valid exponents is from -1022 to +1023, which are encoded as an 11bit integer from 1
to 2046 (where C<exponent_value = exponent_integer - 1023>).  With an 11bit integer,
there are two exponent values (C<0b000_0000_0000 = 0 - 1023 = -1023> and
C<0b111_1111_1111 = 2047 - 1023 = +1024>), which are used to indicate conditions outside
the normal range: The first special encoded-exponent, C<0b000_0000_0000>, indicates that
the coefficient is 0 plus the encoded fraction, at an exponent of -1022; thus, the
floating-point zero is  encoded using an encoded-exponent of 0 and an encoded-fraction of 0
(C<[0 + 0/(2**52)] * [2**-1022] = 0*(2**-1022) = 0>); other numbers
smaller than can normally be encoded (so-called "denormals" or "subnormals"), lying
between 0 and 1 (non-inclusive) are encoded with the same exponent, but have a non-zero
encoded-fraction.  The second special encoded-exponent, C<0b111_1111_1111>, indicates a
number that is infinite (too big to represent), or something that is not a number (NAN);
infinities are indicated by that special exponent and an encoded-fraction of 0; NAN
is indicated by that special exponent and a non-zero encoded-fraction.

=head2 Justification for the existence of B<Data::IEEE754::Tools>

L<Data::IEEE754>, or the equivalent L<perlfunc/pack> recipe L<dE<gt>>, do a
good job of converting a perl floating value (NV) into the big-endian bytes
that encode that value, but they don't help you interpret the value.

L<Data::Float> has a similar suite of tools to B<Data::IEEE754::Tools>, but
uses numerical methods rather than accessing the underlying bits.  It L<has been
shown|http://perlmonks.org/?node_id=1167146> that its interpretation function can take
an order of magnitude longer than a routine that manipulates the underlying bits
to gather the information.

This B<Data::IEEE754::Tools> module combines the two sets of functions, giving
access to the raw IEEE 754 encoding, or a stringification of the encoding which
interprets the encoding as a sign and a coefficient and a power of 2, or access to
the ULP and ULP-manipulating features, all using direct bit manipulation when
appropriate.

=cut

########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-07-07 06:57:25 -0700 (Thu, 07 Jul 2016) $
#   $Revision: 216 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/Tools.pm $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/Tools.pm 216 2016-07-07 13:57:25Z pryrtmx $
#   $Id: Tools.pm 216 2016-07-07 13:57:25Z pryrtmx $
########################################################################
package Data::IEEE754::Tools;
use 5.008005;
use warnings;
use strict;
use Carp;
use Exporter 'import';  # just use the import() function, without the rest of the overhead of ISA

use version 0.77; our $VERSION = version->declare('v0.008');

=head1 EXPORTABLE FUNCTIONS AND VARIABLES

=cut

my  @EXPORT_RAW754 = qw(hexstr754_from_double binstr754_from_double hexstr754_to_double binstr754_to_double);
my  @EXPORT_FLOATING = qw(to_hex_floatingpoint to_dec_floatingpoint);
my  @EXPORT_ULP = qw(ulp toggle_ulp nextup nextdown nextafter);

our @EXPORT_OK = (@EXPORT_FLOATING, @EXPORT_RAW754, @EXPORT_ULP);
our %EXPORT_TAGS = (
    floating        => [@EXPORT_FLOATING],
    floatingpoint   => [@EXPORT_FLOATING],
    raw754          => [@EXPORT_RAW754],
    ulp             => [@EXPORT_ULP],
    all             => [@EXPORT_OK],
);

=head2 :raw754

These are the functions to do raw conversion from a floating-point value to a hexadecimal or binary
string of the underlying IEEE754 encoded value, and back.

=head3 hexstr754_from_double( I<val> )

Converts the floating-point I<val> into a big-endian hexadecimal representation of the underlying
IEEE754 encoding.

    hexstr754_from_double(12.875);      #  4029C00000000000
                                        #  ^^^
                                        #  :  ^^^^^^^^^^^^^
                                        #  :  :
                                        #  :  `- fraction
                                        #  :
                                        #  `- sign+exponent

The first three nibbles (hexadecimal digits) encode the sign and the exponent.  The sign is
the most significant bit of the three nibbles (so AND the first nibble with 8; if it's true,
the number is negative, else it's positive).  The remaining 11 bits of the nibbles encode the
exponent: convert the 11bits to decimal, then subtract 1023.  If the resulting exponent is -1023,
it indicates a zero or denormal value; if the exponent is +1024, it indicates an infinite (Inf) or
not-a-number (NaN) value, which are generally used to indicate the calculation has grown to large
to fit in an IEEE754 double (Inf) or has tried an performed some other undefined operation (divide
by zero or the logarithm of a zero or negative value) (NaN).

The final thirteen nibbles are the encoding of the fractional value (usually C<1 + thirteennibbles /
16**13>, unless it's zero, denormal, infinite, or not a number).

Of course, this is easier to decode using the L</to_dec_floatingpoint()> function, which interprets
the sign, fraction, and exponent for you.  (See below for more details.)

    to_dec_floatingpoint(12.875);       # +0d1.6093750000000000p+0003
                                        # ^  ^^^^^^^^^^^^^^^^^^  ^^^^
                                        # :  :                   :
                                        # :  `- coefficient      `- exponent (power of 2)
                                        # :
                                        # `- sign

=head3 binstr754_from_double( I<val> )

Converts the floating-point I<val> into a big-endian binary representation of the underlying
IEEE754 encoding.

    binstr754_from_double(12.875);      # 0100000000101001110000000000000000000000000000000000000000000000
                                        # ^
                                        # `- sign
                                        #  ^^^^^^^^^^^
                                        #  `- exponent
                                        #             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                        #             `- fraction

The first bit is the sign, the next 11 are the exponent's encoding

=head3 hexstr754_to_double( I<str> )

The inverse of I<hexstr754_from_double()>: it takes a string representing the 16 nibbles
of the IEEE754 double value, and converts it back to a perl floating-point value.

    print hexstr754_to_double('4029C00000000000');
    12.875

=head3 binstr754_to_double( I<str> )

The inverse of I<binstr754_from_double()>: it takes a string representing the 64 bits
of the IEEE754 double value, and converts it back to a perl floating-point value.

    print binstr754_to_double('0100000000101001110000000000000000000000000000000000000000000000');
    12.875

=cut
# Perl 5.10 introduced the ">" and "<" modifiers for pack which can be used to
# force a specific endianness.
if( $] lt '5.010' ) {
    my $str = join('', unpack("H*", pack 'L' => 0x12345678));
    if('78563412' eq $str) {        # little endian, so reverse byteorder
        *hexstr754_from_double  = sub { return uc unpack('H*' => reverse pack 'd'  => shift); };
        *binstr754_from_double  = sub { return uc unpack('B*' => reverse pack 'd'  => shift); };

        *hexstr754_to_double    = sub { return    unpack('d'  => reverse pack 'H*' => shift); };
        *binstr754_to_double    = sub { return    unpack('d'  => reverse pack 'B*' => shift); };

        *arr2x32b_from_double   = sub { return    unpack('N2' => reverse pack 'd'  => shift); };
    } elsif('12345678' eq $str) {   # big endian, so keep default byteorder
        *hexstr754_from_double  = sub { return uc unpack('H*' =>         pack 'd'  => shift); };
        *binstr754_from_double  = sub { return uc unpack('B*' =>         pack 'd'  => shift); };

        *hexstr754_to_double    = sub { return    unpack('d'  =>         pack 'H*' => shift); };
        *binstr754_to_double    = sub { return    unpack('d'  =>         pack 'B*' => shift); };

        *arr2x32b_from_double   = sub { return    unpack('N2' =>         pack 'd'  => shift); };
    } else {
        # I don't handle middle-endian / mixed-endian; sorry
        *hexstr754_from_double = sub { undef };
        *binstr754_from_double = sub { undef };

        *hexstr754_to_double     = sub { undef };
        *binstr754_to_double     = sub { undef };
    }
} else {
        *hexstr754_from_double  = sub { return uc unpack('H*' =>         pack 'd>' => shift); };
        *binstr754_from_double  = sub { return uc unpack('B*' =>         pack 'd>' => shift); };

        *hexstr754_to_double    = sub { return    unpack('d>' =>         pack 'H*' => shift); };
        *binstr754_to_double    = sub { return    unpack('d>' =>         pack 'B*' => shift); };

        *arr2x32b_from_double   = sub { return    unpack('N2' =>         pack 'd>' => shift); };
}

=head2 :floatingpoint

=head3 to_hex_floatingpoint( I<value> )

=head3 to_dec_floatingpoint( I<value> )

Converts value to a hexadecimal or decimal floating-point notation that indicates the sign and
the coefficient and the power of two, with the coefficient either in hexadecimal or decimal
notation.

    to_hex_floatingpoint(-3.9999999999999996)    # -0x1.fffffffffffffp+0001
    to_dec_floatingpoint(-3.9999999999999996)    # -0d1.9999999999999998p+0001

It displays the value as (sign)(0base)(implied).(fraction)p(exponent):

=cut

sub to_hex_floatingpoint {
    # thanks to BrowserUK @ http://perlmonks.org/?node_id=1167146 for slighly better decision factors
    # I tweaked it to use the two 32bit words instead of one 64bit word (which wouldn't work on some systems)
    my $v = shift;
    my ($msb,$lsb) = arr2x32b_from_double($v);
    my $sbit = ($msb & 0x80000000) >> 31;
    my $sign = $sbit ? '-' : '+';
    my $exp  = (($msb & 0x7FF00000) >> 20) - 1023;
    my $mant = sprintf '%05x%08x', $msb & 0x000FFFFF, $lsb & 0xFFFFFFFF;
    if($exp == 1024) {
        return $sign . "0x1.#INF000000000p+0000"    if $mant eq '0000000000000';
        return $sign . "0x1.#IND000000000p+0000"    if $mant eq '8000000000000' and $sign eq '-';
        return $sign . ( (($msb & 0x00080000) != 0x00080000) ? "0x1.#SNAN00000000p+0000" : "0x1.#QNAN00000000p+0000");
    }
    my $implied = 1;
    if( $exp == -1023 ) { # zero or denormal
        $implied = 0;
        $exp = $mant eq '0000000000000' ? 0 : -1022;   # 0 for zero, -1022 for denormal
    }
    sprintf '%s0x%1u.%13.13sp%+05d', $sign, $implied, $mant, $exp;
}

sub to_dec_floatingpoint {
    # based on to_hex_floatingpoint
    my $v = shift;
    my ($msb,$lsb) = arr2x32b_from_double($v);
    my $sbit = ($msb & 0x80000000) >> 31;
    my $sign = $sbit ? '-' : '+';
    my $exp  = (($msb & 0x7FF00000) >> 20) - 1023;
    my $mant = sprintf '%05x%08x', $msb & 0x000FFFFF, $lsb & 0xFFFFFFFF;
    if($exp == 1024) {
        return $sign . "0d1.#INF000000000000p+0000"    if $mant eq '0000000000000';
        return $sign . "0d1.#IND000000000000p+0000"    if $mant eq '8000000000000' and $sign eq '-';
        return $sign . ( (($msb & 0x00080000) != 0x00080000) ? "0d1.#SNAN00000000000p+0000" : "0d1.#QNAN00000000000p+0000");
    }
    my $implied = 1;
    if( $exp == -1023 ) { # zero or denormal
        $implied = 0;
        $exp = $mant eq '0000000000000' ? 0 : -1022;   # 0 for zero, -1022 for denormal
    }
    #$mant = (($msb & 0x000FFFFF)*4_294_967_296.0 + ($lsb & 0xFFFFFFFF)*1.0) / (2.0**52);
    #sprintf '%s0d%1u.%.16fp%+05d', $sign, $implied, $mant, $exp;
    my $other = abs($v) / (2.0**$exp);
    sprintf '%s0d%.16fp%+05d', $sign, $other, $exp;
}


=over

=item sign

The I<sign> will be + or -

=item 0base

The I<0base> will be C<0x> for hexadecimal, C<0d> for decimal

=item implied.fraction

The I<implied.fraction> indicates the hexadecimal or decimal equivalent for the coefficient

I<implied> will be 0 for zero or denormal numbers, 1 for everything else

I<fraction> will indicate infinities (#INF), signaling not-a-numbers (#SNAN), and quiet not-a-numbers (#QNAN).

I<implied.fraction> will range from decimal 0.0000000000000000 to 0.9999999999999998 for zero thru all the denormals,
and from 1.0000000000000000 to 1.9999999999999998 for normal values.

=item p

The I<p> introduces the "power" of 2.  (It is analogous to the C<e> in C<1.0e3> introducing the power of 10 in a
standard decimal floating-point notation, but indicates that the exponent is 2**exp instead of 10**exp.)

=item exponent

The I<exponent> is the power of 2.  Is is always a decimal number, whether the coefficient's base is hexadecimal or decimal.

    +0d1.500000000000000p+0010
    = 1.5 * (2**10)
    = 1.5 * 1024.0
    = 1536.0.

The I<exponent> can range from -1022 to +1023.

Internally, the IEEE 754 representation uses the encoding of -1023 for zero and denormals; to
aid in understanding the actual number, the I<to_..._floatingpoint()> conversions represent
them as +0000 for zero, and -1022 for denormals: since denormals are C<(0+fraction)*(2**min_exp)>,
they are really multiples of 2**-1022, not 2**-1023.

=back

=head2 :ulp

=head3 ulp( I<val> )

Returns the ULP ("Unit in the Last Place") for the given I<val>, which is the smallest number
that you can add to or subtract from I<val> and still be able to discern a difference between
the original and modified.  Under normal (or denormal) circumstances, C<ulp($val) + $val E<gt> $val>
is true.

If the I<val> is a zero or a denormal, C<ulp()> will return the smallest possible denormal.

Since INF and NAN are not really numbers, C<ulp()> will just return the same I<val>.  Because
of the way they are handled, C<ulp($val) + $val E<gt> $val> no longer makes sense (infinity plus
anything is still infinity, and adding NAN to NAN is not numerically defined, so a numerical
comparison is meaningless on both).

=cut

sub ulp($) {
    my $val = shift;
    my $rawbin = binstr754_from_double($val);
    my ($sign, $exp, $fract) = ($rawbin =~ /(.)(.{11})(.{52})/);

    # check for special conditions
    if( $exp == '1'x11 ) {                          # return self for INF or NAN
        return $val;
    } elsif ( $exp == '0'x11 ) {                    # ZERO or DENORMAL: build (+)(exp:0)(fract:0...1)
        $fract = '0'x51 . '1';
        $rawbin = join '', '0', $exp, $fract;
        return binstr754_to_double($rawbin);
    }

    # calculate normal ULP
    my $tog = toggle_ulp( $val );
    return abs($val - $tog);
    return join "|", (caller(0))[3].'()', $val, $rawbin, $sign, $exp, $fract, __LINE__, '';
}

=head3 toggle_ulp( I<val> )

Returns the orginal I<val>, but with the ULP toggled.  In other words, if the ULP bit
was a 0, it will return a value with the ULP of 1 (equivalent to adding one ULP to a positive
I<val>); if the ULP bit was a 1, it will return a value with the ULP of 0 (equivalent to
subtracting one ULP from a positive I<val>).  Under normal (or denormal) circumstances,
C<toggle_ulp($val) != $val> is true.

Since INF and NAN are not really numbers, C<ulp()> will just return the same I<val>.  Because
of the way they are handled, C<toggle_ulp($val) != $val> no longer makes sense.

=cut

sub toggle_ulp {
    my $val = shift;
    my $rawbin = binstr754_from_double($val);
    my ($sign, $exp, $fract) = ($rawbin =~ /(.)(.{11})(.{52})/);

    # INF and NAN do not have a meaningful ULP; just return SELF
    if( $exp == '1'x11 ) {
        return $val;
    }

    # ZERO, DENORMAL, and NORMAL: toggle the last bit of fract
    my $ulp_bit = substr $fract, -1;
    substr $fract, -1, 1, (1-$ulp_bit);
    $rawbin = join '', $sign, $exp, $fract;
    return binstr754_to_double($rawbin);
}

=head3 nextup( I<value> )

Returns the next floating point value numerically greater than I<value>; that is, it adds one ULP.
Returns infinite when I<value> is the highest normal floating-point value.
Returns I<value> when I<value> is positive-infinite or NAN; returns the largest negative normal
floating-point value when I<value> is negative-infinite.

C<nextup> is an IEEE 754r standard function.

=cut

sub nextup {
    # thanks again to BrowserUK: http://perlmonks.org/?node_id=1167146
    my $val = shift;
    return $val                                     if $val != $val;                # interestingly, NAN != NAN
    my $h754 = hexstr754_from_double($val);
    return $val                                     if $h754 eq '7FF0000000000000'; # return self               for +INF
    return hexstr754_to_double('FFEFFFFFFFFFFFFF')  if $h754 eq 'FFF0000000000000'; # return largest negative   for -INF
    return hexstr754_to_double('0000000000000001')  if $h754 eq '8000000000000000'; # return +SmallestDenormal  for -ZERO
    my ($msb,$lsb) = arr2x32b_from_double($val);
    $lsb += ($msb & 0x80000000) ? -1.0 : +1.0;
    if($lsb == 4_294_967_296.0) {
        $lsb = 0.0;
        $msb += ($msb & 0x80000000) ? -1.0 : +1.0;
    } elsif ($lsb == -1.0) {
        $msb += ($msb & 0x80000000) ? -1.0 : +1.0;
    }
    return hexstr754_to_double( sprintf '%08X%08X', $msb, $lsb );
}

=head3 nextdown( I<value> )

Returns the next floating point value numerically lower than I<value>; that is, it subtracts one ULP.
Returns -infinity when I<value> is the largest negative normal floating-point value.
Returns I<value> when I<value> is negative-infinite or NAN; returns the largest positive normal
floating-point value when I<value> is positive-infinite.

C<nextdown> is an IEEE 754r standard function.

=cut

sub nextdown {
    return - nextup( - $_[0] );
}

=head3 nextafter( I<value>, I<direction> )

Returns the next floating point value after I<value> in the direction of I<direction>.  If the
two are identical, return I<direction>; if I<direction> is numerically above I<float>, return
C<nextup(I<value>)>; if I<direction> is numerically below I<float>, return C<nextdown(I<value>)>.

C<nextafter> is an IEEE 754r standard function.

=cut

sub nextafter {
    return $_[0]            if $_[0] != $_[0];      # return value when value is NaN
    return $_[1]            if $_[1] != $_[1];      # return direction when direction is NaN
    return $_[1]            if $_[1] == $_[0];      # return direction when the two are equal
    return nextup($_[0])    if $_[1] > $_[0];       # return nextup if direction > value
    return nextdown($_[0]);                         # otherwise, return nextdown()
}

=head2 :all

Include all of the above.

=head1 SEE ALSO

=over

=item * L<What Every Compute Scientist Should Know About Floating-Point Arithmetic|https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html>

=item * L<Perlmonks: Integers sometimes turn into Reals after substraction|http://perlmonks.org/?node_id=1163025> for
inspiring me to go down the IEEE754-expansion trail in perl.

=item * L<Perlmonks: Exploring IEEE754 floating point bit patterns|http://perlmonks.org/?node_id=984141> as a resource
for how perl interacts with the various "edge cases" (+/-infinity, L<denormalized numbers|https://en.wikipedia.org/wiki/Denormal_number>,
signaling and quiet L<NaNs (Not-A-Number)|https://en.wikipedia.org/wiki/NaN>.

=item * L<Data::IEEE754>: I really wanted to use this module, but it didn't get me very far down the "Tools" track,
and included a lot of overhead modules for its install/test that I didn't want to require for B<Data::IEEE754::Tools>.
However, I was inspired by his byteorder-dependent anonymous subs (which were in turn derived from L<Data::MessagePack::PP>);
they were more efficient, on a per-call-to-subroutine basis, than my original inclusion of the if(byteorder) in every call to
the sub.

=item * L<Data::Float>: Similar to this module, but uses numeric manipulation.

=back

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Data-IEEE754-Tools AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-IEEE754-Tools>.

=head1 COPYRIGHT

Copyright (C) 2016 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
