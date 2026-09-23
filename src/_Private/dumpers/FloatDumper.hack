/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\Str;
use function is_nan;
use const INF;

final class FloatDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    $value as float;

    if (is_nan($value)) {
      return '\NAN';
    }

    if ($value === INF) {
      return '\INF';
    }

    if ($value === -INF) {
      return '-\INF';
    }

    if ($value === -0.0) {
      // https://github.com/facebook/hhvm/issues/7426
      return Str\format_number($value, 0) === '-0' ? '(-1.0 * 0.0)' : '0.0';
    }

    $literal = (string)$value;
    if ((float)$literal !== $value) {
      $literal = Str\format('%.16E', $value) |> Str\strip_suffix($$, 'E+0');
    }

    // An integral float must not turn into an int when the source is parsed.
    return Str\contains($literal, '.') || Str\contains($literal, 'E')
      ? $literal
      : $literal.'.0';
  }
}
