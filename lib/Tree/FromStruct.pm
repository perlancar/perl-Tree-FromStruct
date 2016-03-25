package Tree::FromStruct;

# DATE
# VERSION

require Code::Includable::Tree::FromStruct;

use Exporter qw(import);
our @EXPORT_OK = qw(build_tree_from_struct);

sub build_tree_from_struct {
    my $struct = shift;

    my $class = $struct->{_class} or die "Please specify _class in struct";
    Code::Includable::Tree::FromStruct::new_from_struct($class, $struct);
}

1;
# ABSTRACT: Build a tree object from hash structure

=head1 SYNOPSIS

In your tree node class F<My/Person.pm>:

 package My::Person;

 sub new {
     my $class = shift;
     my %args = @_;
     bless \%args, $class;
 }

 sub parent {
     my $self = shift;
     $self->{_parent} = $_[0] if $@;
     $self->{_parent};
 }

 sub children {
     my $self = shift;
     $self->{_children} = $_[0] if $@;
     $self->{_children};
 }

In your code to build a tree:

 use Tree::FromStruct qw(build_tree_from_struct);

 # require all the used classes
 use My::Person;
 use My::MarriedPerson;
 use My::KidPerson;

 my $family_tree = build_tree_from_struct({
     _class => 'My::Person', name => 'Andi', age => 60, _children => [
         {name => 'Budi', age => 30},
         {_class => 'My::MarriedPerson', name => 'Cinta', _children => [
              {class => 'My::KidPerson', name => 'Deni'},
              {class => 'My::KidPerson', name => 'Eno'},
          ]},
     ]});


=head1 DESCRIPTION

Building a tree manually can be tedious: you have to connect the parent and
the children nodes together:

 my $root = My::Class->new(...);
 my $child1 = My::Class->new(...);
 my $child2 = My::Class->new(...);

 $root->children($child1, $child2);
 $child1->parent($root);
 $child2->parent($root);

 my $grandchild1 = My::Class->new(...);
 ...

This module provides a convenience function to build a tree of objects in a
single command. It connect the parent and children nodes for you.

The class can be any class that provides C<parent> and C<children> methods. See
L<Role::TinyCommons::Tree::Node> for more details.


=head1 FUNCTIONS

=head2 build_tree_from_struct($struct) => obj

This is basically L<Role::TinyCommons::Tree::FromStruct>'s C<new_from_struct>
presented as a function. See the role's documentation for more details on what
you can put in C<$struct>.


=head1 SEE ALSO

L<Role::TinyCommons::Tree::FromStruct> if you want to use this functionality via
consuming a role.
