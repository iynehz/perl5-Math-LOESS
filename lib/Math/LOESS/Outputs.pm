package Math::LOESS::Outputs;

use strict;
use warnings;

# VERSION

use Moo;

use Math::LOESS::_swig;

has [qw(n p)] => ( is => 'ro', required => 1 );
has family    => ( is => 'ro', required => 1 );
has _obj      => ( is => 'ro', required => 1 );
has activated => ( is => 'rw', default  => 0 );

sub DEMOLISH {
    my ($self) = @_;
    Math::LOESS::_swig::loess_outputs_free( $self->_obj );
}

for my $attr (
    qw(
    fitted_values fitted_residuals diagnal robust
    divisor
    )
  )
{
    no strict 'refs';
    *{$attr} = sub {
        my ($self) = @_;
        return Math::LOESS::_swig::darray_to_pdl( $self->_obj->{$attr},
            $self->n );
    };
}

sub pseudovalues {
    my ($self) = @_;
    if ( $self->family ne 'symmetric' ) {
        die "pseudovalues are available only when robust fitting. "
          . "Use family='symmetric' for robust fitting";
    }
    return Math::LOESS::_swig::darray_to_pdl( $self->_obj->{pseudovalues},
        $self->n );
}

for my $attr (
    qw(
    enp residual_scale one_delta two_delta trace_hat
    )
  )
{
    no strict 'refs';
    *{$attr} = sub {
        my ($self) = @_;
        return $self->_obj->{$attr};
    };
}

1;

__END__

=head1 DESCRIPTION

You normally don't need to construct object of this class yourself.
Instead you get the object from an L<Math::LOESS> object after its C<fit()>
method is called. 

=head1 ATTRIBUTES

=head2 n

=head2 p

=head2 family

=head2 activated

A true value indicates data in the object is valid.

=head2 fitted_values

Fitted values.

=head2 fitted_residuals

Fitted residuals.

=head2 pseudovalues

Adjusted values of the response when robust estimation is used.

=head2 diagnal

Diagonal of the operator hat matrix.

=head2 robust

Robustness weights for robust fitting.

=head2 divisor

Normalization divisors for numeric predictors.

=head2 enp

Equivalent number of parameters.

=head2 residual_scale

Estimate of the scale of residuals.

=head2 one_delta

Statistical parameter used in the computation of standard errors.

=head2 two_delta

Statistical parameter used in the computation of standard errors.

=head2 trace_hat

Trace of the operator hat matrix.

=head1 SEE ALSO

L<Math::LOESS>

