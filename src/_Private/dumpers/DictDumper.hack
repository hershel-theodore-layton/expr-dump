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
    return Dict\map_with_key(
      $value as dict<_, _>,
      ($k, $v) ==>
        $this->keyDumper->dump($k).' => '.$this->valueDumper->dump($v),
    )
      |> Str\join($$, ', ')
      |> 'dict['.$$.']';
  }
}
