#!/bin/env perl
########################################################################
# Verifies the following functions:
#   get_raw_ieee754_hexstr_from_double()
#   get_raw_ieee754_binstr_from_double()
#   get_double_from_ieee754_hexstr()
#   get_double_from_ieee754_binstr()
########################################################################
# Subversion Info
#   $Author: pryrtmx $
#   $Date: 2016-06-17 12:17:19 -0700 (Fri, 17 Jun 2016) $
#   $Revision: 168 $
#   $URL: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/t/rawstr.pl $
#   $Header: https://subversion.assembla.com/svn/pryrt/trunk/perl/Data-IEEE754-Expand/t/rawstr.pl 168 2016-06-17 19:17:19Z pryrtmx $
#   $Id: rawstr.pl 168 2016-06-17 19:17:19Z pryrtmx $
########################################################################
use warnings;
use strict;
use lib '../';
require 'Expand.pm';

use version 0.77; our $VERSION = version->declare('v1.000.' . sprintf '%03d', (q$Revision: 168 $ =~ /(\d+)/) );   # PAUSE compatible SVN-based version-object; can have extra

local $\ = "\n";

print $\ x 50;

print "$0: $VERSION";
print "\$Data::IEEE754::Expand::VERSION = ", $Data::IEEE754::Expand::VERSION;

my $v = -0.16;
print "rawhex754($v) =\t", Data::IEEE754::Expand::get_raw_ieee754_hexstr_from_double($v);
print "rawbin754($v) =\t", Data::IEEE754::Expand::get_raw_ieee754_binstr_from_double($v);
my $s = "BFC47AE147AE147B";
print "encode(0x$s) =\t", Data::IEEE754::Expand::get_double_from_ieee754_hexstr($s);
$s = "1011111111000100011110101110000101000111101011100001010001111011";
print "encode(0b$s) =\t", Data::IEEE754::Expand::get_double_from_ieee754_binstr($s);
print '';

$v = 1.0 + 1.0/16.0 + 5.0/256.0;
print "rawhex754($v) =\t", Data::IEEE754::Expand::get_raw_ieee754_hexstr_from_double($v);
print "rawbin754($v) =\t", Data::IEEE754::Expand::get_raw_ieee754_binstr_from_double($v);
$s = "3FF1500000000000";
print "encode(0x$s) =\t", Data::IEEE754::Expand::get_double_from_ieee754_hexstr($s);
$s = "0011111111110001010100000000000000000000000000000000000000000000";
print "encode(0b$s) =\t", Data::IEEE754::Expand::get_double_from_ieee754_binstr($s);
print '';
exit;

