/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class IntDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    return (string)$value;
  }
}
