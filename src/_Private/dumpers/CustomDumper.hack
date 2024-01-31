/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class CustomDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private (function(mixed)[]: string) $dumper)[] {}

  public function dump(mixed $value)[]: string {
    return ($this->dumper)($value);
  }
}
