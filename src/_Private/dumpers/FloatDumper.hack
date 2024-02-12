/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\Math;

final class FloatDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    $value as float;

    if (\is_nan($value)) {
      return '\NAN';
    }

    if ($value === \INF) {
      return '\INF';
    }

    if ($value === -\INF) {
      return '-\INF';
    }

    return (string)$value;
  }
}
