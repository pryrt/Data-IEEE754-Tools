# NAME

Data::IEEE754::Tools - Various tools for understanding and manipulating the underlying IEEE-754 representation of floating point values

# SYNOPSIS

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

# DESCRIPTION

These tools give access to the underlying IEEE 754 floating-point 64bit representation
used by many instances of Perl (see [perlguts](https://metacpan.org/pod/perlguts)).  They include functions for converting
from the 64bit internal representation to a string that shows those bits (either as
hexadecimal or binary) and back, functions for converting that encoded value
into a more human-readable format to give insight into the meaning of the encoded
values, and functions to manipulate the smallest possible change for a given
floating-point value (which is the [ULP](https://en.wikipedia.org/wiki/Unit_in_the_last_place) or
"Unit in the Last Place").

## Justification for the existence of **Data::IEEE754::Tools**

[Data::IEEE754](https://metacpan.org/pod/Data::IEEE754), or the equivalent ["pack" in perlfunc](https://metacpan.org/pod/perlfunc#pack) recipe [d>](https://metacpan.org/pod/d>), do a
good job of converting a perl floating value (NV) into the big-endian bytes
that encode that value, but they don't help you interpret the value.

[Data::Float](https://metacpan.org/pod/Data::Float) has a similar suite of tools to **Data::IEEE754::Tools**, but
uses numerical methods rather than accessing the underlying bits.  It [has been
shown](http://perlmonks.org/?node_id=1167146) that its interpretation function can take
an order of magnitude longer than a routine that manipulates the underlying bits
to gather the information.

This **Data::IEEE754::Tools** module combines the two sets of functions, giving
access to the raw IEEE 754 encoding, or a stringification of the encoding which
interprets the encoding as a sign and a coefficient and a power of 2, or access to
the ULP and ULP-manipulating features, all using direct bit manipulation when
appropriate.

## Compatibility

**Data::IEEE754::Tools** works with 64bit floating-point representations.

If you have a Perl setup which uses a larger representation (for example,
`use [Config](https://metacpan.org/pod/Config); print $Config{nvsize}; # 16 => 128bit`), values reported by
this module will be reduced in precision to fit the 64bit representation.

If you have a Perl setup which uses a smaller representation (for example,
`use [Config](https://metacpan.org/pod/Config); print $Config{nvsize}; # 4 => 32bit`), the installation
will likely fail, because the unit tests were not set up for lower precision
inputs.  However, forcing the installation _might_ still allow coercion
from the smaller Perl NV into a true IEEE 754 double (64bit) floating-point,
but there is no guarantee it will work.

# INSTALLATION

To install this module, use your favorite CPAN client.

For a manual install, type the following:

    perl Makefile.PL
    make
    make test
    make install

(On Windows machines, you may need to use "dmake" or "gmake" instead of "make", depending on your setup.)

# AUTHOR

Peter C. Jones `<petercj AT cpan DOT org>`

Please report any bugs or feature requests emailing `<bug-Data-IEEE754-Tools AT rt.cpan.org>`
or thru the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-IEEE754-Tools](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Data-IEEE754-Tools),
or thru the repository's interface at [https://github.com/pryrt/Data-IEEE754-Tools/issues](https://github.com/pryrt/Data-IEEE754-Tools/issues).

<div>
    <a href="https://metacpan.org/pod/Data::IEEE754::Tools><img src="https://img.shields.io/cpan/v/Data-IEEE754-Tools.svg?colorB=00CC00" alt="" title="metacpan"></a>
    <a href="http://matrix.cpantesters.org/?dist=Data-IEEE754-Tools"><img src="http://cpants.cpanauthors.org/dist/Data-IEEE754-Tools.png" alt="" title="cpan testers"></a>
    <a href="https://github.com/pryrt/Data-IEEE754-Tools/releases"><img src="https://img.shields.io/github/release/pryrt/Data-IEEE754-Tools.svg" alt="" title="github release"></a>
    <a href="https://github.com/pryrt/Data-IEEE754-Tools/issues"><img src="https://img.shields.io/github/issues/pryrt/Data-IEEE754-Tools.svg" alt="" title="issues"></a>
    <a href="https://ci.appveyor.com/project/pryrt/data-ieee754-tools"><img src="https://ci.appveyor.com/api/projects/status/a9yylnhnufr2g9ug?svg=true" alt="" title="appveyor build status"></a>
    <a href="https://travis-ci.org/pryrt/Data-IEEE754-Tools"><img src="https://travis-ci.org/pryrt/Data-IEEE754-Tools.svg?branch=master" alt="" title="travis build status"></a>
    <a href="https://coveralls.io/github/pryrt/Data-IEEE754-Tools?branch=master"><img src="https://coveralls.io/repos/github/pryrt/Data-IEEE754-Tools/badge.svg?branch=master" alt="" title="coveralls test coverage"></a>
</div>

# COPYRIGHT

Copyright (C) 2016-2018 Peter C. Jones

# LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.
