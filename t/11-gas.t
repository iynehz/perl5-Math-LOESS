#!perl

use strict;
use warnings;

use PDL::Core qw(pdl);

use Test2::V0;
use Test2::Tools::PDL;

use Math::LOESS;

$Test2::Tools::PDL::TOLERANCE_REL = 1e-4;

my $NOx = pdl(
    4.818, 2.849, 3.275, 4.691, 4.255, 5.064, 2.118, 4.602,
    2.286, 0.97,  3.965, 5.344, 3.834, 1.99,  5.199, 5.283,
    3.752, 0.537, 1.64,  5.055, 4.937, 1.561
);
my $E = pdl(
    0.831, 1.045, 1.021, 0.97,  0.825, 0.891, 0.71,  0.801,
    1.074, 1.148, 1,     0.928, 0.767, 0.701, 0.807, 0.902,
    0.997, 1.224, 1.089, 0.973, 0.98,  0.665
);

my $gas = pdl(
    4.883437, 2.927639, 3.572746, 4.710510, 4.815363, 5.196193,
    2.512832, 4.474939, 2.149797, 0.990044, 4.089353, 5.303627,
    3.864174, 2.267121, 4.575636, 5.240293, 4.154036, 0.523682,
    1.853026, 4.659184, 4.521148, 1.196414
);

my $gas_null = pdl(
    4.892690, 3.362733, 3.728575, 4.489023, 4.831715, 5.177112,
    2.535887, 4.530370, 2.873000, 1.453502, 4.059136, 5.052650,
    3.943568, 2.265232, 4.614320, 5.163913, 4.107184, -0.276342,
    2.604373, 4.445040, 4.351615, 1.051719
);

subtest gas => sub {
    my $loess = Math::LOESS->new( x => $E, y => $NOx );
    ok( $loess, 'Math::LOESS->new()' );

    cmp_ok( $loess->model->span, '==', 0.75, 'default model->span' );

    $loess->model->span( 2 / 3 );
    cmp_ok( $loess->model->span, '==', 2 / 3, 'model->span' );

    $loess->fit();
    pdl_is( $loess->outputs->fitted_values, $gas, 'outputs->fitted_values' );
};

subtest gas_null => sub {
    my $loess = Math::LOESS->new( x => $E, y => $NOx );
    ok( $loess, 'Math::LOESS->new()' );

    $loess->model->span(1.0);
    cmp_ok( $loess->model->span, '==', 1.0, 'model->span' );

    $loess->fit();
    pdl_is( $loess->outputs->fitted_values,
        $gas_null, 'outputs->fitted_values' );
};

done_testing;
