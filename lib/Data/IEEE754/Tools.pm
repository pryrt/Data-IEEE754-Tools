package Data::IEEE754::Tools;
use 5.006;
use warnings;
use strict;
use Carp;
use Exporter 'import';  # just use the import() function, without the rest of the overhead of ISA
use Config;

our $VERSION = '0.018003';
    # use rrr.mmm_aaa, where rrr is major revision, mmm is ODD minor revision, and aaa is alpha sub-revision (for ALPHA code)
    # use rrr.mmmsss,  where rrr is major revision, mmm is EVEN minor revision, and sss is a sub-revision (usually sss=000) (for releases)

=pod

=head1 NAME

Data::IEEE754::Tools - Various tools for understanding and manipulating the underlying IEEE-754 representation of floating point values

=head1 SYNOPSIS

    use Data::IEEE754::Tools qw/:convertToString :ulp/;

    # return -12.875 as strings of decimal or hexadecimal floating point numbers ("convertTo*Character" in IEEE-754 parlance)
    convertToDecimalString(-12.875);        # -0d1.6093750000000000p+0003
    convertToHexString(-12.875);            # -0x1.9c00000000000p+0003

    # shows the smallest value you can add or subtract to 16.16 (ulp = "Unit in the Last Place")
    print ulp( 16.16 );                     # 3.5527136788005e-015

    # toggles the ulp: returns a float that has the ULP of 16.16 toggled
    #   (if it was a 1, it will be 0, and vice versa);
    #   running it twice should give the original value
    print $t16 = toggle_ulp( 16.16 );       # 16.159999999999997
    print $v16 = toggle_ulp( $t16 );        # 16.160000000000000

=head1 DESCRIPTION

