%module "Math::LOESS::_swig"

%{
#include "loess.h"
%}

%include typemaps.i
%typemap(in) int [ANY] {
    SV *input = (SV*)$input;
    AV *tempav;
    int i;
    if (!(SvROK(input) && SvTYPE(SvRV(input)) == SVt_PVAV)) {
        croak("Argument $argnum is not an array ref.");
    }
    tempav = (AV*)SvRV(input);
    $1 = (int *) malloc($1_dim0 * sizeof(int));
    for (i = 0; i < $1_dim0; i++) {
        SV **elem_p = av_fetch(tempav, i, 0);
        if (elem_p) {
            $1[i] = (int) SvIV(*elem_p);
        } else {
            $1[i] = 0;
        }
    }
}
%typemap(freearg) int [ANY] {
    free($1);
}
%typemap(memberin) int [ANY] {
    int i;
    for (i = 0; i < $1_dim0; i++) {
        $1[i] = $input[i];
    }
}
%typemap(out) int [ANY] {
    AV* av = newAV();
    int i = 0;
    for (i = 0; i < $1_dim0 ; i++) {
        SV* perlval = newSV(0);
        sv_setiv(perlval, (IV)$1[i]);
        av_push(av, perlval);
    }
    $result = newRV_noinc((SV*) av );
    sv_2mortal( $result );
    argvi++;
}
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
