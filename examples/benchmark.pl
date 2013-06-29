use v5.14;
use Benchmark qw(cmpthese);
use B::Deparse;

sub dump_method {
	state $b = 'B::Deparse'->new;
	
	my ($class, $method) = @_;
	my $coderef = $class->can($method);
	
	printf("sub %s::%s %s\n", $class, $method, $b->coderef2text($coderef));
}

BEGIN {
	$ENV{METHOD_SIGNATURES_TYPES_FLAVOUR} = 'type_tiny';
}

package WithInlining {
	use Method::Signatures;
	method foo (Str $a, Num $b, ArrayRef $c) {
		return;
	}
}

BEGIN {
	*Type::Tiny::can_be_inlined = sub { 0 };
}

package WithoutInlining {
	use Method::Signatures;
	method foo (Str $a, Num $b, ArrayRef $c) {
		return;
	}
}

@::Input = (
	"Hello",
	3.14,
	[],
);

cmpthese(-1, {
	WithInlining    => q{ WithInlining->foo(@::Input) },
	WithoutInlining => q{ WithoutInlining->foo(@::Input) },
});
