package Lexical::select;

#ABSTRACT: provides a lexically scoped filehandle select function

use strict;
use warnings;
use Carp qw[croak];
use Symbol 'qualify_to_ref';

our @ISA    = qw[Exporter];
our @EXPORT = qw[lselect];

sub lselect {
  my $handle = qualify_to_ref(shift, caller);
  my $old_fh = CORE::select $handle;
  return bless { old_fh => $old_fh }, __PACKAGE__;
}

sub DESTROY {
  my $self = shift;
  select $self->{old_fh};
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

=head1 FUNCTIONS

=over

=item C<lselect>

=back

=cut
