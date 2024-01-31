/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class NullDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $_)[]: string {
    return 'null';
  }
}
