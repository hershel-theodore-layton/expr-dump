/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump;

interface Dumper<-T> {
  public function dump(T $value)[]: string;
}
