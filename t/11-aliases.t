########################################################################
# Verifies aliased functions
########################################################################
use 5.006;
use warnings;
use strict;
use Test::More;
use Data::IEEE754::Tools qw/:all/;

# :raw754
is( \&hexstr754_from_double                     , \&binary64_convertToInternalHexString         , 'alias:hexstr754_from_double' );
is( \&hexstr754_to_double                       , \&binary64_convertFromInternalHexString       , 'alias:hexstr754_to_double'   );
is( \&binstr754_from_double                     , \&binary64_convertToInternalBinaryString      , 'alias:binstr754_from_double' );
is( \&binstr754_to_double                       , \&binary64_convertFromInternalBinaryString    , 'alias:binstr754_to_double'   );

# :internalstring
is( \&convertToInternalHexString                , \&binary64_convertToInternalHexString         , 'alias:convertToInternalHexString' );
is( \&convertFromInternalHexString              , \&binary64_convertFromInternalHexString       , 'alias:convertFromInternalHexString'   );
is( \&convertToInternalBinaryString             , \&binary64_convertToInternalBinaryString      , 'alias:convertToInternalBinaryString' );
is( \&convertFromInternalBinaryString           , \&binary64_convertFromInternalBinaryString    , 'alias:convertFromInternalBinaryString'   );

done_testing;exit;

plan tests    => 555;


exit;
