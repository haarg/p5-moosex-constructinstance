use strict;
use warnings;
use Test::More;

BEGIN {
	eval q{ require Moose; 1 } or plan skip_all => 'requires Moose';
}

{
	package Local::Other;
	use Moose;
	has param => (is => 'rw');
}

{
	package Local::Class1;
	use Moose;
	with qw( MooseX::ConstructInstance );
	has xxx => (is => 'ro');
	sub make_other {
		my $self = shift;
		$self->construct_instance('Local::Other', param => $self->xxx);
	}
}

{
	package Local::Class2;
	use Moose;
	extends qw( Local::Class1 );
	around make_other => sub {
		my ($orig, $self, $class, @args) = @_;
		my $inst = $self->$orig($class, @args);
		$inst->param(2) if $inst->DOES('Local::Other');
		return $inst;
	}
}

can_ok 'Local::Class1', 'construct_instance';
ok !Local::Class1->can('import');

{
	my $obj = Local::Class1->new(xxx => 3);
	my $oth = $obj->make_other;
	is($oth->param, 3);
}

{
	my $obj = Local::Class2->new(xxx => 3);
	my $oth = $obj->make_other;
	is($oth->param, 2);
}

done_testing;
