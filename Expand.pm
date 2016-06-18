#!/bin/env perl
########################################################################
=pod

=head1 NAME

Data::IEEE754::Expand - Takes an IEEE754 double, and expands it to SIGN * (1+FRACTION) * (2**EXPONENT)

=head1 SYNOPSIS

    use Data::IEEE754::Expand qw/expand_ieee754/;
    print expand_ieee754(-1.5, 'binary', 'fraction');

=head1 DESCRIPTION

Takes an IEEE754 double, and expands it to SIGN * (1+FRACTION) * (2**EXPONENT).

The L<IEEE754|https://en.wikipedia.org/wiki/IEEE_floating_point> standard describes
various floating-point encodings.  The double format (`binary64') is a 64-bit base-2
encoding, and correpsonds to the usual Perl floating value (NV). The format  includes the
sign (s), the power of 2 (q), and a coefficient (c): C<value = ((-1)**s) * (c) * (2**q)>.
The C<(-1)**s> term evaluates to the SIGN of the number, where s=0 means the sign
is +1 and s=1 means the sign is -1.
The coefficient is internally encoded as an implied 1 plus an encoded FRACTION,
which is itself encoded as a 52-bit integer divided by an implied 2**52.

L<Data::IEEE754>, or the equivalent L<perlfunc/pack> recipe L<dE<gt>>, does a
good job of converting a perl floating value (NV) into the big-endian bytes
that encode that value, but don't help you interpret.

This B<Data::IEEE754::Expand> module takes it to the next step, and provideds
the tools to expand the encoded floating point value into its component sign,
fraction, and exponent, so you can see how it is encoded internally.

=head2 FEATURES

=over

=item * will allow fraction to be represented as numerator/denominator or as a floating-point number

=item * will allow fraction to be represented in binary or hexadecimal or decimal

=item * will allow reducing the fraction (removing common factors of 2 or 16) to simplify interpretation

=back

=head1 ACKNOWLEDGEMENTS

=over

=item * L<What Every Compute Scientist Should Know About Floating-Point Arithmetic|https://docs.oracle.com/cd/E19957-01/806-3568/ncg_goldberg.html>

=item * L<Perlmonks: Integers sometimes turn into Reals after substraction|http://perlmonks.org/?node_id=1163025> for
inspiring me to go down the IEEE754-expansion trail in perl.

=item * L<Perlmonks: Exploring IEEE754 floating point bit patterns|http://perlmonks.org/?node_id=984141> as a resource
for how perl interacts with the various "edge cases" (+/-infinity, L<denormalized numbers|https://en.wikipedia.org/wiki/Denormal_number>,
signaling and quiet L<NaNs (Not-A-Number)|https://en.wikipedia.org/wiki/NaN>.

=item * L<Data::IEEE754>: I really wanted to use this module, but it didn't get me very far down the "Expand" track,
and included a lot of overhead modules for its install/test that I didn't want to require for B<Data::IEEE754::Expand>.
However, I was inspired by his byteorder-dependent anonymous subs (which were in turn derived from L<Data::MessagePack::PP>);
they were more efficient, on a per-call-to-subroutine basis, than my original inclusion of the if(byteorder) in every call to
the sub.

=back

=cut
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-06-17 15:09:51 -0700 (Fri, 17 Jun 2016) $
#   $Revision: 169 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/Expand.pm $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/Expand.pm 169 2016-06-17 22:09:51Z pryrtmx $
#   $Id: Expand.pm 169 2016-06-17 22:09:51Z pryrtmx $
########################################################################
package Data::IEEE754::Expand;
use warnings;
use strict;
use Carp;
use Config;

use version 0.77; our $VERSION = version->declare('v0.002.' . sprintf '%03d', (q$Revision: 169 $ =~ /(\d+)/) );   # PAUSE compatible SVN-based version-object; can have extra

# Perl 5.10 introduced the ">" and "<" modifiers for pack which can be used to
# force a specific endianness.
if( $] lt '5.010' ) {
    my $str = join('', unpack("H*", pack 'L' => 0x12345678));
    if('78563412' eq $str) {        # little endian, so reverse byteorder
        *get_raw_ieee754_hexstr_from_double = sub { return uc unpack('H*' => reverse pack 'd'  => shift); };
        *get_raw_ieee754_binstr_from_double = sub { return uc unpack('B*' => reverse pack 'd'  => shift); };

        *get_double_from_ieee754_hexstr     = sub { return    unpack('d'  => reverse pack 'H*' => shift); };
        *get_double_from_ieee754_binstr     = sub { return    unpack('d'  => reverse pack 'B*' => shift); };
    } elsif('12345678' eq $str) {   # big endian, so keep default byteorder
        *get_raw_ieee754_hexstr_from_double = sub { return uc unpack('H*' =>         pack 'd'  => shift); };
        *get_raw_ieee754_binstr_from_double = sub { return uc unpack('B*' =>         pack 'd'  => shift); };

        *get_double_from_ieee754_hexstr     = sub { return    unpack('d'  =>         pack 'H*' => shift); };
        *get_double_from_ieee754_binstr     = sub { return    unpack('d'  =>         pack 'B*' => shift); };
    } else {
        # TODO: there are 4!-2 = 22 potential middle-endian encodings; there has to be a way to programmatically
        #   determine which it is, without listing all 22 elseif conditions.
        my %nibbles = ( 12 => undef, 34 => undef, 56 => undef, 78 => undef );
        foreach my $k (reverse sort keys %nibbles) {
            pos($str) = 0;
            $str =~ /$k/g;
            $nibbles{$k} = pos($str);
        }
            # OOPS: it's really 8!, because 64bit has 8 nibbles; need to generate a known unique ieee754.double, and
            # base the decoding on that;
        *get_raw_ieee754_hexstr_from_double = sub { undef };
        *get_raw_ieee754_binstr_from_double = sub { undef };

        *get_double_from_ieee754_hexstr     = sub { undef };
        *get_double_from_ieee754_binstr     = sub { undef };
    }
} else {
        *get_raw_ieee754_hexstr_from_double = sub { return uc unpack('H*' =>         pack 'd>' => shift); };
        *get_raw_ieee754_binstr_from_double = sub { return uc unpack('B*' =>         pack 'd>' => shift); };

        *get_double_from_ieee754_hexstr     = sub { return    unpack('d>' =>         pack 'H*' => shift); };
        *get_double_from_ieee754_binstr     = sub { return    unpack('d>' =>         pack 'B*' => shift); };
}

sub ieee754_double2xxx_workhorse($;@) {
    # $ = double precision ieee754 floating point: 64bit total = 1bit sign + 11bit exponent (offset) + 52bit fraction + 0bit implied 1+ before fraction
    #       Thus, value of ieee754 = ( (sign?-1:+1) * (implied_1 + fraction / (2**52)) * (2**(exponent-bias)) )
    # @ = arguments:
    #       'hex' overrides 'binary'
    #           'binary' [default] => 0b1.0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101_0101
    #           'hex' => 0x1.1234_5678_9abc_d   (13 nibbles = 13x4 bits = 52 fractional bits)
    #           'decimal' => only valid with 'fraction'; see below
    #       'fraction' overrides 'point'
    #           'point' [default] => examples above
    #           'fraction' =>
    #                 [     0b0_0100_0111_1010_1110_0001_0100_0111_1010_1110_0001_0100_0111_1011 ]
    #               + [ 1 + -------------------------------------------------------------------- ] * (2**-3)
    #                 [     0b1_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 ]
    #           *** if 'fraction', then also allow 'decimal', so that you get { 1 + (decimal = 0 .. 2**52-1) / 2**52 } * sign * exponent
    #       'reduce' overrides 'allbits'
    #           'allbits' [default] => examples above
    #
    my $val = shift;
    my $rawbin = get_raw_ieee754_binstr_from_double($val);
    my ($sign, $exp, $fract) = ($rawbin =~ /(.)(.{11})(.{52})/);
    $sign += 0;                                         # convert to number
    $exp = oct("0b$exp") - 1023;                        # convert to number, and adjust for the IEEE754 Exponent Bias for a double (binary64)
    my ($num, $den, $out) = ($fract, '0'x52, '');

    if( $exp == 1024 ) {
        #INF or NaN
        print STDERR "\nINF or NaN: $sign $exp $fract\n";
        return "".$val; # stringify and return
    } elsif ( $exp == -1023 ) {
        #Zero or Denormal
        print STDERR "\nZERO or Denormal: $sign $exp $fract\n";
        return "0" if $fract eq '0000000000000000000000000000000000000000000000000000';
    }

    # parse options
    my ($base, $drawFraction, $reduce) = ('',0,0);
    foreach(@_) {
        $base .= 'x'        if /^hex(|adecimal)$/i;
        $base .= 'b'        if /^bin(|ary)$/i;
        $base .= 'd'        if /^dec(|imal)$/i;
        $drawFraction |= 1  if /^fraction$/i;
        $reduce |= 1        if /^reduce$/i;
    }
    $base = 'b'     if '' eq $base; # default
    unless(1 == length($base)) {
        my %replace = (b => 'binary', d => 'decimal', h => 'hexadecimal');
        my $msg = "Bases " . join(" and ", map { $replace{lc $_} } split(//, $base)) . " are mutuall exclusive: chose";
        $base = ($base =~ /b/i) ? 'b' : ($base =~ /h/i) ? 'h' : 'd';    # priority = binary > hexadecimal > decimal (so if all three, binary chosen; if two, then prefer binary over hex, and hex over decimal)
        carp "$msg $base";
    }

    my $fval = (abs($val) / (2**$exp) - 1) * (2**52);

    # if hex then convert 52bit fract to 13nibble fract
    if($base eq 'x') {
        $den = '0000000000000'; # implied 1 before... but don't want that there, yet

        # I'd like to just the integer form of $fval, converted to hex
        #   however, on machines with $Config{ivsize}=4, it cannot convert to a 13nibble hex (because a 4byte value is only 8 nibbles of integer space)
        if($Config{ivsize}>4) {
            $num = substr sprintf('%013X', $fval), -13;
        } else {
            my ($left, $right) = ( $fract =~ /^(\d{20})(\d{32})$/ );
            $num = sprintf "%05X%08X", oct("0b$left"), oct("0b$right");
        }
    }

    if($base eq 'd') {                                              # decimal: convert to num & den, optionally reduce, then add commas every 3 characters
        if($drawFraction) {                                             # 1,234,567
            my $p = 52;
            if($reduce) {
                while(0 == $fval % 2) {
                    --$p;
                    $fval /= 2;
                }
            }
            $num = sprintf '%.0f', abs($fval);
            $den = sprintf '%.0f', (2**$p);
            foreach ($num, $den) { s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g; }   # http://www.perlmonks.org/?node_id=117697: the fewest number of digits that has only multiples of 3 digits beyond it
        } else {                                                        # .123,456,7
            $num = sprintf "%.24f", abs($val) / (2**$exp);
            if($reduce) {
                $num =~ s/0+$//g;   # remove all trailing zeroes
            }
            my ($in,$fr) = split /\./, $num;
            foreach ($in) { s/(\d{1,3}?)(?=(\d{3})+$)/$1,/g; }          # integer needs 1,234,567-style
            foreach ($fr) { s/(\d{3})(?=\d)/$1_/g; }                    # 3 digits, followed by a non-capturing match of at least 1 digit
            $out = ( $sign ? '-' : '+' ) . "${in}.${fr} * (2**$exp)";
        }
    } elsif( $base =~ /^[xb]$/ ) {                                      # hex or binary: optionally reduce, add _ every four chars, and for fractional, prefix num and denom with 0b or 0x
        if($reduce) {
            $num =~ s/0+$//g;    # remove all trailing zeroes
            $den = '0' x length($num);
        }
        foreach ($num, $den) { s/([[:xdigit:]]{1,4})/_$1/g; }
        if($drawFraction) { # fractional
            $num = "0${base}0$num";
            $den = "0${base}1$den";
        } else {
            ($out = ( $sign ? '-' : '+' ) . "0${base}1.$num * (2**$exp)") =~ s/\._/./;
        }

    }

    # convert to fraction
    if($drawFraction) {
        my $dash = '-' x length($den);
        $num  = (' ' x length($den)) . $num;
        $num  = substr $num, -length($den);
        $out     = "";
        $out    .= "  [     $num ]\n";
        $out    .= '' . ( $sign ? '-' : '+' ) . ' [ 1 + ' . $dash . ' ] * (2**' . $exp . ") = $val\n";
        $out    .= "  [     $den ]";
    }

    if(1) { # debug only
        local $" = ", ";
        $out = "ieee754_double2xxx_workhorse(@{[$val, @_]})\n\n$out";
        $out .= "\n\n-----\n\n";
    }

    return $out;

    # 3.TODO = add callers that automate the options
    # 2.TODO (v0.004) = rename:
    #       module = Data::IEEE754::Tools
    #       raw functions = hexstr754_from_double() and hexstr754_to_double() (or binstr*)
    #       workhorse = expand_ieee754_workhorse()
    #       callers = expand_to_*(NV)
    # 1.TODO (v0.003) = since I now have the reverse functions, I have an idea for how to rework this, to get rid of some of the conversions
    #   between hex/binary/decimal
    #       x. use binstr764_from_double() as currently handled
    #       x. check exponent
    #           * ==emax+1 => isInf or isNaN, so just stringify: return $out = "".$in
    #           * ==emin-1 => isDenormal or isZero; if isDenormal, exp=emin; if isZero, exp=0; continue
    #           * else     => normal; continue
    #       c. determine whether it's hexadecimal/decimal/binary output
    #           * binary: I've got everything I need: numer comes from binary $fract; continue
    #           * hex: numer comes from hexstr754_from_double():
    #               new $fract = substr $hex, -13 (rightmost 13 chars)
    #               if isDenormal, 0+, else 1+
    #               continue
    #           * decimal:
    #               if drawFraction
    #                   (left,right) = ( fract =~ /(.{20})(.{32})$/ );  # split into 20bit and 32bit numbers, which both fit within 4byte integer
    #                   numer = (2.0**32)*oct("0b$left") + 1.0*oct("0b$right") -- this keeps it floating-point, so it will fit
    #                   denom = (2.0**52)
    #               else
    #                   numer = $fval                       # might be wrong for denormal; will need to look into it
    #                   out = sign . numer . "2**$exp"
    #       d. reduce (if applicable)
    #           * bin or hex: remove trailing 0s
    #           * decimal: if drawFraction, divide-by-2**k; else remove trailing 0s
    #       e. add commas/underscores (per existing code)
    #       f. output
}

1;
