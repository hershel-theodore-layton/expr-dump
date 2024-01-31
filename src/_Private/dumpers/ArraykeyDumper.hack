/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class ArraykeyDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(
    private UntypedDumper $intDumper,
    private UntypedDumper $stringDumper,
  )[] {}

  public function dump(mixed $value)[]: string {
    return $value is int
      ? $this->intDumper->dump($value)
      : $this->stringDumper->dump($value);
  }
}
