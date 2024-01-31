/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

interface UntypedDumper {
  public function dump(mixed $value)[]: string;

  /**
   * This is needed because of a circular reference in the array dumpers.
   * If their value type is `mixed`, they will have a BestEffortDumper.
   * This BestEffortDumper holds a reference to the array dumper.
   * This would cause circular garbage. All types that return `true`
   * can safely be embedded in the array dumpers.
   *
   * If I hand a WeakRef<UntypedDumper> to the array dumpers, they could
   * deref an empty WeakRef, since they could be the only reference to it.
   * The solution is to only hand out `Dumper<T>` instances,
   * (using the TypedDumperShell) that hold a strong reference to it.
   * As soon as the shell is dropped, the refcount drops to zero.
   */
  public function shouldFormAWeakReference()[]: bool;
}
