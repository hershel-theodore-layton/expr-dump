/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HTL\ExprDump;

final class TypedDumperShell<T> implements ExprDump\Dumper<T> {
  /**
   * @param $keepMeAlive see `UntypedDumper::shouldFormAWeakReference()`
   */
  public function __construct(
    private UntypedDumper $inner,
    private Ref<UntypedDumper> $keepMeAlive,
  )[] {}

  public function dump(T $value)[]: string {
    return $this->inner->dump($value);
  }

  public function dumpUntypedForUnitTest__DO_NOT_USE(mixed $value)[]: string {
    return $this->inner->dump($value);
  }

  public function dropTheReferenceToTheDumperForUntypedValues__DO_NOT_USE(
  )[write_props]: void {
    $this->keepMeAlive = new Ref($this->inner);
  }
}
