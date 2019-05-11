package Math::LOESS::Model;

use strict;
use warnings;

# VERSION

use Moo;

use Math::LOESS::_swig;

has _obj => (is => 'ro');

=head1 ATTRIBUTES

=head2 span

=head2 degree

=head2 normalize

=head2 family

=cut

for my $attr (qw(span degree normalize family)) {
    no strict 'refs';
    *{$attr} = sub {
        my ($self, $value) = @_;

        if (defined $value) {
            $self->_obj->{$attr} = $value;
        }
        return $self->_obj->{$attr};
    };
}

1;

__END__

