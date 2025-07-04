/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Str, Vec};
use namespace HTL\HH4Shim;

final class VecDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private WeakUntypedDumper $inner)[] {}

  public function dump(mixed $value)[]: string {
    if (!HH4Shim\is_vecish($value)) {
      // Fail with a TypeAssertionException:
      // expected vec<_> got ??? on all supported platforms.
      $value as vec<_>;
    }

    return Vec\map(vec($value as Container<_>), $v ==> $this->inner->dump($v))
      |> Str\join($$, ", \n")
      |> 'vec['.$$.']';
  }
}
