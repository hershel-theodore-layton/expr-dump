/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\Tests;

newtype MyOpaqueInt = int;

function opaque_int(int $int)[]: MyOpaqueInt {
  return $int;
}
