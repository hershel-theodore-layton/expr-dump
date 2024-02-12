/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump;

use type HH\Lib\Ref;
use namespace HH\Lib\Dict;
use namespace HTL\TypeVisitor;

function create_dumper<reify T>(DumpOptions $options)[]: Dumper<T> {
  $dumper_to_use_for_untyped_values = TypeVisitor\visit<mixed, _, _>(
    new _Private\DumperVisitor(
      $options['custom_dumpers'] ?? dict[],
      null,
      dict[],
      ($_, $_) ==> null,
    ),
  );

  return TypeVisitor\visit<T, _, _>(new _Private\DumperVisitor(
    $options['custom_dumpers'] ?? dict[],
    $dumper_to_use_for_untyped_values,
    Dict\from_values(
      $options['enum_definitions'] ?? vec[],
      $ed ==> $ed->getClassname(),
    ),
    $options['shape_key_namer'] ?? ($_, $_) ==> null,
  ))
    |> new _Private\TypedDumperShell(
      $$,
      new Ref($dumper_to_use_for_untyped_values),
    );
}
