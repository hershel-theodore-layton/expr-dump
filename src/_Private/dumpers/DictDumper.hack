/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Dict, Str};

final class DictDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(
    private WeakUntypedDumper $keyDumper,
    private WeakUntypedDumper $valueDumper,
  )[] {}

  public function dump(mixed $value)[]: string {
    if (!\HH\is_dict_or_darray($value)) {
      // Fail with a TypeAssertionException:
      // expected dict<_, _> got ??? on all supported platforms.
      $value as dict<_, _>;
    }

    return Dict\map_with_key(
      dict($value as KeyedContainer<_, _>),
      ($k, $v) ==>
        $this->keyDumper->dump($k).' => '.$this->valueDumper->dump($v),
    )
      |> Str\join($$, ", \n")
      |> 'dict['.$$.']';
  }
}
