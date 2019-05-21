package Math::LOESS;

# ABSTRACT: Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

use 5.010;
use strict;
use warnings;

# VERSION

use PDL::Core qw(ones);
use PDL::Lite;
use Math::LOESS::_swig;
use Type::Params qw(compile compile_named);
use Types::Standard qw(Any Num Object Optional Str);
use Types::PDL qw(Piddle1D);

use Math::LOESS::Model;
use Math::LOESS::Outputs;
use Math::LOESS::Prediction;

sub new {
    my $class = shift;
    state $check = compile_named(
        x       => Piddle1D,
        y       => Piddle1D,
        weights => Optional [Piddle1D],
        span    => Optional [ Num->where( sub { $_ > 0 and $_ < 1 } ) ],
        family  => Optional [ Str ],
    );

    my $arg = $check->(@_);

    my ( $x, $y, $span, $family ) = map { $arg->{$_} } qw(x y span family);
    my $n = $y->dim(0);
    my $p = $x->dim(0) / $y->dim(0);
    unless ( int($p) == $p ) {
        die "x's length must be same as, or integral times as, that of y";
    }

    my $w = $arg->{weights};
    if ( defined $w ) {
        unless ( $w->dim(0) == $n ) {
            die "weights's length must be same as that of y";
        }
    }
    else {
        $w = ones($n);
    }

    my $x1 = Math::LOESS::_swig::pdl_to_darray( $x, $n * $p );
    my $y1 = Math::LOESS::_swig::pdl_to_darray( $y, $n );
    my $w1 = defined $w ? Math::LOESS::_swig::pdl_to_darray( $w, $n ) : undef;

    my $loess = Math::LOESS::_swig::loess->new();
    for my $param (qw(inputs model control kd_tree outputs)) {
        my $class = "Math::LOESS::_swig::loess_${param}";
        $loess->{$param} = $class->new();
    }
    
    my $self = bless(
        {
            %$arg,
            _obj      => $loess,
            activated => 0
        },
        $class
    );

    Math::LOESS::_swig::loess_setup( $x1, $y1, $w1, $n, $p, $self->_obj );

    # free memory
    map { Math::LOESS::_swig::delete_doubleArray($_) }
      ( $x1, $y1, defined $w1 ? $w1 : () );

    $self->{model} = Math::LOESS::Model->new( _obj => $self->_obj->{model} );
    if ( defined $span ) {
        $self->model->span($span);
    }
    if ( defined $family ) {
        $self->model->family($family);
    }

    $self->{outputs} = Math::LOESS::Outputs->new(
        _obj   => $self->_obj->{outputs},
        _loess => $self,
        n      => $self->_inputs_n,
        p      => $self->_inputs_p,
        family => $self->model->family,
    );

    return $self;
}

sub DESTROY {
    my ($self) = @_;
    Math::LOESS::_swig::loess_free_mem( $self->_obj );
}

for my $attr (qw(_obj activated model outputs)) {
    no strict 'refs';
    *{$attr} = sub { $_[0]->{$attr} };
}

sub _inputs   { $_[0]->_obj->{inputs} }
sub _inputs_n { $_[0]->_inputs->{n} }
sub _inputs_p { $_[0]->_inputs->{p} }

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
    $self->{activated} = 1;
    return;
}

sub predict {
    state $check = compile( Any, Piddle1D, Optional [Any] );
    my ($self, $newdata, $stderr) = $check->(@_);

    unless ($self->activated) {
        $self->fit();
    }

    my $pred = Math::LOESS::_swig::prediction->new();
    $pred->{m} = $newdata->dim(0);
    $pred->{se} = $stderr ? 1 : 0; 

    my $d = Math::LOESS::_swig::pdl_to_darray($newdata);
    Math::LOESS::_swig::predict( $d, $self->_obj, $pred );
    $self->_check_error;

    Math::LOESS::_swig::delete_doubleArray($d);

    return Math::LOESS::Prediction->new( _obj => $pred );
}

sub summary {
    my ($self) = @_;

    my $fit_flag = $self->activated;
    my $s = sprintf(
        <<"EOT",
Number of Observations         : %d
Fit flag                       : %d
Equivalent Number of Parameters: %.1f
EOT
        $self->_inputs->{n}, $fit_flag, $self->outputs->enp
    );

    if ($fit_flag) {
        my $rse_fmt =
          $self->model->family eq 'gaussian'
          ? "Residual Standard Error        : %.4f"
          : "Residual Scale Estimate        : %.4f";
        $s .= sprintf( $rse_fmt, $self->outputs->residual_scale ) . "\n";
    }
    return $s;
}

1;

__END__

=head1 NAME

Math::LOESS - Perl wrapper of the Locally-Weighted Regression package originally written by Cleveland, et al.

=head1 SYNOPSIS

    use Math::LOESS;

    my $loess = Math::LOESS->new(x => $x, y => $y);

    $loess->fit();
    my $fitted_values = $loess->outputs->fitted_values;

    print $loess->summary();

    my $prediction = $loess->predict($new_data, 1);
    my $confidence_intervals = $prediction->confidence(0.05);
    print $confidence_internals->{fit};
    print $confidence_internals->{upper};
    print $confidence_internals->{lower};

=head1 CONSTRUCTION

    new(Piddle1D :$x, Piddle1D :$y, Piddle1D :$weights=undef,
        Num :$span=0.75, Str :$family='gaussian')

Arguments:

=over 4

=item * $x

A L<PDL> piddle for x data. 

=item * $y

A L<PDL> piddle for y data. 

=item * $weights

Optional weights.

=item * $span

=include span@Math::LOESS::Model

When provided as a construction parameter, it is like a shortcut for,

    $loess->model->span($span);

=item * $family

=include family@Math::LOESS::Model

When provided as a construction parameter, it is like a shortcut for,

    $loess->model->family($family);

=back

=head1 ATTRIBUTES

=head2 model

Get an L<Math::LOESS::Model> object.

=head2 outputs

Get an L<Math::LOESS::Outputs> object.

=head2 x

Get input x data as a piddle.

=head2 y

Get input y data as a piddle.

=head2 weights

Get input weights data as a piddle.

=head2 activated

Returns a true value if the object's C<fit()> method has been called.

=head1 METHODS

=head2 fit

    fit()

=head2 predict

    predict(Piddle1D $newdata, Bool $stderr=false)

Returns a L<Math::LOESS::Prediction> object.

=head2 summary

    summary()

Returns a summary string.

=head1 SEE ALSO

L<https://en.wikipedia.org/wiki/Local_regression>

L<PDL>

