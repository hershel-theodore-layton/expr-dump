/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class StringDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    return string_export_pure($value as string);
  }
}
