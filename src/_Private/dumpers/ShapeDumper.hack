/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Str, Vec};

final class ShapeDumper implements UntypedDumper {
  use BecomeAStrongRef;

  public function __construct(
    private ?string $parentShapeName,
    private (function(?string, arraykey)[]: ?string) $shapeKeyNamer,
    private dict<arraykey, ShapeField> $fields,
    private WeakUntypedDumper $inner,
  )[] {}

  public function dump(mixed $value)[]: string {
    $create_key = (arraykey $k) ==> {
      $name = ($this->shapeKeyNamer)($this->parentShapeName, $k);

      if ($name is string || $k is string) {
        return $name ?? $this->inner->dump($k);
      }

      throw new \UnexpectedValueException(Str\format(
        'The key %d in shape() [%s] has type int '.
        'and the shape namer did not resolve to a class constant. '.
        'Raw integer field names are not allowed in Hack. '.
        'Please pass a shape namer to ExprDump\\create_dumper().',
        $k,
        $this->parentShapeName ?? '<unnamed-shape>',
      ));
    };

    $dump_value = ($k, $v) ==> idx(
      $this->fields,
      $k,
      shape('dumper' => $this->inner),
    )['dumper']->dump($v);

    $value as shape(...);

    return Vec\map_with_key(
      Shapes::toDict($value),
      ($k, $v) ==> $create_key($k).' => '.$dump_value($k, $v),
    )
      |> Str\join($$, ", \n")
      |> 'shape('.$$.')';
  }
}
