/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump;

function dump<reify T>(T $value, DumpOptions $options = shape())[]: string {
  return create_dumper<T>($options)->dump($value);
}
