/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump;

type DumpOptions = shape(
  ?'custom_dumpers' => dict<string, (function(mixed)[]: string)>,
  ?'enum_definitions' => vec<EnumDefinition>,
  ?'shape_key_namer' => _Private\DumperVisitor::TShapeKeyNamer,
  /*_*/
);
