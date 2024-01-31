/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class NullableDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(private WeakUntypedDumper $inner)[] {}

  public function dump(mixed $value)[]: string {
    return $value is null ? 'null' : $this->inner->dump($value);
  }
}
