/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use type HTL\ExprDump\EnumDefinition;

final class EnumDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private EnumDefinition $enumDefinition)[] {}

  public function dump(mixed $value)[]: string {
    return $this->enumDefinition->resolveRuntimeValue($value as arraykey);
  }
}
