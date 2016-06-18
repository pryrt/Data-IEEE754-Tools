#!/bin/env perl
########################################################################
# Application Description
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-06-17 15:09:51 -0700 (Fri, 17 Jun 2016) $
#   $Revision: 169 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/t/debug.pl $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/t/debug.pl 169 2016-06-17 22:09:51Z pryrtmx $
#   $Id: debug.pl 169 2016-06-17 22:09:51Z pryrtmx $
########################################################################
use warnings;
use strict;
use lib '../';
require 'Expand.pm';

use version 0.77; our $VERSION = version->declare('v1.000.' . sprintf '%03d', (q$Revision: 169 $ =~ /(\d+)/) );   # PAUSE compatible SVN-based version-object; can have extra

local $\ = "\n";

print $\ x 50;

print "$0: $VERSION";
print "\$Data::IEEE754::Expand::VERSION = ", $Data::IEEE754::Expand::VERSION;

print Data::IEEE754::Expand::get_raw_ieee754_hexstr_from_double(-.16);
print Data::IEEE754::Expand::get_raw_ieee754_binstr_from_double(-.16);
print '';

print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/binary/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/binary fraction/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/decimal/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/decimal fraction/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/hexadecimal/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/hexadecimal reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/hexadecimal fraction/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(-1.5, qw/hexadecimal fraction reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(0.16, qw/binary/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(0.16, qw/decimal/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(0.16, qw/hexadecimal/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(128.375, qw/binary reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(128.375, qw/binary fraction reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(128.375, qw/decimal reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(128.375, qw/decimal fraction reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(128.375, qw/hex reduce/);
print '';
print Data::IEEE754::Expand::ieee754_double2xxx_workhorse(0, qw/hex reduce/);
print '';

foreach my $h ( qw/0000000000000001 8000000000000001 7FF0000000000000 FFF0000000000000 7FF0000000000001 FFF0000000000001 7FF8000000000001 FFF8000000000001/ ) {
    my $v = Data::IEEE754::Expand::get_double_from_ieee754_hexstr( $h );
    printf "$h \t $v \t %23.16g\n", $v;
    print Data::IEEE754::Expand::ieee754_double2xxx_workhorse($v, qw/bin reduce/);
    print '';
}
exit;

