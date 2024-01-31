/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Str, Vec};

final class KeysetDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private WeakUntypedDumper $inner)[] {}

  public function dump(mixed $value)[]: string {
    return Vec\map($value as keyset<_>, $v ==> $this->inner->dump($v))
      |> Str\join($$, ', ')
      |> 'keyset['.$$.']';
  }
}
