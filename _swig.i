%module "Math::LOESS::_swig"

%{
#include "loess.h"
%}

%include typemaps.i
%include "loess.h"

%include "carrays.i"
%array_functions(double, doubleArray);

%perlcode %{

package Math::LOESS::_swig;

use strict;

use PDL::Core qw(pdl);

sub darray_to_pdl {
    my ($a, $n) = @_;

    my @array = map { doubleArray_getitem($a, $_); } (0 .. $n - 1); 
    return pdl(\@array);
}

sub pdl_to_darray {
    my ($p) = @_;

    my $n = $p->dim(0);
    my @array = $p->list;
    my $a = new_doubleArray($n);
    for my $i (0 .. $n - 1) {
        doubleArray_setitem($a, $i, $array[$i]);
    }
    return $a;
}

%}
