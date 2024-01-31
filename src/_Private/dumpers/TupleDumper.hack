/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{C, Str, Vec};

final class TupleDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private vec<WeakUntypedDumper> $elements)[] {}

  public function dump(mixed $value)[]: string {
    $value as vec<_>;

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