These tools give access to the underlying IEEE 754 floating-point 64bit representation
used by many instances of Perl (see L<perlguts>).  They include functions for converting
from the 64bit internal representation to a string that shows those bits (either as
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

=head2 Compatibility

B<Data::IEEE754::Tools> works with 64bit floating-point representations.

If you have a Perl setup which uses a larger representation (for example,
C<use L<Config>; print $Config{nvsize}; # 16 =E<gt> 128bit>), values reported by
this module will be reduced in precision to fit the 64bit representation.

If you have a Perl setup which uses a smaller representation (for example,
C<use L<Config>; print $Config{nvsize}; # 4 =E<gt> 32bit>), the installation
will likely fail, because the unit tests were not set up for lower precision
inputs.  However, forcing the installation I<might> still allow coercion
from the smaller Perl NV into a true IEEE 754 double (64bit) floating-point,
but there is no guarantee it will work.

=head1 INTERFACE NOT YET STABLE

Please note: the interface to this module is not yet stable.  There may be changes
to function naming conventions (under_scores vs. camelCase, argument order, etc).
Once B<Data::IEEE754::Tools> hits v1.000, the interface should be stable for all
sub-versions of v1: existing functions should keep the same calling conventions,
though new functions may be added; significant changes to the interface will cause
a transition to v2.

=over

=item * v0.013_003

=over

=item * C<nextup()> renamed to C<nextUp()>

=item * C<nextdown()> renamed to C<nextDown()>

=item * C<nextafter()> renamed to C<nextAfter()>

=back

=item * v0.013_008

=over

=item * C<absolute()> renamed to C<abs()>, and noted that perl's builtin can be accessed via C<CORE::abs()>

=back

=item * v0.14001

=over

=item * messed up version numbering convention.  Fixed at v0.016.

=back

=item * v0.017_002

=over

=item * C<:floatingpoint> renamed to C<:convertToString>

=item * C<to_hex_floatingpoint()> renamed to C<convertToHexString()> (or C<Data::Tools::IEEE754::binary64_convertToHexCharacter()>)

=item * C<to_dec_floatingpoint()> renamed to C<convertToDecimalString()> (or C<Data::Tools::IEEE754::binary64_convertToDecimalCharacter()>)

=item * C<:raw754> renamed to C<:internalString>

=item * C<hexstr754_from_double()> renamed to C<convertToInternalHexString()>

=item * C<binstr754_from_double()> renamed to C<convertToInternalBinaryString()>

=item * C<hexstr754_to_double()> renamed to C<convertFromInternalHexString()>

=item * C<binstr754_to_double()> renamed to C<convertFromInternalBinaryString()>

=back

For backward compatibility, the old names are available, but the new names are recommended.

=back

=head1 EXPORTABLE FUNCTIONS AND VARIABLES

=cut

my  @EXPORT_RAW754 = qw(
    hexstr754_from_double   hexstr754_to_double
    binstr754_from_double   binstr754_to_double
);
my @EXPORT_INTERNALS = qw(
    convertToInternalHexString      convertToInternalBinaryString
    convertFromInternalHexString    convertFromInternalBinaryString
);

my  @EXPORT_FLOATING = qw(to_hex_floatingpoint to_dec_floatingpoint);           # deprecated
my  @EXPORT_CONVERT2STR = qw(convertToHexString convertToDecimalString);
my  @EXPORT_ULP = qw(ulp toggle_ulp nextUp nextDown nextAfter);
my  @EXPORT_CONST = qw(
    POS_ZERO
    POS_DENORM_SMALLEST POS_DENORM_BIGGEST
    POS_NORM_SMALLEST POS_NORM_BIGGEST
    POS_INF
    POS_SNAN_FIRST POS_SNAN_LAST
    POS_IND POS_QNAN_FIRST POS_QNAN_LAST
    NEG_ZERO
    NEG_DENORM_SMALLEST NEG_DENORM_BIGGEST
    NEG_NORM_SMALLEST NEG_NORM_BIGGEST
    NEG_INF
    NEG_SNAN_FIRST NEG_SNAN_LAST
    NEG_IND NEG_QNAN_FIRST NEG_QNAN_LAST
);
my @EXPORT_INFO = qw(isSignMinus isNormal isFinite isZero isSubnormal
    isInfinite isNaN isSignaling isSignalingConvertedToQuiet isCanonical
    class radix totalOrder totalOrderMag compareFloatingValue compareFloatingMag);
my @EXPORT_SIGNBIT = qw(copy negate abs copySign isSignMinus);

my @EXPORT_BINARY64 = qw(
    binary64_convertToInternalHexString
    binary64_convertFromInternalHexString
    binary64_convertToInternalBinaryString
    binary64_convertFromInternalBinaryString
    binary64_convertToHexString
    binary64_convertToDecimalString
);

our @EXPORT = ();
our @EXPORT_OK = (@EXPORT_FLOATING, @EXPORT_CONVERT2STR, @EXPORT_RAW754, @EXPORT_INTERNALS, @EXPORT_ULP, @EXPORT_CONST, @EXPORT_INFO, @EXPORT_SIGNBIT, @EXPORT_BINARY64);
our %EXPORT_TAGS = (
    convertToString     => [@EXPORT_CONVERT2STR],
    floating            => [@EXPORT_FLOATING],      # deprecated
    floatingpoint       => [@EXPORT_FLOATING],      # deprecated
    internalString      => [@EXPORT_INTERNALS],
    raw754              => [@EXPORT_RAW754],        # deprecated
    ulp                 => [@EXPORT_ULP],
    constants           => [@EXPORT_CONST],
    info                => [@EXPORT_INFO],
    signbit             => [@EXPORT_SIGNBIT],
    binary64            => [@EXPORT_BINARY64],
    all                 => [@EXPORT_OK],
);

=head2 :internalString

These are the functions to do raw conversion from a floating-point value to a hexadecimal or binary
string of the underlying IEEE754 encoded value, and back.

=head3 convertToInternalHexString( I<value> )

Converts the floating-point I<value> into a big-endian hexadecimal representation of the underlying
IEEE754 encoding.

    convertToInternalHexString(12.875);     #  4029C00000000000
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

Of course, this is easier to decode using the L</convertToDecimalString()> function, which interprets
the sign, fraction, and exponent for you.  (See below for more details.)

    convertToDecimalString(12.875);         # +0d1.6093750000000000p+0003
                                            # ^  ^^^^^^^^^^^^^^^^^^  ^^^^
                                            # :  :                   :
                                            # :  `- coefficient      `- exponent (power of 2)
                                            # :
                                            # `- sign

=head3 convertToInternalBinaryString( I<value> )

Converts the floating-point I<value> into a big-endian binary representation of the underlying
IEEE754 encoding.

    convertToInternalBinaryString(12.875);  # 0100000000101001110000000000000000000000000000000000000000000000
                                            # ^
                                            # `- sign
                                            #  ^^^^^^^^^^^
                                            #  `- exponent
                                            #             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                            #             `- fraction

The first bit is the sign, the next 11 are the exponent's encoding

=head3 convertFromInternalHexString( I<str> )

The inverse of C<convertToInternalHexString()>: it takes a string representing the 16 nibbles
of the IEEE754 double value, and converts it back to a perl floating-point value.

    print convertFromInternalHexString('4029C00000000000');
    12.875

=head3 convertFromInternalBinaryString( I<str> )

The inverse of C<convertToInternalBinaryString()>: it takes a string representing the 64 bits
of the IEEE754 double value, and converts it back to a perl floating-point value.

    print convertFromInternalBinaryString('0100000000101001110000000000000000000000000000000000000000000000');
    12.875

=cut

my ($_helper64_arr2x32b,$_helper128_arr4x32b);

# Perl 5.10 introduced the ">" and "<" modifiers for pack which can be used to
# force a specific endianness.
if( $] lt '5.010' ) {
    my $str = join('', unpack("H*", pack 'L' => 0x12345678));
    if('78563412' eq $str) {        # little endian, so reverse byteorder
        *binary64_convertToInternalHexString        = sub { return uc unpack('H*' => reverse pack 'd'  => shift); };
        *binary64_convertToInternalBinaryString     = sub { return uc unpack('B*' => reverse pack 'd'  => shift); };

        *binary64_convertFromInternalHexString      = sub { return    unpack('d'  => reverse pack 'H*' => shift); };
        *binary64_convertFromInternalBinaryString   = sub { return    unpack('d'  => reverse pack 'B*' => shift); };

        $_helper64_arr2x32b                         = sub { return    unpack('N2' => reverse pack 'd'  => shift); };
        $_helper128_arr4x32b                        = ($Config{d_longdbl})
                                                    ? sub { return    unpack('N4' => reverse pack 'D'  => shift); }     # long doubles are a "thing"
                                                    : sub { undef };                                                    # else don't know how to do this
    } elsif('12345678' eq $str) {   # big endian, so keep default byteorder
        *binary64_convertToInternalHexString        = sub { return uc unpack('H*' =>         pack 'd'  => shift); };
        *binary64_convertToInternalBinaryString     = sub { return uc unpack('B*' =>         pack 'd'  => shift); };

        *binary64_convertFromInternalHexString      = sub { return    unpack('d'  =>         pack 'H*' => shift); };
        *binary64_convertFromInternalBinaryString   = sub { return    unpack('d'  =>         pack 'B*' => shift); };

        $_helper64_arr2x32b                         = sub { return    unpack('N2' =>         pack 'd'  => shift); };
        $_helper128_arr4x32b                        = ($Config{d_longdbl})
                                                    ? sub { return    unpack('N4' =>         pack 'D'  => shift); }     # long doubles are a "thing"
                                                    : sub { undef };                                                    # else don't know how to do this
    } else {
        # I don't handle middle-endian / mixed-endian; sorry
        carp sprintf "\n\n%s %s configuration error:\n"
            ."\tCannot understand your system's endianness.\n"
            ."\tPlease report a bug in %s.ENDIAN#%d('%s'),\n"
            ."\tand include your machine's output of perl -V.\n"
            ."\tAlso, let me know if you're willing to run test\n"
            ."\tversions on your machine, to help me debug.\n"
            ."\tThanks.\n"
            ."\n",
            __PACKAGE__, $VERSION, $VERSION, (caller)[2], defined $str ? $str : '<undef>';

        *binary64_convertToInternalHexString        = sub { 'UNKNOWN ENDIANNESS' };
        *binary64_convertToInternalBinaryString     = sub { 'UNKNOWN ENDIANNESS' };

        *binary64_convertFromInternalHexString      = sub { undef };
        *binary64_convertFromInternalBinaryString   = sub { undef };
        $_helper64_arr2x32b                         = sub { undef };
        $_helper128_arr4x32b                        = sub { undef };
    }
} else {
        *binary64_convertToInternalHexString        = sub { return uc unpack('H*' =>         pack 'd>' => shift); };
        *binary64_convertToInternalBinaryString     = sub { return uc unpack('B*' =>         pack 'd>' => shift); };

        *binary64_convertFromInternalHexString      = sub { return    unpack('d>' =>         pack 'H*' => shift); };
        *binary64_convertFromInternalBinaryString   = sub { return    unpack('d>' =>         pack 'B*' => shift); };

        $_helper64_arr2x32b                         = sub { return    unpack('N2' =>         pack 'd>' => shift); };
        $_helper128_arr4x32b                        = sub { return    unpack('N4' =>         pack 'D>' => shift); };
}

# issue#6: canonical camelCase name, generic versions
*convertToInternalHexString         = \&binary64_convertToInternalHexString;
*convertToInternalBinaryString      = \&binary64_convertToInternalBinaryString;
*convertFromInternalHexString       = \&binary64_convertFromInternalHexString;
*convertFromInternalBinaryString    = \&binary64_convertFromInternalBinaryString;
# TODO: issue#7 switch, per below

# backward compatibility:
*hexstr754_from_double              = \&convertToInternalHexString;
*binstr754_from_double              = \&convertToInternalBinaryString;
*hexstr754_to_double                = \&convertFromInternalHexString;
*binstr754_to_double                = \&convertFromInternalBinaryString;

=head2 :convertToString

=head3 convertToHexString( I<value> [, I<conversionSpecification>] )

=head3 convertToDecimalString( I<value> [, I<conversionSpecification>] )

Converts value to a hexadecimal or decimal floating-point notation that indicates the sign and
the coefficient and the power of two, with the coefficient either in hexadecimal or decimal
notation.

    convertToHexString(-3.9999999999999996)         # -0x1.fffffffffffffp+0001
    convertToDecimalString(-3.9999999999999996)     # -0d1.9999999999999998p+0001

The optional I<conversionSpecification> argument is an integer specifying the number of digits
after the fractional-point.  By default, C<convertToHexString()> uses 13 hex-digits and
C<convertToDecimalString()> uses 16 decimal-digits, because those are the minimum number of
digits to always distinguish one ULP; if you choose the I<conversionSpecification> below default,
it will round your results; if you choose the I<conversionSpecification> above default,
the correctness of digits beyond the default is B<not> guaranteed (it may even round back to 13
hex-digits or 16 decimal-digits).

    convertToHexString(-3.9999999999999996, 16)     # -0x1.fffffffffffff000p+0001
    convertToHexString(-3.9999999999999996, 10)     # -0x2.0000000000p+0001
    convertToDecimalString(-3.9999999999999996, 18) # -0d1.999999999999999778p+0001 (the last three digits may be different on your system, or may round to -0d1.9999999999999998p+0001)
    convertToDecimalString(-3.9999999999999996, 10) # -0d2.0000000000p+0001

=cut

sub DBG_SPRINTF {
    return unless $Data::IEEE754::Tools::CPANTESTERS_DEBUG;
    my $fmt = shift;
    warn sprintf("# __%04d__\t", (caller)[2]), sprintf( $fmt, @_ ), "\n";
}
use Devel::Peek ();
sub DBG_PEEK {
    return unless $Data::IEEE754::Tools::CPANTESTERS_DEBUG;
    my ($name, $var) = @_;
    open( my $ek , '>&STDERR') or die "dup STDERR: $!";
    close(STDERR);
    my $txt;
    open(STDERR, '>', \$txt) or die "STDERR to var: $!";
    Devel::Peek::Dump($var);
    close(STDERR);
    open(STDERR, ">&", $ek) or die "STDERR back to orig: $!";
    $txt =~ s/^/# \t\t# /gims;
    $txt =~ s/\s*$//gims;
    DBG_SPRINTF("__%04d__\tDevel::Peek::Dump(%s):\n%s", (caller)[2], $name, $txt);
}
sub binary64_convertToHexString {
    # thanks to BrowserUK @ http://perlmonks.org/?node_id=1167146 for slighly better decision factors
    # I tweaked it to use the two 32bit words instead of one 64bit word (which wouldn't work on some systems)
print STDERR "#\n" if $Data::IEEE754::Tools::CPANTESTERS_DEBUG;
DBG_SPRINTF('binary64_convertToHexString()');
DBG_SPRINTF("\t%-16s = %d", $_ => $Config{$_}) foreach( qw/nvsize ivsize doublesize intsize longsize ptrsize/ );
    my $v = shift;
    my $p = defined $_[0] ? shift : 13;
    my ($msb,$lsb) = $_helper64_arr2x32b->($v);
    my $sbit = ($msb & 0x80000000) >> 31;
    my $sign = $sbit ? '-' : '+';
    my $exp  = (($msb & 0x7FF00000) >> 20) - 1023;
    my $mhex = sprintf '%05x', $msb & 0x000FFFFF;
    my $lhex = sprintf '%08x', $lsb & 0xFFFFFFFF;
    my $mant = $mhex . $lhex;
DBG_SPRINTF('[msb][lsb] = 0x%08x %08x => digits=%d', $msb, $lsb, $p);
DBG_SPRINTF('... = %s %s . %s pwr %d', $sign, '?', $mant, $exp);
    if($exp == 1024) {
        my $z = "0"x (($p<5?4:$p)-4);
        return $sign . "0x1.#INF${z}p+0000"    if $mant eq '0000000000000';
        return $sign . "0x1.#IND${z}p+0000"    if $mant eq '8000000000000' and $sign eq '-';
        $z = "0"x (($p<6?5:$p)-5);
        return $sign . ( (($msb & 0x00080000) != 0x00080000) ? "0x1.#SNAN${z}p+0000" : "0x1.#QNAN${z}p+0000");  # v0.012 coverage note: '!=' condition only triggered on systems with SNAN; ignore Devel::Cover failures on this line on systems which quiet all SNAN to QNAN
    }
    my $implied = 1;
DBG_SPRINTF('... = %s %s . %s pwr %d', $sign, $implied, $mant, $exp);
    if( $exp == -1023 ) { # zero or denormal
        $implied = 0;
        $exp = $mant eq '0000000000000' ? 0 : -1022;   # 0 for zero, -1022 for denormal
    }
DBG_SPRINTF('... = %s %s . %s pwr %d', $sign, $implied, $mant, $exp);
    if( $p>12 ) {
DBG_SPRINTF('%s0x%1u.%13.13sp%+05d', $sign, $implied, $mant . '0'x($p-13), $exp);
        return sprintf '%s0x%1u.%13.13sp%+05d', $sign, $implied, $mant . '0'x($p-13), $exp;
    } else {
        my $roundhex = substr $mant, 0, $p;
        my $nibble = substr $mant, $p, 1;
        my $carry = hex($nibble)>7 ? 1 : 0;
        foreach my $cp ( 1 .. $p ) {
            $nibble = substr $roundhex, -$cp, 1;
            my $v = hex($nibble)+$carry;
            ($carry, $v) = (16==$v) ? (1,0) : (0, $v);
            $nibble = sprintf '%01x', $v;
            substr($roundhex, -$cp, 1) = $nibble;
        }
DBG_SPRINTF('{%02d} %13.13s => [%13.13s] [%1.1s] <%01d>', $p, $mant, $roundhex, $nibble, $carry);
        $implied += $carry;
        my $ret = sprintf '%s0x%1u%s%*sp%+05d', $sign, $implied, $p?'.':'', $p, $roundhex, $exp;
DBG_SPRINTF('ret=%s', $ret);
        return $ret;
    }
}
*convertToHexString = \&binary64_convertToHexString;
my $__glue_dispatch;    # issue#7 TODO
if(0) { # issue#7 TODO
    $__glue_dispatch = sub {    # only use this subref in the glue code, not in any subroutine
        my ($arg, %h) = @_;
        croak sprintf "\n\n%s %s configuration error:\n"
            ."\tCould not determine the right setup for your system.\n"
            ."\tPlease report a bug in %s.DISPATCH_TABLE#%d('%s').\n"
            ."\tIt would be helpful to include the output of perl -V\n"
            ."\tin the bug report.  Thanks.\n"
            ."\n",
            __PACKAGE__, $VERSION, $VERSION, (caller)[2], defined $arg ? $arg : '<undef>'
        unless exists $h{$arg};
        return $h{$arg};
    };

    *convertToHexString = $__glue_dispatch->( $Config{nvsize},
        4  => \&binary32_convertToHexString,
        8  => \&binary64_convertToHexString,
        16 => \&binary128_convertToHexString,
    );
}
*to_hex_floatingpoint = \&convertToHexString;

sub binary64_convertToDecimalString {
    # derived from binary64_convertToHexString
    my $v = shift;
    my $p = defined $_[0] ? shift : 16;
    my ($msb,$lsb) = $_helper64_arr2x32b->($v);
    my $sbit = ($msb & 0x80000000) >> 31;
    my $sign = $sbit ? '-' : '+';
    my $exp  = (($msb & 0x7FF00000) >> 20) - 1023;
    my $mant = sprintf '%05x%08x', $msb & 0x000FFFFF, $lsb & 0xFFFFFFFF;
    if($exp == 1024) {
        my $z = "0"x (($p<5?4:$p)-4);
        return $sign . "0d1.#INF${z}p+0000"    if $mant eq '0000000000000';
        return $sign . "0d1.#IND${z}p+0000"    if $mant eq '8000000000000' and $sign eq '-';
        $z = "0"x (($p<6?5:$p)-5);
        return $sign . ( (($msb & 0x00080000) != 0x00080000) ? "0d1.#SNAN${z}p+0000" : "0d1.#QNAN${z}p+0000");  # v0.012 coverage note: '!=' condition only triggered on systems with SNAN; ignore Devel::Cover failures on this line on systems which quiet all SNAN to QNAN
    }
    my $implied = 1;
    if( $exp == -1023 ) { # zero or denormal
        $implied = 0;
        $exp = $mant eq '0000000000000' ? 0 : -1022;   # 0 for zero, -1022 for denormal
    }
    #$mant = (($msb & 0x000FFFFF)*4_294_967_296.0 + ($lsb & 0xFFFFFFFF)*1.0) / (2.0**52);
    #sprintf '%s0d%1u.%.16fp%+05d', $sign, $implied, $mant, $exp;
    my $other = abs($v) / (2.0**$exp);
    sprintf '%s0d%.*fp%+05d', $sign, $p, $other, $exp;
}
*convertToDecimalString = \&binary64_convertToDecimalString;
if(0) { # issue#7 TODO
    *convertToDecimalString = $__glue_dispatch->( $Config{nvsize},
        4  => \&binary32_convertToDecimalString,
        8  => \&binary64_convertToDecimalString,
        16 => \&binary128_convertToDecimalString,
    );
}
*to_dec_floatingpoint = \&convertToDecimalString;

=head4 interpretation

It displays the value as (sign)(0base)(implied).(fraction)p(exponent):

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
aid in understanding the actual number, the C<:convertToCharacter> conversions represent
them as +0000 for zero, and -1022 for denormals: since denormals are C<(0+fraction)*(2**min_exp)>,
they are really multiples of 2**-1022, not 2**-1023.

=back

For backward compatibility, if you use the older tag C<:floatingpoint>, you can refer to these
functions as C<to_hex_floatingpoint()> and C<to_dec_floatingpoint()>.

=head3 Data::IEEE754::Tools::binary64_convertToHexCharacter( I<value> )

=head3 Data::IEEE754::Tools::binary64_convertToDecimalCharacter( I<value> )

These are the same functions, but under the official IEEE 754 nomenclature of
C<E<lt>typeE<gt>_convertTo*Character()>.  These are included for the "canonical"
naming convention, but are not exportable.

=cut

*binary64_convertToHexCharacter     = \&binary64_convertToHexString;
*binary64_convertToDecimalCharacter = \&binary64_convertToDecimalString;

=head2 :constants

These can be useful as references for the specialty values, and include the positive and negative
zeroes, infinities, a variety of signaling and quiet NAN values.

    POS_ZERO             # +0x0.0000000000000p+0000  # signed zero (positive)
    POS_DENORM_SMALLEST  # +0x0.0000000000001p-1022  # smallest positive value that requires denormal representation in 64bit floating-point
    POS_DENORM_BIGGEST   # +0x0.fffffffffffffp-1022  # largest positive value that requires denormal representation in 64bit floating-point
    POS_NORM_SMALLEST    # +0x1.0000000000000p-1022  # smallest positive value that allows for normal representation in 64bit floating-point
    POS_NORM_BIGGEST     # +0x1.fffffffffffffp+1023  # largest positive value that allows for normal representation in 64bit floating-point
    POS_INF              # +0x1.#INF000000000p+0000  # positive infinity: indicates that the answer is out of the range of a 64bit floating-point
    POS_SNAN_FIRST       # +0x1.#SNAN00000000p+0000  # positive signaling NAN with "0x0000000000001" as the system-dependent information [*]
    POS_SNAN_LAST        # +0x1.#SNAN00000000p+0000  # positive signaling NAN with "0x7FFFFFFFFFFFF" as the system-dependent information [*]
    POS_IND              # +0x1.#QNAN00000000p+0000  # positive quiet NAN with "0x8000000000000" as the system-dependent information [%]
    POS_QNAN_FIRST       # +0x1.#QNAN00000000p+0000  # positive quiet NAN with "0x8000000000001" as the system-dependent information
    POS_QNAN_LAST        # +0x1.#QNAN00000000p+0000  # positive quiet NAN with "0xFFFFFFFFFFFFF" as the system-dependent information

    NEG_ZERO             # -0x0.0000000000000p+0000  # signed zero (negative)
    NEG_DENORM_SMALLEST  # -0x0.0000000000001p-1022  # smallest negative value that requires denormal representation in 64bit floating-point
    NEG_DENORM_BIGGEST   # -0x0.fffffffffffffp-1022  # largest negative value that requires denormal representation in 64bit floating-point
    NEG_NORM_SMALLEST    # -0x1.0000000000000p-1022  # smallest negative value that allows for normal representation in 64bit floating-point
    NEG_NORM_BIGGEST     # -0x1.fffffffffffffp+1023  # largest negative value that allows for normal representation in 64bit floating-point
    NEG_INF              # -0x1.#INF000000000p+0000  # negative infinity: indicates that the answer is out of the range of a 64bit floating-point
    NEG_SNAN_FIRST       # -0x1.#SNAN00000000p+0000  # negative signaling NAN with "0x0000000000001" as the system-dependent information [*]
    NEG_SNAN_LAST        # -0x1.#SNAN00000000p+0000  # negative signaling NAN with "0x7FFFFFFFFFFFF" as the system-dependent information [*]
    NEG_IND              # -0x1.#IND000000000p+0000  # negative quiet NAN with "0x8000000000000" as the system-dependent information [%]
    NEG_QNAN_FIRST       # -0x1.#QNAN00000000p+0000  # negative quiet NAN with "0x8000000000001" as the system-dependent information
    NEG_QNAN_LAST        # -0x1.#QNAN00000000p+0000  # negative quiet NAN with "0xFFFFFFFFFFFFF" as the system-dependent information

	[*] note that many perl interpreters will internally convert Signalling NaN (SNAN) to Quiet NaN (QNAN)
	[%] some perl interpreters define the zeroeth negative Quiet NaN, NEG_IND, as an "indeterminate" value (IND);
	    in a symmetrical world, they would also define the zeroeth positive Quiet NaN, POS_IND, as an "indeterminate" value (IND)

=cut

{ my $local; sub POS_ZERO           () { $local = binary64_convertFromInternalHexString('000'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub POS_DENORM_SMALLEST() { $local = binary64_convertFromInternalHexString('000'.'0000000000001') unless defined $local; return $local; } }
{ my $local; sub POS_DENORM_BIGGEST () { $local = binary64_convertFromInternalHexString('000'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub POS_NORM_SMALLEST  () { $local = binary64_convertFromInternalHexString('001'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub POS_NORM_BIGGEST   () { $local = binary64_convertFromInternalHexString('7FE'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub POS_INF            () { $local = binary64_convertFromInternalHexString('7FF'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub POS_SNAN_FIRST     () { $local = binary64_convertFromInternalHexString('7FF'.'0000000000001') unless defined $local; return $local; } }
{ my $local; sub POS_SNAN_LAST      () { $local = binary64_convertFromInternalHexString('7FF'.'7FFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub POS_IND            () { $local = binary64_convertFromInternalHexString('7FF'.'8000000000000') unless defined $local; return $local; } }
{ my $local; sub POS_QNAN_FIRST     () { $local = binary64_convertFromInternalHexString('7FF'.'8000000000001') unless defined $local; return $local; } }
{ my $local; sub POS_QNAN_LAST      () { $local = binary64_convertFromInternalHexString('7FF'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub NEG_ZERO           () { $local = binary64_convertFromInternalHexString('800'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub NEG_DENORM_SMALLEST() { $local = binary64_convertFromInternalHexString('800'.'0000000000001') unless defined $local; return $local; } }
{ my $local; sub NEG_DENORM_BIGGEST () { $local = binary64_convertFromInternalHexString('800'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub NEG_NORM_SMALLEST  () { $local = binary64_convertFromInternalHexString('801'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub NEG_NORM_BIGGEST   () { $local = binary64_convertFromInternalHexString('FFE'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub NEG_INF            () { $local = binary64_convertFromInternalHexString('FFF'.'0000000000000') unless defined $local; return $local; } }
{ my $local; sub NEG_SNAN_FIRST     () { $local = binary64_convertFromInternalHexString('FFF'.'0000000000001') unless defined $local; return $local; } }
{ my $local; sub NEG_SNAN_LAST      () { $local = binary64_convertFromInternalHexString('FFF'.'7FFFFFFFFFFFF') unless defined $local; return $local; } }
{ my $local; sub NEG_IND            () { $local = binary64_convertFromInternalHexString('FFF'.'8000000000000') unless defined $local; return $local; } }
{ my $local; sub NEG_QNAN_FIRST     () { $local = binary64_convertFromInternalHexString('FFF'.'8000000000001') unless defined $local; return $local; } }
{ my $local; sub NEG_QNAN_LAST      () { $local = binary64_convertFromInternalHexString('FFF'.'FFFFFFFFFFFFF') unless defined $local; return $local; } }

=head2 :ulp

=head3 ulp( I<value> )

Returns the ULP ("Unit in the Last Place") for the given I<value>, which is the smallest number
that you can add to or subtract from I<value> and still be able to discern a difference between
the original and modified.  Under normal (or denormal) circumstances, C<ulp($val) + $val E<gt> $val>
is true.

If the I<value> is a zero or a denormal, C<ulp()> will return the smallest possible denormal.

Since INF and NAN are not really numbers, C<ulp()> will just return the same I<value>.  Because
of the way they are handled, C<ulp($val) + $val E<gt> $val> no longer makes sense (infinity plus
anything is still infinity, and adding NAN to NAN is not numerically defined, so a numerical
comparison is meaningless on both).

=cut

my $TWONEG52        = sub { 2.0**-52 };
my $FIFTYTWOZEROES  = sub { '0'x52 };

sub ulp {   # ulp_by_div
    my $val = shift;
    my $rawbin = binary64_convertToInternalBinaryString($val);
    my ($sgn, $exp, $frac) = ($rawbin =~ /(.)(.{11})(.{52})/);

    return $val             if $exp eq '11111111111';   # return SELF for INF or NAN
    return POS_DENORM_SMALLEST   if $exp eq '00000000000';   # return first positive denorm for 0 or denorm

    # this method will multiply by 2**-52 (as a constant) after
    $sgn  = '0';
    $frac = $FIFTYTWOZEROES->();
    $val  = binary64_convertFromInternalBinaryString( $sgn . $exp . $frac );
    $val *= $TWONEG52->();
}

=head3 toggle_ulp( I<value> )

Returns the orginal I<value>, but with the ULP toggled.  In other words, if the ULP bit
was a 0, it will return a value with the ULP of 1 (equivalent to adding one ULP to a positive
I<value>); if the ULP bit was a 1, it will return a value with the ULP of 0 (equivalent to
subtracting one ULP from a positive I<value>).  Under normal (or denormal) circumstances,
C<toggle_ulp($val) != $val> is true.

Since INF and NAN are not really numbers, C<ulp()> will just return the same I<value>.  Because
of the way they are handled, C<toggle_ulp($val) != $val> no longer makes sense.

=cut

sub toggle_ulp {
    my $val = shift;
    my $rawbin = binary64_convertToInternalBinaryString($val);
    my ($sign, $exp, $fract) = ($rawbin =~ /(.)(.{11})(.{52})/);

    # INF and NAN do not have a meaningful ULP; just return SELF
    if( $exp == '1'x11 ) {
        return $val;
    }

    # ZERO, DENORMAL, and NORMAL: toggle the last bit of fract
    my $ulp_bit = substr $fract, -1;
    substr $fract, -1, 1, (1-$ulp_bit);
    $rawbin = join '', $sign, $exp, $fract;
    return binary64_convertFromInternalBinaryString($rawbin);
}

=head3 nextUp( I<value> )

Returns the next floating point value numerically greater than I<value>; that is, it adds one ULP.
Returns infinite when I<value> is the highest normal floating-point value.
Returns I<value> when I<value> is positive-infinite or NAN; returns the largest negative normal
floating-point value when I<value> is negative-infinite.

C<nextUp> is an IEEE 754r standard function (754-2008 #5.3.1).

=cut

sub nextUp {
    # thanks again to BrowserUK: http://perlmonks.org/?node_id=1167146
    my $val = shift;
    return $val                                     if $val != $val;                # interestingly, NAN != NAN
    my $h754 = binary64_convertToInternalHexString($val);
    return $val                                     if $h754 eq '7FF0000000000000'; # return self               for +INF
    return binary64_convertFromInternalHexString('FFEFFFFFFFFFFFFF')  if $h754 eq 'FFF0000000000000'; # return largest negative   for -INF
    return binary64_convertFromInternalHexString('0000000000000001')  if $h754 eq '8000000000000000'; # return +SmallestDenormal  for -ZERO
    my ($msb,$lsb) = $_helper64_arr2x32b->($val);
    $lsb += ($msb & 0x80000000) ? -1.0 : +1.0;
    if($lsb == 4_294_967_296.0) {
        $lsb  = 0.0;
        $msb += 1.0;    # v0.012: LSB==4e9 only happens if you add one to LSB = 0xFFFFFFFF, so only when +msb; thus, remove extra check for msb sign here
    } elsif ($lsb == -1.0) {
        $lsb  = 0xFFFFFFFF;
        $msb -= 1.0;    # v0.012: LSB==-1  only happens if you subtract one from LSB = 0x00000000, so only when -msb; thus, remove extra check for msb sign here
    }
    $msb &= 0xFFFFFFFF;     # v0.011_001: bugfix: ensure 32bit MSB <https://rt.cpan.org/Public/Bug/Display.html?id=116006>
    $lsb &= 0xFFFFFFFF;     # v0.011_001: bugfix: ensure 32bit MSB <https://rt.cpan.org/Public/Bug/Display.html?id=116006>
    return binary64_convertFromInternalHexString( sprintf '%08X%08X', $msb, $lsb );
}

=head3 nextDown( I<value> )

Returns the next floating point value numerically lower than I<value>; that is, it subtracts one ULP.
Returns -infinity when I<value> is the largest negative normal floating-point value.
Returns I<value> when I<value> is negative-infinite or NAN; returns the largest positive normal
floating-point value when I<value> is positive-infinite.

C<nextDown> is an IEEE 754r standard function (754-2008 #5.3.1).

=cut

sub nextDown {
    return - nextUp( - $_[0] );
}

=head3 nextAfter( I<value>, I<direction> )

Returns the next floating point value after I<value> in the direction of I<direction>.  If the
two are identical, return I<direction>; if I<direction> is numerically above I<float>, return
C<nextUp(I<value>)>; if I<direction> is numerically below I<float>, return C<nextDown(I<value>)>.

=cut

sub nextAfter {
    return $_[0]            if $_[0] != $_[0];      # return value when value is NaN
    return $_[1]            if $_[1] != $_[1];      # return direction when direction is NaN
    return $_[1]            if $_[1] == $_[0];      # return direction when the two are equal
    return nextUp($_[0])    if $_[1] > $_[0];       # return nextUp if direction > value
    return nextDown($_[0]);                         # otherwise, return nextDown()
}

=head2 :info

The informational functions include various operations (defined in 754-2008 #5.7.2) that provide general
information about the floating-point value: most define whether a value is a special condition of
floating-point or not (such as normal, finite, zero, ...).

=head3 isSignMinus( I<value> )

Returns 1 if I<value> has negative sign (even applies to zeroes and NaNs); otherwise, returns 0.

=cut

sub isSignMinus {
    # look at leftmost nibble, and determine whether it has the 8-bit or not (which is the sign bit)
    return (hex(substr(binary64_convertToInternalHexString(shift),0,1)) & 8) >> 3;
}

=head3 isNormal( I<value> )

Returns 1 if I<value> is a normal number (not zero, subnormal, infinite, or NaN); otherwise, returns 0.

=cut

sub isNormal {
    # it's normal if the leftmost three nibbles (excluding sign bit) are not 000 or 7FF
    my $exp = hex(substr(binary64_convertToInternalHexString(shift),0,3)) & 0x7FF;
    return (0 < $exp) && ($exp < 0x7FF) || 0;
}

=head3 isFinite( I<value> )

Returns 1 if I<value> is a finite number (zero, subnormal, or normal; not infinite or NaN); otherwise, returns 0.

=cut

sub isFinite {
    # it's finite if the leftmost three nibbles (excluding sign bit) are not 7FF
    my $exp = hex(substr(binary64_convertToInternalHexString(shift),0,3)) & 0x7FF;
    return ($exp < 0x7FF) || 0;
}

=head3 isZero( I<value> )

Returns 1 if I<value> is positive or negative zero; otherwise, returns 0.

=cut

sub isZero {
    # it's zero if it's 0x[80]000000000000000
    my $str = substr(binary64_convertToInternalHexString(shift),1,15);
    return ($str eq '0'x15) || 0;
}

=head3 isSubnormal( I<value> )

Returns 1 if I<value> is subnormal (not zero, normal, infinite, nor NaN); otherwise, returns 0.

=cut

sub isSubnormal {
    # it's subnormal if it's 0x[80]00___ and the last 13 digits are not all zero
    my $h   = binary64_convertToInternalHexString(shift);
    my $exp = substr($h,0,3);
    my $frc = substr($h,3,13);
    return ($exp eq '000' || $exp eq '800') && ($frc ne '0'x13) || 0;
}

=head3 isInfinite( I<value> )

Returns 1 if I<value> is positive or negative infinity (not zero, subnormal, normal, nor NaN); otherwise, returns 0.

=cut

sub isInfinite {
    # it's infinite if it's 0x[F7]FF_0000000000000
    my $h   = binary64_convertToInternalHexString(shift);
    my $exp = substr($h,0,3);
    my $frc = substr($h,3,13);
    return ($exp eq '7FF' || $exp eq 'FFF') && ($frc eq '0'x13) || 0;
}

=head3 isNaN( I<value> )

Returns 1 if I<value> is NaN (not zero, subnormal, normal, nor infinite); otherwise, returns 0.

=cut

sub isNaN {
    # it's infinite if it's 0x[F7]FF_0000000000000
    my $h   = binary64_convertToInternalHexString(shift);
    my $exp = substr($h,0,3);
    my $frc = substr($h,3,13);
    return ($exp eq '7FF' || $exp eq 'FFF') && ($frc ne '0'x13) || 0;
}

=head3 isSignaling( I<value> )

Returns 1 if I<value> is a signaling NaN (not zero, subnormal, normal, nor infinite), otherwise, returns 0.

Note that some perl implementations convert some or all signaling NaNs to quiet NaNs, in which case,
C<isSignaling> might return only 0.

=cut

sub isSignaling {
    # it's signaling if isNaN and MSB of fractional portion is 1
    my $h   = binary64_convertToInternalHexString(shift);
    my $exp = substr($h,0,3);
    my $frc = substr($h,3,13);
    my $qbit = (0x8 && hex(substr($h,3,1))) >> 3;   # 1: quiet, 0: signaling
    return ($exp eq '7FF' || $exp eq 'FFF') && ($frc ne '0'x13)  && (!$qbit) || 0;  # v0.013_007 = possible coverage bug: don't know whether it's the paren or non-paren, but the "LEFT=TRUE" condition of "OR 2 CONDITIONS" is never covered
}

=head4 isSignalingConvertedToQuiet()

Returns 1 if your implementation of perl converts a SignalingNaN to a QuietNaN, otherwise returns 0.

This is I<not> a standard IEEE 754 function; but this is used to determine if the C<isSignaling()>
function is meaningful in your implementation of perl.

=cut

sub isSignalingConvertedToQuiet {
    !isSignaling( POS_SNAN_FIRST ) || 0     # v0.013 coverage note: ignore Devel::Cover failures on this line -- will be only LEFT on quiet systems vs. only RIGHT on signaling systems
}

=head3 isCanonical( I<value> )

Returns 1 to indicate that I<value> is Canonical.

Per IEEE Std 754-2008, "Canonical" is the "preferred" encoding.  Based on the
B<Data::IEEE754::Tools>'s author's reading of the standard, non-canonical
applies to decimal floating-point encodings, not the binary floating-point
encodings that B<Data::IEEE754::Tools> handles.  Since there are not multiple
choicesfor the representation of a binary-encoded floating-point, all
I<value>s seem canonical, and thus return 1.

=cut

sub isCanonical { 1 }

=head3 class( I<value> )

Returns the "class" of the I<value>:

    signalingNaN
    quietNaN
    negativeInfinity
    negativeNormal
    negativeSubnormal
    negativeZero
    positiveZero
    positiveSubnormal
    positiveNormal
    positiveInfinity

=cut

sub class {
    return 'signalingNaN'       if isSignaling($_[0]);      # v0.013 coverage note: ignore Devel::Cover failures on this line (won't return on systems that quiet SNaNs)
    return 'quietNaN'           if isNaN($_[0]);
    return 'negativeInfinity'   if isInfinite($_[0])    && isSignMinus($_[0]);
    return 'negativeNormal'     if isNormal($_[0])      && isSignMinus($_[0]);
    return 'negativeSubnormal'  if isSubnormal($_[0])   && isSignMinus($_[0]);
    return 'negativeZero'       if isZero($_[0])        && isSignMinus($_[0]);
    return 'positiveZero'       if isZero($_[0])        && !isSignMinus($_[0]);     # v0.013 coverage note: ignore Devel::Cover->CONDITION failure; alternate condition already returned above
    return 'positiveSubnormal'  if isSubnormal($_[0])   && !isSignMinus($_[0]);     # v0.013 coverage note: ignore Devel::Cover->CONDITION failure; alternate condition already returned above
    return 'positiveNormal'     if isNormal($_[0])      && !isSignMinus($_[0]);     # v0.013 coverage note: ignore Devel::Cover->CONDITION failure; alternate condition already returned above
    return 'positiveInfinity'   if isInfinite($_[0])    && !isSignMinus($_[0]);     # v0.013 coverage note: no tests for FALSE because all conditions covered above
}

=head3 radix( I<value> )

Returns the base (radix) of the internal floating point representation.
This module works with the binary floating-point representations, so will always return 2.

=cut

sub radix { 2 }

=head3 totalOrder( I<x>, I<y>  )

Returns TRUE if I<x> E<le> I<y>, FALSE if I<x> E<gt> I<y>.

Special cases are ordered as below:

    -quietNaN < -signalingNaN < -infinity < ...
    ... < -normal < -subnormal < -zero < ...
    ... < +zero < +subnormal < +normal < ...
    ... < +infinity < +signalingNaN < +quietNaN

=cut

sub totalOrder {
    my ($x, $y) = @_[0,1];
    my ($bx,$by) = map { binary64_convertToInternalBinaryString($_) } $x, $y;        # convert to binary strings
    my @xsegs = ($bx =~ /(.)(.{11})(.{20})(.{32})/);                # split into sign, exponent, MSB, LSB
    my @ysegs = ($by =~ /(.)(.{11})(.{20})(.{32})/);                # split into sign, exponent, MSB, LSB
    my ($xin, $yin) = map { isNaN($_) } $x, $y;                     # determine if NaN: used twice each, so save the values rather than running twice each during if-switch

    if( $xin && $yin ) {                                            # BOTH NaN
        # use a trick: the rules for both-NaN treat it as if it's just another floating point,
        #  so lie about the exponent and do a normal comparison
        ($bx, $by) = map { $_->[1] = '1' . '0'x10; join '', @$_ } \@xsegs, \@ysegs;
        ($x, $y) = map { binary64_convertFromInternalBinaryString($_) } $bx, $by;
        return (($x <= $y) || 0);
    } elsif ( $xin ) {                                              # just x NaN: TRUE if x is NEG
        return ( ($xsegs[0]) || 0 );
    } elsif ( $yin ) {                                              # just y NaN: TRUE if y is not NEG
        return ( (!$ysegs[0]) || 0 );
    } elsif ( isZero($x) && isZero($y) ) {                          # both zero: TRUE if x NEG, or if x==y
        # trick = -signbit(x) <= -signbit(y), since signbit is 1 for negative, -signbit = -1 for negative
        return ( (-$xsegs[0] <= -$ysegs[0]) || 0 );
    } else {                                                        # numeric comparison (works for inf, normal, subnormal, or only one +/-zero)
        return( ($x <= $y) || 0 );
    }
}

=head3 totalOrderMag( I<x>, I<y> )

Returns TRUE if I<abs(x)> E<le> I<abs(y)>, otherwise FALSE.
Equivalent to

    totalOrder( abs(x), abs(y) )

Special cases are ordered as below:

    zero < subnormal < normal < infinity < signalingNaN < quietNaN

=cut

sub totalOrderMag {
    my ($x, $y)     = @_[0,1];
    my ($bx,$by)    = map { binary64_convertToInternalBinaryString($_) } $x, $y;                         # convert to binary strings
    ($x,  $y)       = map { substr $_, 0, 1, '0'; binary64_convertFromInternalBinaryString($_) } $bx, $by;   # set sign bit to 0, and convert back to number
    return totalOrder( $x, $y );                                                        # compare normally
}

=head3 compareFloatingValue( I<x>, I<y> )

=head3 compareFloatingMag( I<x>, I<y> )

These are similar to C<totalOrder()> and C<totalOrderMag()>, except they return
-1 for C<x E<lt> y>, 0 for C<x == y>, and +1 for C<x E<gt> y>.

These are not in IEEE 754-2008, but are included as functions to replace the perl spaceship
(C<E<lt>=E<gt>>) when comparing floating-point values that might be NaN.

=cut

sub compareFloatingValue {
    my ($x, $y) = @_[0,1];
    my ($bx,$by) = map { binary64_convertToInternalBinaryString($_) } $x, $y;        # convert to binary strings
    my @xsegs = ($bx =~ /(.)(.{11})(.{20})(.{32})/);                # split into sign, exponent, MSB, LSB
    my @ysegs = ($by =~ /(.)(.{11})(.{20})(.{32})/);                # split into sign, exponent, MSB, LSB
    my ($xin, $yin) = map { isNaN($_) } $x, $y;                     # determine if NaN: used twice each, so save the values rather than running twice each during if-switch

    if( $xin && $yin ) {                                            # BOTH NaN
        # use a trick: the rules for both-NaN treat it as if it's just another floating point,
        #  so lie about the exponent and do a normal comparison
        ($bx, $by) = map { $_->[1] = '1' . '0'x10; join '', @$_ } \@xsegs, \@ysegs;
        ($x, $y) = map { binary64_convertFromInternalBinaryString($_) } $bx, $by;
        return ($x <=> $y);
    } elsif ( $xin ) {                                              # just x NaN: if isNaN(x) && isNegative(x) THEN -1 (x<y) ELSE (x>y)
        return ( ($xsegs[0])*-1 || +1 );
    } elsif ( $yin ) {                                              # just y NaN: if isNaN(y) && !isNegative(y) THEN -1 (x<y) ELSE (x>y)
        return ( (!$ysegs[0])*-1 || +1 );
    } elsif ( isZero($x) && isZero($y) ) {                          # both zero: TRUE if x NEG, or if x==y
        # trick = -signbit(x) <=> -signbit(y), since signbit is 1 for negative, -signbit = -1 for negative
        return (-$xsegs[0] <=> -$ysegs[0]);
    } else {                                                        # numeric comparison (works for inf, normal, subnormal, or only one +/-zero)
        return ($x <=> $y);
    }
}

sub compareFloatingMag {
    my ($x, $y)     = @_[0,1];
    my ($bx,$by)    = map { binary64_convertToInternalBinaryString($_) } $x, $y;                         # convert to binary strings
    ($x,  $y)       = map { substr $_, 0, 1, '0'; binary64_convertFromInternalBinaryString($_) } $bx, $by;   # set sign bit to 0, and convert back to number
    return compareFloatingValue( $x, $y );                                              # compare normally
}

=head2 :signbit

These functions, from IEEE Std 754-2008, manipulate the sign bits
of the argument(s)set P.

See IEEE Std 754-2008 #5.5.1 "Sign bit operations": This section asserts
that the sign bit operations (including C<negate>, C<abs>, and C<copySign>)
should only affect the sign bit, and should treat numbers and NaNs alike.

=head3 copy( I<value> )

Copies the I<value> to the output, leaving the sign bit unchanged, for all
numbers and NaNs.

=cut

sub copy {
	return shift;
}

=head3 negate( I<value> )

Reverses the sign bit of I<value>.  (If the sign bit is set on I<value>,
it will not be set on the output, and vice versa; this will work on
signed zeroes, on infinities, and on NaNs.)

=cut

sub negate {
    my $b = binary64_convertToInternalBinaryString(shift);                                               # convert to binary string
    my $s = 1 - substr $b, 0, 1;                                                        # toggle sign
    substr $b, 0, 1, $s;                                                                # replace sign
    return binary64_convertFromInternalBinaryString($b);                                                     # convert to floating-point
}

=head3 abs( I<value> )

Similar to the C<CORE::abs()> builtin function, C<abs()> is provided as a
module-based function to get the absolute value (magnitude) of a 64bit
floating-point number.

The C<CORE::abs()> function behaves properly (per the IEEE 754 description)
for all classes of I<value>, except that many implementations do not correctly
handle -NaN properly, outputting -NaN, which is in violation of the standard.
The C<Data::IEEE754::Tools::abs()> function correctly treats NaNs in the same
way it treats numerical values, and clears the sign bit on the output.

Please note that exporting C<abs()> or C<:signbit> from this module will
"hide" the builtin C<abs()> function.  If you really need to use the builtin
version (for example, you care more about execution speed than its ability to find
the absolute value of a signed NaN), then you may call it as C<CORE::abs>.

=cut

sub abs {
    my $b = binary64_convertToInternalBinaryString(shift);                                               # convert to binary string
    substr $b, 0, 1, '0';                                                               # replace sign
    return binary64_convertFromInternalBinaryString($b);                                                     # convert to floating-point
}

=head3 copySign( I<x>, I<y> )

Copies the sign from I<y>, but uses the value from I<x>.  For example,

    $new = copySign( 1.25, -5.5);   # $new is -1.25: the value of x, but the sign of y

=cut

sub copySign {
    my ($x, $y)         = @_[0,1];
    my ($bx,$by)        = map { binary64_convertToInternalBinaryString($_) } $x, $y;    # convert to binary strings
    substr($bx, 0, 1)   = substr($by, 0, 1);                                            # copy the sign bit from y to x
    return binary64_convertFromInternalBinaryString($bx);                               # convert binary-x (with modified sign) back to double
}

=head3 also exports C<isSignMinus(> I<value> C<)> (see :info)

(:signbit also exports the C<isSignMinus()> function, described in :info, above)

=head2 :all

Include all of the above.

=head1 INSTALLATION

To install this module, use your favorite CPAN client.

For a manual install, type the following:

    perl Makefile.PL
    make
    make test
    make install

(On Windows machines, you may need to use "dmake" or "gmake" instead of "make", depending on your setup.)

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
However, I was inspired by its byteorder-dependent anonymous subs (which were in turn derived from L<Data::MessagePack::PP>);
they were more efficient, on a per-call-to-subroutine basis, than my original inclusion of the if(byteorder) in every call to
the sub.

=item * L<Data::Float>: Similar to this module, but uses numeric manipulation.

=back

=head1 AUTHOR

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Data-IEEE754-Tools AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-IEEE754-Tools>,
or thru the repository's interface at L<https://github.com/pryrt/Data-IEEE754-Tools/issues>.

=begin html

<a href="https://metacpan.org/pod/Data::IEEE754::Tools><img src="https://img.shields.io/cpan/v/Data-IEEE754-Tools.svg?colorB=00CC00" alt="" title="metacpan"></a>
<a href="http://matrix.cpantesters.org/?dist=Data-IEEE754-Tools"><img src="http://cpants.cpanauthors.org/dist/Data-IEEE754-Tools.png" alt="" title="cpan testers"></a>
<a href="https://github.com/pryrt/Data-IEEE754-Tools/releases"><img src="https://img.shields.io/github/release/pryrt/Data-IEEE754-Tools.svg" alt="" title="github release"></a>
<a href="https://github.com/pryrt/Data-IEEE754-Tools/issues"><img src="https://img.shields.io/github/issues/pryrt/Data-IEEE754-Tools.svg" alt="" title="issues"></a>
<a href="https://travis-ci.org/pryrt/Data-IEEE754-Tools"><img src="https://travis-ci.org/pryrt/Data-IEEE754-Tools.svg?branch=master" alt="" title="build status"></a>
<a href="https://coveralls.io/github/pryrt/Data-IEEE754-Tools?branch=master"><img src="https://coveralls.io/repos/github/pryrt/Data-IEEE754-Tools/badge.svg?branch=master" alt="" title="test coverage"></a>

=end html

=head1 COPYRIGHT

Copyright (C) 2016-2017 Peter C. Jones

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

=cut

1;
