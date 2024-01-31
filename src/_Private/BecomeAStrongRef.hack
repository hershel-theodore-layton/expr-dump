/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

trait BecomeAStrongRef {
  public function shouldFormAWeakReference()[]: bool {
    return false;
  }
}
