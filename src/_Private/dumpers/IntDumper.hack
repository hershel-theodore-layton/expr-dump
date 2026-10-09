/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\Math;

final class IntDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    // The positive decimal token in INT64_MIN's value would overflow.
    return $value === Math\INT64_MIN ? '(-1 << 63)' : (string)$value;
  }
}
