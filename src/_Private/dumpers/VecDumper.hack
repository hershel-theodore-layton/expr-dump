/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Str, Vec};

final class VecDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private WeakUntypedDumper $inner)[] {}

  public function dump(mixed $value)[]: string {
    return Vec\map($value as vec<_>, $v ==> $this->inner->dump($v))
      |> Str\join($$, ', ')
      |> 'vec['.$$.']';
  }
}
