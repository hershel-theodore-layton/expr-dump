/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class VecOrDictDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(
    private UntypedDumper $vecDumper,
    private UntypedDumper $dictDumper,
  )[] {}

  public function dump(mixed $value)[]: string {
    return $value is vec<_>
      ? $this->vecDumper->dump($value)
      : $this->dictDumper->dump($value);
  }
}
