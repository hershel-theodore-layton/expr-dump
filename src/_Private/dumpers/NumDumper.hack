/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class NumDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(
    private UntypedDumper $floatDumper,
    private UntypedDumper $intDumper,
  )[] {}

  public function dump(mixed $value)[]: string {
    return $value is int
      ? $this->intDumper->dump($value)
      : $this->floatDumper->dump($value);
  }
}
