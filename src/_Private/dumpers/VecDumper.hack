/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Str, Vec};

final class VecDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private WeakUntypedDumper $inner)[] {}

  public function dump(mixed $value)[]: string {
    $value as vec<_>;

    return Vec\map($value, $v ==> $this->inner->dump($v))
      |> Str\join($$, ", \n")
      |> 'vec['.$$.']';
  }
}
