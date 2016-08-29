use ExtUtils::MakeMaker;
use 5.006;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
%mm_args = (
    'NAME'          => 'Data::IEEE754::Tools',
    'AUTHOR'        => 'Peter C. jones <petercj AT cpan.org>',
    'VERSION_FROM'  => 'Tools.pm',
    'ABSTRACT_FROM' => 'Tools.pm',
    'PREREQ_PM'     => {
        'Exporter'      => 0,
        'version'       => 0.77,
        'warnings'      => 0,
        'strict'        => 0,
        'Carp'          => 0,
    },
);

{
    no warnings;
    if( $ExtUtils::MakeMaker::VERSION >= '6.46' ) {
        $mm_args{META_MERGE} = {
            resources => {
                bugtracker => {
                    mailto => 'bug-Data-IEEE754-Tools@rt.cpan.org',
                    web => 'http://rt.cpan.org/Public/Dist/Display.html?Name=Data-IEEE754-Tools',
                }
                repository => 'https://github.com/pryrt/Data-IEEE754-Tools',
            },
            keywords => [ 'IEEE-754', 'floating point representation'],
            provides => {
                'Data::IEEE754::Tools' => {
                    file => 'Tools.pm',
                }
            }
        },
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.31' ) {
        $mm_args{LICENSE} = 'perl_5';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.48' ) {
        $mm_args{MIN_PERL_VERSION} = '5.6.0';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.52' ) {
        $mm_args{CONFIGURE_REQUIRES} = {
            'ExtUtils::MakeMaker' => 0,
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        },
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.64' ) {
        $mm_args{TEST_REQUIRES} = {
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        };
    }
}

WriteMakefile( %mm_args )
