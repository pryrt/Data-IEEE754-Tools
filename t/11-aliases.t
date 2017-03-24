########################################################################
# Verifies aliased functions
#   This checks to make sure that the alias points to the same
#   CODEREF as the original.  This should guarantee that if an alias
#   is invoked, it will call the same underlying code as if the
#   original routine were invoked
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:all/;

# :raw754
is( \&hexstr754_from_double                     , \&binary64_convertToInternalHexString         , 'alias:hexstr754_from_double              ');
is( \&hexstr754_to_double                       , \&binary64_convertFromInternalHexString       , 'alias:hexstr754_to_double                ');
is( \&binstr754_from_double                     , \&binary64_convertToInternalBinaryString      , 'alias:binstr754_from_double              ');
is( \&binstr754_to_double                       , \&binary64_convertFromInternalBinaryString    , 'alias:binstr754_to_double                ');

# :internalString
is( \&convertToInternalHexString                , \&binary64_convertToInternalHexString         , 'alias:convertToInternalHexString         ');
is( \&convertFromInternalHexString              , \&binary64_convertFromInternalHexString       , 'alias:convertFromInternalHexString       ');
is( \&convertToInternalBinaryString             , \&binary64_convertToInternalBinaryString      , 'alias:convertToInternalBinaryString      ');
is( \&convertFromInternalBinaryString           , \&binary64_convertFromInternalBinaryString    , 'alias:convertFromInternalBinaryString    ');

# :floatingpoint & :convertToCharacter
is( \&to_hex_floatingpoint                      , \&convertToHexCharacter                       , 'alias:to_hex_floatingpoint               ');
is( \&to_dec_floatingpoint                      , \&convertToDecimalCharacter                   , 'alias:to_dec_floatingpoint               ');
is( \&convertToHexCharacter                     , \&binary64_convertToHexCharacter              , 'alias:convertToHexCharacter              ');
is( \&convertToDecimalCharacter                 , \&binary64_convertToDecimalCharacter          , 'alias:convertToDecimalCharacter          ');

done_testing;exit;

plan tests    => 555;


exit;
