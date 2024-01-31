/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\{Dict, Vec};
use namespace HTL\{ExprDump, TypeVisitor};

final class DumperVisitor
  implements TypeVisitor\TypeDeclVisitor<UntypedDumper, ShapeField> {

  const TypeVisitor\TAlias EMPTY_ALIAS = shape(
    'alias' => null,
    'counter' => -1,
    'opaque' => false,
  );

  const type TShapeKeyNamer = (function(?string, arraykey)[]: ?string);

  public function __construct(
    private dict<string, (function(mixed)[]: string)> $customDumpers,
    private ?UntypedDumper $dumperToUseForUntypedValues,
    private dict<string, ExprDump\EnumDefinition> $enumDefinitions,
    private this::TShapeKeyNamer $shapeKeyNamer,
  )[] {}

  public function panic(string $message)[]: nothing {
    throw new \UnexpectedValueException($message);
  }

  public function unsupportedType(string $type_name)[]: nothing {
    throw new \UnexpectedValueException('Unsupported type: '.$type_name);
  }

  public function shapeField(
    ?string $_parent_shape_name,
    arraykey $key,
    bool $_is_class_constant,
    bool $_is_optional,
    UntypedDumper $dumper,
  )[]: ShapeField {
    return shape(
      'runtime_value' => $key,
      'dumper' => WeakUntypedDumper::create($dumper),
    );
  }

  public function arraykey(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'arraykey') ??
      new ArraykeyDumper(
        $this->int(static::EMPTY_ALIAS),
        $this->string(static::EMPTY_ALIAS),
      );
  }

  public function bool(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'bool') ?? BoolDumper::instance();
  }

  public function class(
    TypeVisitor\TAlias $alias,
    string $classname,
    vec<UntypedDumper> $_generics,
  )[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, $classname);
  }

  public function dict(
    TypeVisitor\TAlias $alias,
    UntypedDumper $key_dumper,
    UntypedDumper $value_dumper,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'dict') ??
      new DictDumper(
        WeakUntypedDumper::create($key_dumper),
        WeakUntypedDumper::create($value_dumper),
      );
  }

  public function dynamic(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'dynamic') ??
      $this->dumperToUseForUntypedValues as nonnull;
  }

  public function enum(
    TypeVisitor\TAlias $alias,
    string $classname,
  )[]: UntypedDumper {
    $dumper = $this->customDumperOrNull($alias, $classname);

    if ($dumper is nonnull) {
      return $dumper;
    }

    $enum_definition = idx($this->enumDefinitions, $classname);

    if ($enum_definition is null) {
      throw new \UnexpectedValueException(
        'Missing enum definition for: '.$classname,
      );
    }

    return new EnumDumper($enum_definition);
  }

  public function float(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return
      $this->customDumperOrNull($alias, 'float') ?? FloatDumper::instance();
  }

  public function int(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'int') ?? IntDumper::instance();
  }

  public function interface(
    TypeVisitor\TAlias $alias,
    string $classname,
    vec<UntypedDumper> $_generics,
  )[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, $classname);
  }

  public function keyset(
    TypeVisitor\TAlias $alias,
    UntypedDumper $inner,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'keyset') ??
      new KeysetDumper(WeakUntypedDumper::create($inner));
  }

  public function mixed(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'mixed') ??
      $this->dumperToUseForUntypedValues ??
      new BestEffortDumper(
        $this->bool(static::EMPTY_ALIAS),
        $this->float(static::EMPTY_ALIAS),
        $this->int(static::EMPTY_ALIAS),
        $this->string(static::EMPTY_ALIAS),
        $this->null(static::EMPTY_ALIAS),
        $self ==> $this->dict(static::EMPTY_ALIAS, $self, $self),
        $self ==> $this->keyset(static::EMPTY_ALIAS, $self),
        $self ==> $this->vec(static::EMPTY_ALIAS, $self),
      );
  }

  public function nonnull(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'nonnull') ??
      $this->dumperToUseForUntypedValues as nonnull;
  }

  public function noreturn(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, 'noreturn');
  }

  public function nothing(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, 'nothing');
  }

  public function null(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'null') ?? NullDumper::instance();
  }

  public function nullable(
    TypeVisitor\TAlias $alias,
    UntypedDumper $inner,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'nullable') ??
      new NullableDumper(WeakUntypedDumper::create($inner));
  }

  public function num(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'num') ??
      new NumDumper(
        $this->float(static::EMPTY_ALIAS),
        $this->int(static::EMPTY_ALIAS),
      );
  }

  public function resource(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, 'resource');
  }

  public function shape(
    TypeVisitor\TAlias $alias,
    vec<ShapeField> $fields,
    bool $_is_open,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'shape') ??
      new ShapeDumper(
        $alias['alias'],
        $this->shapeKeyNamer,
        Dict\from_values($fields, $f ==> $f['runtime_value']),
        WeakUntypedDumper::create(
          $this->dumperToUseForUntypedValues as nonnull,
        ),
      );
  }

  public function string(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return
      $this->customDumperOrNull($alias, 'string') ?? StringDumper::instance();
  }

  public function trait(
    TypeVisitor\TAlias $alias,
    string $classname,
    vec<UntypedDumper> $_generics,
  )[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, $classname);
  }

  public function tuple(
    TypeVisitor\TAlias $alias,
    vec<UntypedDumper> $elements,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'tuple') ??
      new TupleDumper(Vec\map($elements, $e ==> WeakUntypedDumper::create($e)));
  }

  public function vec(
    TypeVisitor\TAlias $alias,
    UntypedDumper $inner,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'vec') ??
      new VecDumper(WeakUntypedDumper::create($inner));
  }

  public function vecOrDict(
    TypeVisitor\TAlias $alias,
    vec<UntypedDumper> $inner,
  )[]: UntypedDumper {
    return $this->customDumperOrNull($alias, 'vec_or_dict') ??
      new VecOrDictDumper(
        new VecDumper(WeakUntypedDumper::create($inner[0])),
        new DictDumper(
          WeakUntypedDumper::create($inner[0]),
          WeakUntypedDumper::create($inner[1]),
        ),
      );
  }

  public function void(TypeVisitor\TAlias $alias)[]: UntypedDumper {
    return $this->customDumperOrThrow($alias, 'void');
  }

  private function customDumperOrNull(
    TypeVisitor\TAlias $alias,
    string $type,
  )[]: ?UntypedDumper {
    $func = idx($this->customDumpers, $alias['alias']) ??
      idx($this->customDumpers, $type);

    if ($func is nonnull) {
      return new CustomDumper($func);
    }

    if ($alias['opaque']) {
      throw new \UnexpectedValueException(
        'Missing custom dumper for: '.$alias['alias'],
      );
    }

    return null;
  }

  private function customDumperOrThrow(
    TypeVisitor\TAlias $alias,
    string $type,
  )[]: UntypedDumper {
    $dumper = $this->customDumperOrNull($alias, $type);

    if ($dumper is nonnull) {
      return $dumper;
    }

    throw new \UnexpectedValueException('Unable to dump type: '.$type);
  }
}
