=pod

=head1 NAME

Data::IEEE754::Tools - Various tools for understanding and manipulating the underlying IEEE-754 representation of floating point values

=head1 SYNOPSIS

    use Data::IEEE754::Tools qw/expand_ieee754/;
    print expand_ieee754(-1.5, 'binary', 'fraction');

=head1 DESCRIPTION

The L<IEEE754|https://en.wikipedia.org/wiki/IEEE_floating_point> standard describes
various floating-point encodings.  The double format (`binary64') is a 64-bit base-2
encoding, and correpsonds to the usual Perl floating value (NV). The format  includes the
sign (s), the power of 2 (q), and a coefficient (c): C<value = ((-1)**s) * (c) * (2**q)>.
The C<(-1)**s> term evaluates to the SIGN of the number, where s=0 means the sign
is +1 and s=1 means the sign is -1.
The coefficient is internally encoded as an implied 1 plus an encoded FRACTION,
which is itself encoded as a 52-bit integer divided by an implied 2**52.

L<Data::IEEE754>, or the equivalent L<perlfunc/pack> recipe L<dE<gt>>, do a
good job of converting a perl floating value (NV) into the big-endian bytes
that encode that value, but they don't help you interpret the value.

This B<Data::IEEE754::Tools> module takes it to the next step, and provideds
the tools to expand the encoded floating point value into its component sign,
fraction, and exponent, so you can see how it is encoded internally.

=head2 FEATURES

=over

=item * will allow fraction to be represented as numerator/denominator or as a floating-point number

=item * will allow fraction to be represented in binary or hexadecimal or decimal

=item * will allow reducing the fraction (removing common factors of 2 or 16) to simplify interpretation

=back

=head1 EXPORTABLE FUNCTIONS AND VARIABLES

=head2 :expand = ( I<expand_ieee754> )

=head3 expand_ieee754( I<value> [, I<opts>] )

Expands the value given into the typical form C<sign * (1 + fraction) * (2**exponent)>.
Depending your options (either the I<opts> argument, or the values of the
C<%Data::IEEE754::Tools::EXPAND_OPTS> hash), it will display the "1 + fraction" in either
hexadecimal, binary, or decimal form (but the "(2**exponent)" will always be in decimal
notation); it can display the fraction as either in a fractional form,

        [       numerator ]
    +/- [ 1 + ----------- ] * (2**exponent)
        [     denominator ]

or as a floating point value,

    +/- 0x1.8A00_0000_0000_0  * (2**exponent)
    +/- 0b1.1000_1010_0000_...  * (2**exponent)
    +/- 1.562_484_741_2... * (2**exponent)

You can also determine whether the fraction or floating-point will "reduce" the fraction
(getting rid of extra multiples of 2 or 16).

For infinite values, will use the usual stringification for your system (often "Inf").
For NaN (not a number), there are nearly 2**52 possible it will combine the typical stringification
(often "NaN") with the extra bits in parentheses (implementations are allowed to use
those bits to further clarify what kind of "NaN" it is indicating).

=over

=item value

This is the floating point number you want to inspect the underlying IEEE754 encoding on.

=item opts

This is either a list of option and value pairs

    expand_ieee754($val, base =E<gt> 'binary', reduce =E<gt> 1>

or a hash reference to the same

    expand_ieee754($val, base =E<gt> 'binary', reduce =E<gt> 1>

They take the same option names (hash keys) as the L</%GLOBAL_OPTS>, described below.

=back

=head2 :options

=head3 %GLOBAL_OPTS

The %GLOBAL_OPTS has contains the default expand_ieee754 options, which can be overridden on
a per-call basis by passing the same keys to C<expand_ieee754()>.

=over

=item $GLOBAL_OPTS{base} = I<'str'>

=item expand_ieee754(..., base =E<gt> I<str>)

Sets the output display for C<expand_ieee754()> to display in the appropriate base, indicated
by I<str>, which can be one of 'hexadecimal' ('hex', 'x', or 'h' also allowed), 'decimal'
(or 'dec' or 'd'), or 'binary' (or 'bin' or 'b').

Defaults to binary.

=item $GLOBAL_OPTS{reduce} = I<bool>

=item expand_ieee754(..., reduce =E<gt> I<bool>)

If I<bool> is true, sets the output display for C<expand_ieee754()> to reduce any fractions:
in floating-point notation, it will reduce the number of significant figures displayed; in
fractional notation, it will reduce the integers displayed in the numerator and denominator
of the fraction.

Defaults to false (display using all digits).

These examples show how toggling C<reduce>'s I<bool> influence the output:

    say expand_ieee754(12.875, base => 'hex', reduce => 0);
    +0x1.9C00_0000_0000_0 * (2**3)

    say expand_ieee754(12.875, base => 'hex', reduce => 1);
    +0x1.9C * (2**3)

=item $GLOBAL_OPTS{drawFraction} = I<bool>

=item expand_ieee754(..., drawFraction =E<gt> I<bool>)

If I<bool> is true, sets the output display for C<expand_ieee754()> to display fractions
as a numerator over the denominator; if false, sets the display to a floating-point
notation, in the given base.

Defaults to false (display using floating-point notation).

Compare the following examples with C<drawFraction =E<gt> 1> to the examples from
the previous section, which had an implied (default) C<drawFraction =E<gt> 0>:
in the previous section.

    say expand_ieee754(12.875, base => 'hex', reduce => 0, drawFraction => 1);
      [     0x09C0_0000_0000_00 ]
    + [ 1 + ------------------- ] * (2**3) = 12.875
      [     0x1000_0000_0000_00 ]

    say expand_ieee754(12.875, base => 'hex', reduce => 1, drawFraction => 1);
      [     0x09C ]
    + [ 1 + ----- ] * (2**3) = 12.875
      [     0x100 ]

    say expand_ieee754(12.875, base => 'hex', reduce => 1, drawFraction => 0);
    +0x1.9C * (2**3)

=back

=head2 :convert

These are the functions to do raw conversion from a floating-point value to a hexadecimal or binary
string of the underlying IEEE754 encoded value, and back.

=head3 hexstr754_from_double( I<val> )

Converts the floating-point I<val> into a big-endian hexadecimal representation of the underlying
IEEE754 encoding.

    say hexstr754_from_double(12.875);
    4029C00000000000
    ^^^
    sign+exponent
       ^^^^^^^^^^^^^
       fraction


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

Of course, this is easier to decode using the L</expand_ieee754()> function.

    say expand_ieee754(12.875, base => 'hex', reduce => 1, drawFraction => 1);
      [     0x09C ]
    + [ 1 + ----- ] * (2**3) = 12.875
      [     0x100 ]
    ^       ^^^^^      ^^^^
    sign    fraction   exponent

Which interprets the sign, fraction, and exponent for you.

=head3 binstr754_from_double( I<val> )

Converts the floating-point I<val> into a big-endian binary representation of the underlying
IEEE754 encoding.

    say binstr754_from_double(12.875);
    0100000000101001110000000000000000000000000000000000000000000000
    ^
    sign
     ^^^^^^^^^^^
     exponent
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                fraction

The first bit is the sign, the next 11 are the exponent's encoding

=head3 hexstr754_to_double( I<str> )

The inverse of I<hexstr754_from_double()>: it takes a string representing the 16 nibbles
of the IEEE754 double value, and converts it back to a perl floating-point value.

    say hexstr754_to_double('4029C00000000000');
    12.875

=head3 binstr754_to_double( I<str> )

The inverse of I<binstr754_from_double()>: it takes a string representing the 64 bits
of the IEEE754 double value, and converts it back to a perl floating-point value.

    say binstr754_to_double('0100000000101001110000000000000000000000000000000000000000000000');
    12.875

=head1 ACKNOWLEDGEMENTS

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

=back

=head1 AUTHOR AND CONTACT INFORMATION

Peter C. Jones C<E<lt>petercj AT cpan DOT orgE<gt>>

Please report any bugs or feature requests emailing C<E<lt>bug-Data-IEEE754-Tools AT rt.cpan.orgE<gt>>
or thru the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-IEEE754-Tools>.

=head1 LICENSE

Copyright (C) 2016 Peter C. Jones

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.



=cut
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-06-29 09:27:27 -0700 (Wed, 29 Jun 2016) $
#   $Revision: 198 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/Tools.pm $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Tools/Tools.pm 198 2016-06-29 16:27:27Z pryrtmx $
#   $Id: Tools.pm 198 2016-06-29 16:27:27Z pryrtmx $
########################################################################
package Data::IEEE754::Tools;
use 5.008005;
use warnings;
use strict;
use Carp;
use Exporter 'import';  # just use the import() function, without the rest of the overhead of ISA

use version 0.77; our $VERSION = version->declare('v0.006');

our %EXPAND_OPTS = (
    base => 'b',
    drawFraction => 0,
    reduce => 0
);

our @EXPORT_CONVERT = qw(hexstr754_from_double binstr754_from_double hexstr754_to_double binstr754_to_double);
our @EXPORT_EXPAND = qw(expand_ieee754);
our @EXPORT_OPTIONS = qw(%EXPAND_OPTS);
our @EXPORT_OK = (@EXPORT_EXPAND, @EXPORT_OPTIONS, @EXPORT_CONVERT);
our %EXPORT_TAGS = (
    expand  => [@EXPORT_EXPAND],
    options => [@EXPORT_OPTIONS],
    convert => [@EXPORT_CONVERT],
);

# Perl 5.10 introduced the ">" and "<" modifiers for pack which can be used to
# force a specific endianness.
if( $] lt '5.010' ) {
    my $str = join('', unpack("H*", pack 'L' => 0x12345678));
    if('78563412' eq $str) {        # little endian, so reverse byteorder
        *hexstr754_from_double = sub { return uc unpack('H*' => reverse pack 'd'  => shift); };
        *binstr754_from_double = sub { return uc unpack('B*' => reverse pack 'd'  => shift); };

        *hexstr754_to_double     = sub { return    unpack('d'  => reverse pack 'H*' => shift); };
        *binstr754_to_double     = sub { return    unpack('d'  => reverse pack 'B*' => shift); };
    } elsif('12345678' eq $str) {   # big endian, so keep default byteorder
        *hexstr754_from_double = sub { return uc unpack('H*' =>         pack 'd'  => shift); };
        *binstr754_from_double = sub { return uc unpack('B*' =>         pack 'd'  => shift); };

        *hexstr754_to_double     = sub { return    unpack('d'  =>         pack 'H*' => shift); };
        *binstr754_to_double     = sub { return    unpack('d'  =>         pack 'B*' => shift); };
    } else {
        # I don't handle middle-endian / mixed-endian; sorry
        *hexstr754_from_double = sub { undef };
        *binstr754_from_double = sub { undef };

        *hexstr754_to_double     = sub { undef };
        *binstr754_to_double     = sub { undef };
    }
} else {
        *hexstr754_from_double = sub { return uc unpack('H*' =>         pack 'd>' => shift); };
        *binstr754_from_double = sub { return uc unpack('B*' =>         pack 'd>' => shift); };

        *hexstr754_to_double     = sub { return    unpack('d>' =>         pack 'H*' => shift); };
        *binstr754_to_double     = sub { return    unpack('d>' =>         pack 'B*' => shift); };
}

sub expand_ieee754($;@) {
    # $ = double precision ieee754 floating point: 64bit total = 1bit sign + 11bit exponent (offset) + 52bit fraction + 0bit implied 1+ before fraction
    #       Thus, value of ieee754 = ( (sign?-1:+1) * (implied_1 + fraction / (2**52)) * (2**(exponent-bias)) )
    # @ = arguments:
    #       'hex' overrides 'binary'
    #           'binary' [default] => 0b1.0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101
    #           'hex' => 0x1.1234_5678_9abc_d               (13 nibbles = 13x4 bits = 52 fractional bits)
    #           'decimal' => +1.002_929_687_5 * (2**7)      (not guaranteed exact)
    #       'fraction' overrides 'point'
    #           'point' [default] => examples above
    #           'fraction' =>
    #                 [     0b0_0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 ]
    #               + [ 1 + -------------------------------------------------------------------- ] * (2**-3)
    #                 [     0b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 ]
    #       'reduce' overrides 'allbits'
    #           'allbits' [default] => examples above
    #
    my $val = shift;
    my $rawbin = binstr754_from_double($val);
    my ($sign, $exp, $fract) = ($rawbin =~ /(.)(.{11})(.{52})/);
    $sign += 0;                                         # convert to number
    $exp = oct("0b$exp") - 1023;                        # convert to number, and adjust for the IEEE754 Exponent Bias for a double (binary64)
    my ($numer, $denom, $out) = ($fract, '0'x52, '');
    my $isDenormal = 0;

    # parse options
    my %opt = (%EXPAND_OPTS);   # defaults
    my %in_opts = defined($_[0]) ? (ref($_[0]) ? (%{$_[0]}) : (@_)) : ();   # if there is another argument, determine if it's a hashref or a raw hash
    foreach my $k (keys %opt) {             # loop thru all valid %opts keys
        next unless exists  $in_opts{$k};   # don't need to import this key if it's not in the in options
        next unless defined $in_opts{$k};   # don't want to override default if it's included but undefined
        $opt{$k} = $in_opts{$k};            # otherwise, override the default option value with the argument option
    }
    foreach($opt{base}) {                   # shrink down hexadecimal/hex to h, decimal/dec to d, binary/bin to b
        s/^(16|x|h|hex|hexadecimal)$/x/i;
        s/^(10|d|dec|decimal)$/d/i;
        s/^(2|b|bin|binary)$/b/i;
    }
    $opt{base} = 'b' unless $opt{base} =~ /^(b|d|x)$/;   # override invalid base with
    my ($base, $drawFraction, $reduce) = @opt{'base', 'drawFraction', 'reduce'};

    # update $fract
    if($base eq 'x') {
        my $rawhex = hexstr754_from_double($val);
        $fract = substr $rawhex, -13;
        $numer   = $fract;
        $denom   = '0'x13;
    } elsif ($base eq 'd') {
        my ($left, $right) = ( $fract =~ /^(.{20})(.{32})$/ );
        $numer = sprintf '%.0f', (2.0**32)*oct("0b$left") + 1.0*oct("0b$right");
        $denom = sprintf '%.0f', (2.0**52);
        $fract = sprintf '%.0f', $numer;
    }

    # check for special conditions
    if( $exp == 1024 ) {
        # stringify to INF or NaN
        $out = "" . $val;

        # for NaN, also include the FRACT encoding      # NAN has fract != all zeroes
        $out .= " (0${base}$fract)"    if( $fract =~ /[^0]/ );
        return $out;
    } elsif ( $exp == -1023 ) {
        #Zero
        return $sign?"-0":"+0" if $fract eq '0'x52 or $fract eq '0'x13 or $fract eq '0';

        #DeNormal
        ++$isDenormal;
        ++$exp;
    }

    if($base eq 'd') {                                              # decimal: convert to num & den, optionally reduce, then add commas every 3 characters
        if($drawFraction) {                                             # 1,234,567
            if($reduce) {
                while($numer and 0 == $numer % 2) {
                    $numer /= 2;
                    $denom /= 2;
                }
            }
            $numer = sprintf '%.0f', $numer;
            $denom = sprintf '%.0f', $denom;
            foreach ($numer, $denom) { s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g; }   # http://www.perlmonks.org/?node_id=117697: the fewest number of digits that has only multiples of 3 digits beyond it
        } else {                                                        # .123,456,7
            $numer = sprintf('%.*f', $isDenormal ? 24 : 16, (abs($val) / (2**$exp)));
            if($reduce) {
                $numer =~ s/0+$//g;   # remove all trailing zeroes
            }
            my ($in,$fr) = split /\./, $numer;
            $fr = '0' unless defined $fr;
            foreach ($in) { s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g; }          # integer needs 1,234,567-style
            foreach ($fr) { s/(\d{3})(?=\d)/$1_/g; }                    # 3 digits, followed by a non-capturing match of at least 1 digit
            $out = ( $sign ? '-' : '+' ) . "${in}.${fr} * (2**$exp)";
        }
    } elsif( $base =~ /^[xb]$/ ) {                                      # hex or binary: optionally reduce, add _ every four chars, and for fractional, prefix num and denom with 0b or 0x
        if($reduce) {
            $numer =~ s/0+$//g;    # remove all trailing zeroes
            $denom = '0' x length($numer);
        }
        if($drawFraction) {
            $numer = '0'.$numer;
            $denom = '1'.$denom;
        }
        foreach ($numer, $denom) { s/([[:xdigit:]]{1,4})/_$1/g; }
        if($drawFraction) { # fractional
            $numer = "0${base}$numer";
            $denom = "0${base}$denom";
            foreach ($numer, $denom) { s/${base}_/${base}/; }
        } else {            # floatingpoint
            my $int = $isDenormal ? 0 : 1;
            ($out = ( $sign ? '-' : '+' ) . "0${base}${int}.$numer * (2**$exp)") =~ s/\._/./;
        }

    }

    # convert to fraction
    if($drawFraction) {
        my $dash = '-' x length($denom);
        $numer  = (' ' x length($denom)) . $numer;
        $numer  = substr $numer, -length($denom);
        my $int = $isDenormal ? '0' : '1';
        $out     = "";
        $out    .= "  [     $numer ]\n";
        $out    .= '' . ( $sign ? '-' : '+' ) . " [ $int + $dash ] * (2**" . $exp . ") = $val\n";
        $out    .= "  [     $denom ]";
    }

    if(0) { # debug only
        local $" = ", ";
        my @tmp = map { "$_=>'$opt{$_}'" } keys(%{ ref($_[0]) ? $_[0] : +{@_} });
        $out = "expand_ieee754(@{[$val, @tmp]})\n\n$out";
        $out .= "\n\n-----\n\n";
    }

    return $out;
}

# TODO = v0.007 = add additional tools:
#       * ulp(val): convert val to hex; change $fract-portion to 0000000000001, and convert back to value
#       * val_plus_ulp(val): return val+ulp(val) {or do the math on the $fract-portion of val, though that includes much error checking}
#       * val_minus_ulp(val): return val-ulp(val) {or do the math on the $fract-portion of val, though that includes much error checking}
#       => for test/, ensure that val_plus_ulp(val) -> hex is only off by one digit from val->hex

1;
