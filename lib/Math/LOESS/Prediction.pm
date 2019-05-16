package Math::LOESS::Prediction;

use 5.014;
use warnings;

# VERSION

use Moo;

use Math::LOESS::_swig;

has _obj => (is => 'ro');

sub DEMOLISH {
    my ($self) = @_;
    Math::LOESS::_swig::pred_free_mem( $self->_obj );
}

sub values {
    my ($self) = @_;
    return Math::LOESS::_swig::darray_to_pdl( $self->_obj->{fit},
        $self->_obj->{m} );
}

sub stderr {
    my ($self) = @_;
    unless ( $self->_obj->{se} ) {
        die "Standard error was not computed. "
          . "Use stderr => 1 when predicting";
    }
    return Math::LOESS::_swig::darray_to_pdl( $self->_obj->{se_fit},
        $self->_obj->{m} );
}

for my $attr (qw(residual_scale df)) {
    no strict 'refs';
    *{$attr} = sub {
        my ($self) = @_;
        return $self->_obj->{$attr};
    };
}

sub confidence {
    my ($self, $alpha) = @_;
    $alpha //= 0.01;

    unless ($alpha > 0 and $alpha < 1) {
        die "The alpha value should be between 0 and 1";
    }
    unless ($self->_obj->{se}) {
        die "Cannot compute confidence intervals without standard errors";
    }

    my $ci = Math::LOESS::_swig::confidence_intervals->new;
    Math::LOESS::_swig::pointwise($self->_obj, 1 - $alpha, $ci);   
    my $m = $self->_obj->{m};
    my $rslt =
      { map { $_ => Math::LOESS::_swig::darray_to_pdl( $ci->{$_}, $m ) }
          qw(fit upper lower) };
    Math::LOESS::_swig::pw_free_mem($ci);
    return $rslt;
}

1;

__END__

=head1 DESCRIPTION

You normally don't need to construct object of this class yourself.
Instead you get the object from an L<Math::LOESS> object after its C<fit()>
method is called. 

=head1 ATTRIBUTES

=head2 values

loess values evaluated at newdata.

=head2 stderr

Estimates of the standard error on the estimated values.

=head2 residual_scale

Estimate of the scale of the residuals.

=head2 df

Degrees of freedom of the loess fit.

It is used with the t-distribution to compute pointwise confidence
intervals for the evaluated surface. It is obtained using the formula
C<(one_delta ** 2) / two_delta>

=head1 METHODS

=head2 confidence

    confidence($alpha=0.01)

Returns the confidence intervals for predicted values, as a hashref of
C<{ fit =E<gt> $fit, upper =E<gt> $upper, lower =E<gt> $lower }>,
where C<$fit>, C<$upper>, C<$lower> are piddles of same length as the
C<values> attr.

=head1 SEE ALSO

L<Math::LOESS>

