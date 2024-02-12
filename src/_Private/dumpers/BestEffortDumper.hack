/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

final class BestEffortDumper implements UntypedDumper {
  // These fields are nullable, since they require `$this` to be constructed.
  // Now that they are nullable, `$this` is considered to be fully constructed,
  // before assigning them to `$this->dictDumper` etc.
  // They will become nonnull after the constructor finishes.
  // If they were notnullable, `$dict_factory($this)` would not typecheck.
  // The initialization is not over because $this->dictDumper,
  // can still potentially be null. Hack(3004)
  private ?UntypedDumper $dictDumper;
  private ?UntypedDumper $keysetDumper;
  private ?UntypedDumper $vecDumper;

  public function __construct(
    private UntypedDumper $boolDumper,
    private UntypedDumper $floatDumper,
    private UntypedDumper $intDumper,
    private UntypedDumper $stringDumper,
    private UntypedDumper $nullDumper,
    (function(UntypedDumper)[]: UntypedDumper) $dict_factory,
    (function(UntypedDumper)[]: UntypedDumper) $keyset_factory,
    (function(UntypedDumper)[]: UntypedDumper) $vec_factory,
  )[] {
    $this->dictDumper = $dict_factory($this);
    $this->keysetDumper = $keyset_factory($this);
    $this->vecDumper = $vec_factory($this);
  }

  public function dump(mixed $value)[]: string {
    if ($value is bool) {
      return $this->boolDumper->dump($value);
    } else if ($value is float) {
      return $this->floatDumper->dump($value);
    } else if ($value is int) {
      return $this->intDumper->dump($value);
    } else if ($value is string) {
      return $this->stringDumper->dump($value);
    } else if ($value is null) {
      return $this->nullDumper->dump($value);
    } else if ($value is dict<_, _>) {
      return $this->dictDumper as nonnull->dump($value);
    } else if ($value is keyset<_>) {
      return $this->keysetDumper as nonnull->dump($value);
    } else if ($value is vec<_>) {
      return $this->vecDumper as nonnull->dump($value);
    }

    throw new \UnexpectedValueException(
      'Unable to dump type without specific instructions: '.
      (\is_object($value) ? \get_class($value) : \gettype($value)),
    );
  }

  public function shouldFormAWeakReference()[]: bool {
    return true;
  }
}
