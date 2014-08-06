package Lexical::select;

#ABSTRACT: provides a lexically scoped currently selected filehandle

use strict;
use warnings;
use Symbol 'qualify_to_ref';

our @ISA    = qw[Exporter];
our @EXPORT = qw[lselect];

sub lselect {
  my $handle = qualify_to_ref(shift, caller);
  my $old_fh = CORE::select $handle;
  return bless { old_fh => $old_fh }, __PACKAGE__;
}

sub restore {
  my $self = shift;
  return if $self->{_restored};
  CORE::select delete $self->{old_fh};
  return $self->{_restored} = 1;
}

sub DESTROY {
  my $self = shift;
  $self->restore unless $self->{_restored};
}

q[select $old_fh];

=pod

=head1 SYNOPSIS

  use Lexical::select;

  open my $fh, '>', 'fubar' or die "Oh noes!\n";

  {
    my $lxs = lselect $fh;

    print "Something wicked goes to \$fh \n";

  }

  print "Back on STDOUT\n";

=head1 DESCRIPTION

Changing the currently selected filehandle with C<select> and changing it back to the previously selected filehandle
can be slightly tedious. Wouldn't it be great to have something handle this boilerplate, especially in lexical scopes.

This is where Lexical::select comes in.

Lexical::select provides the C<lselect> function. As demonstrated in the C<SYNOPSIS>, C<lselect> will change the currently
selected filehandle to the filehandle of your choice for the duration of the enclosing lexical scope.

=head1 FUNCTIONS

Functions exported by default.

=over

=item C<lselect>

Takes one parameter, a C<filehandle> that will become the currently selected filehandle for the duration of the enclosing scope.

Returns an object, which provides the C<restore> method.

You can then either C<restore> the currently selected filehandle back manually or let the object fall out of
scope, which automagically restores.

=back

=head1 METHODS

=over

=item C<restore>

Explicitly restores the currently selected filehandle back to the original filehandle. This is called automagically
when the object is C<DESTROY>ed, for instance when the object goes out of scope.

=back

=head1 SEE ALSO

L<SelectSaver>

=cut
