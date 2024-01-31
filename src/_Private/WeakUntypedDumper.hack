/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use type WeakRef;

final class WeakUntypedDumper {
  private function __construct(
    private ?WeakRef<UntypedDumper> $weakRef,
    private ?UntypedDumper $strongRef,
  )[] {
    invariant(
      $weakRef is nonnull || $strongRef is nonnull,
      'Must construct %s with either a weak or a strong ref.',
      static::class,
    );
  }

  public function dump(mixed $value)[]: string {
    return $this->get()->dump($value);
  }

  public static function create(UntypedDumper $dumper)[]: this {
    return $dumper->shouldFormAWeakReference()
      ? new static(new WeakRef($dumper), null)
      : new static(null, $dumper);
  }

  private function get()[]: UntypedDumper {
    $ref = $this->strongRef ?? $this->weakRef?->get();
    invariant(
      $ref is nonnull,
      'This %s should have still been alive. You may file a bug.',
      static::class,
    );
    return $ref;
  }
}
