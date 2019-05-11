package Math::LOESS::Outputs;

use strict;
use warnings;

# VERSION

use Moo;

use Math::LOESS::_swig;

=head1 ATTRIBUTES

=head2 n

=head2 p

=head2 family

=head2 activated

=head2 _obj

=cut

has [qw(n p)] => ( is => 'ro', required => 1 );
has family    => ( is => 'ro', required => 1 );
has _obj      => ( is => 'ro', required => 1 );
has activated => ( is => 'rw', default  => 0 );

sub DEMOLISH {
    my ($self) = @_;
    Math::LOESS::_swig::loess_outputs_free( $self->_obj );
}

=head1 METHODS

=head2 fitted_values

=head2 fitted_residuals

=head2 diagnal

=head2 robust

=head2 divisor

=cut

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

for my $attr (
    qw(
    residual_scale one_delta two_delta trace_hat
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

