package Math::LOESS;

# ABSTRACT: Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

use 5.010;
use strict;
use warnings;

# VERSION

=head1 NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

=head1 SYNOPSIS

    use Math::LOESS;

    my $loess = Math::LOESS->new(x => $x_piddle, y => $y_piddle);

    $loess->fit();
    my $fitted_values = $loess->outputs->fitted_values;

=cut


use Moo;

use PDL::Core qw(ones);
use PDL::Lite;
use Math::LOESS::_swig;

use Math::LOESS::Outputs;
use Math::LOESS::Model;

has _obj => (
    is      => 'ro',
    builder => sub {
        my $loess = Math::LOESS::_swig::loess->new();
        for my $param (qw(inputs model control kd_tree outputs)) {
            my $class = "Math::LOESS::_swig::loess_${param}";
            $loess->{$param} = $class->new();
        }
        return $loess;
    },
);

=head1 ATTRIBUTES

=head2 model

=head2 outputs

=cut

has outputs => (
    is      => 'lazy',
    builder => sub {
        my ($self) = @_;
        return Math::LOESS::Outputs->new(
            n      => $self->_inputs_n,
            p      => $self->_inputs_p,
            _obj   => $self->_obj->{outputs},
            family => 'gaussian'
        );
    }
);

has model => (
    is      => 'lazy',
    builder => sub {
        my ($self) = @_;
        return Math::LOESS::Model->new( _obj => $self->_obj->{model} );
    }
);

sub BUILD {
    my ( $self, $args ) = @_;

    my ( $x, $y ) = map {
        my $p = delete $args->{$_};
        unless ( defined $p ) {
            die "$_ is required";
        }
        $p;
    } qw(x y);

    my $n = $y->dim(0);
    my $p = $x->dim(0) / $y->dim(0);
    unless ( int($p) == $p ) {
        die "x's length must be same as, or integral times as, that of y";
    }

    my $w = delete $args->{weights};
    if ( defined $w ) {
        unless ( $w->dim(0) == $n ) {
            die "weights's length must be same as that of y";
        }
    }
    else {
        $w = ones($n);
    }

    my ( $x1, $y1, $w1 ) =
      map { Math::LOESS::_swig::pdl_to_darray( $_, $_->dim(0) ); }
      ( $x, $y, $w );
    Math::LOESS::_swig::loess_setup( $x1, $y1, $w1, $n, $p, $self->_obj );
}

sub DEMOLISH {
    my ($self) = @_;
    Math::LOESS::_swig::loess_inputs_free( $self->_obj->{inputs} );

    #Math::LOESS::_swig::loess_free_mem( $self->_obj );
}

=head1 METHODS

=head2 x

=head2 y

=head2 weights

=cut

sub _inputs_n { $_[0]->_obj->{inputs}{n} }
sub _inputs_p { $_[0]->_obj->{inputs}{p} }

sub _size {
    my ( $self, $attr ) = @_;
    return $attr eq 'x'
      ? $self->_inputs_n * $self->_inputs_p
      : $self->_inputs_n;
}

for my $attr (qw(x y weights)) {
    no strict 'refs';
    *{$attr} = sub {
        my ($self) = @_;

        my $d = $self->_obj->{inputs}->{$attr};
        return Math::LOESS::_swig::darray_to_pdl( $d, $self->_size($attr) );
    };
}

sub _check_error {
    my ($self) = @_;

    my $status = $self->_obj->{status};
    if ( $status->{err_status} ) {
        die $status->{err_msg};
    }
}

sub fit {
    my ($self) = @_;

    Math::LOESS::_swig::loess_fit( $self->_obj );
    $self->_check_error;
    $self->outputs->activated(1);
    return;
}

1;

__END__

=head1 SEE ALSO

L<PDL>

