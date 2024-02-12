/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

/**
 * `HH\Lib\Ref<T>` is not annotated with coeffects in hhvm 4.102.
 */
final class Ref<T> {
  public function __construct(public T $value)[] {}

  public function getValue()[]: T {
    return $this->value;
  }

  public function setValue(T $value)[write_props]: void {
    $this->value = $value;
  }
}
