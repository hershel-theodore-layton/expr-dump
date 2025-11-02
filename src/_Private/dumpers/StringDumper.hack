/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use function var_export_pure;

final class StringDumper implements UntypedDumper {
  use BecomeAStrongRef, SingletonDumper;

  public function dump(mixed $value)[]: string {
    return var_export_pure($value as string) as string;
  }
}
