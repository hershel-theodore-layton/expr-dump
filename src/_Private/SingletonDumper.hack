/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

<<__ConsistentConstruct>>
trait SingletonDumper {
  require implements UntypedDumper;

  final protected function __construct()[] {}

  <<__Memoize>>
  public static function instance()[]: UntypedDumper {
    return new static();
  }
}
