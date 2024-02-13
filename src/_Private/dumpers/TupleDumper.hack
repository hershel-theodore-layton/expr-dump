/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{C, Str, Vec};

final class TupleDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private vec<WeakUntypedDumper> $elements)[] {}

  public function dump(mixed $value)[]: string {
    if (!\HH\is_vec_or_varray($value)) {
      // Fail with a TypeAssertionException:
      // expected AVecOrAVarrayDependingOnYourHHVMVersion; got ???.
      // Casting to any tuple type, f.e. `(int, int)` would be confusing.
      $value as AVecOrAVarrayDependingOnYourHHVMVersion;
      invariant_violation(
        'Typechecker thinks this cast might succeed. '.
        'There is no platform where it will, vec(object-type) is disallowed. '.
        'By placing this invariant_violation here I assure the typechecker.',
      );
    }

    $value = vec($value as Container<_>);

    $value_count = C\count($value);
    $element_count = C\count($this->elements);

    if ($value_count !== $element_count) {
      throw new \TypeAssertionException(
        'Expected tuple of length %d, got a vec<_> of length %d.',
      );
    }

    return Vec\zip($value, $this->elements)
      |> Vec\map($$, $t ==> $t[1]->dump($t[0]))
      |> Str\join($$, ', ')
      |> 'tuple('.$$.')';
  }
}
