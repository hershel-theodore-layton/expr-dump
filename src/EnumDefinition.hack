/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump;

use namespace HH;
use namespace HH\Lib\Dict;

final class EnumDefinition {
  private function __construct(
    private string $classname,
    private dict<arraykey, string> $keys,
  )[] {}

  public static function create(HH\enumname<arraykey> $enum)[]: EnumDefinition {
    return new static($enum, $enum::getValues() |> Dict\flip($$));
  }

  public function getClassname()[]: string {
    return $this->classname;
  }

  public function resolveRuntimeValue(arraykey $value)[]: string {
    return '\\'.$this->classname.'::'.$this->keys[$value];
  }
}
