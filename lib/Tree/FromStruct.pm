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
     $self->{_children} = [@_] if $@;
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


=head1 FUNCTIONS

=head2 build_tree_from_struct($struct) => obj

Construct a tree object from a data structure C<$struct>. Structure must be a
hash. There must be a special key named C<_class> to set which node class to
use. There can also be some other special keys: C<_children> (an array of
structure to build children), C<_constructor> (string, constructor name if not
C<new>). The other keys will be fed to the node constructor.

Class must at least provide the C<parent> and C<children> attribute methods to
get and set the parent and children (you can also consume the
L<Role::TinyCommons::Tree::Node> to enforce this).

Example:

 my $family_tree = build_tree_from_struct({
     _class => 'My::Person', name => 'Andi', age => 60, _children => [
         {name => 'Budi', age => 30},
         {_class => 'My::MarriedPerson', name => 'Cinta', _children => [
              {class => 'My::KidPerson', name => 'Deni'},
              {class => 'My::KidPerson', name => 'Eno'},
          ]},
     ]});

Here's how the function builds the tree. function will first construct the first
(root) node with:

 my $root = My::Person->new(name => 'Andi', age => 60);

then it will set the children:

 my $child1 = My::Person->new(name => 'Budi', age => 30);
 $child1->parent($root);
 my $child2 = My::MarriedPerson->new(name => 'Cinta');
 $child1->parent($root);

and connect them to the root:

 $root->children($child1, $child2);

It then proceeds to the next level:

 my $grandchidl1 = My::KidPerson->new(name => 'Deni');
 $grandchild1->parent($child2);
 my $grandchidl2 = My::KidPerson->new(name => 'Eno');
 $grandchild2->parent($child2);

and connect the nodes to their parent:

 $child2->children($grandchild1, $grandchild2);

Finally it will return the root node C<$root>.


=head1 SEE ALSO

L<Role::TinyCommons::Tree::FromStruct> if you want to use this functionality via
consuming a role.
