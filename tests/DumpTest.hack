/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\Tests;

use namespace HTL\ExprDump;
use namespace HTL\ExprDump\_Private;
use type Facebook\HackTest\{DataProvider, HackTest};
use function Facebook\FBExpect\expect;

final class DumpTest extends HackTest {
  private static ?ExprDump\DumpOptions $options;

  <<__Override>>
  public static async function beforeFirstTestAsync(): Awaitable<void> {
    static::$options = shape(
      'custom_dumpers' => dict[
        'bool' => ($v)[] ==> 'intercepted('.($v as bool ? 'true' : 'false').')',
        MyOpaqueInt::class => ($v)[] ==> 'opaque_int('.$v as int.')',
      ],
      'enum_definitions' => vec[ExprDump\EnumDefinition::create(MyEnum::class)],
      'shape_key_namer' => ($parent, $key)[] ==> {
        $const = '\\'.MyClass::class.'::';

        if ($parent === MyShape::class) {
          return dict<arraykey, string>[
            MyClass::SOME_CONSTANT => $const.'SOME_CONSTANT',
            MyClass::SOME_OTHER_CONSTANT => $const.'SOME_OTHER_CONSTANT',
          ][$key];
        }

        return null;
      },
    );
  }

  public function provideTestCases(
  ): vec<(mixed, ExprDump\Dumper<nothing>, string)> {
    return vec[
      // Simple, but with bool intercepted via the custom_dumpers.
      static::createTestCase<vec<mixed>>(
        vec[1, 2.2, '3', false, null],
        "vec[1, 2.2, '3', intercepted(false), null]",
      ),

      // Everybody loves the special float values...
      static::createTestCase<vec<float>>(
        vec[\INF, -\INF, \NAN],
        'vec[\INF, -\INF, \NAN]',
      ),

      // In case of duplicate enum values, the last enumerator is chosen.
      static::createTestCase<keyset<MyEnum>>(
        keyset[MyEnum::ONE_INT, MyEnum::ONE_STR],
        'keyset['.
        '\HTL\ExprDump\Tests\MyEnum::ANOTHER_ONE_INT, '.
        '\HTL\ExprDump\Tests\MyEnum::ONE_STR'.
        ']',
      ),

      // You are able to intercept your type aliasses.
      static::createTestCase<dict<int, MyOpaqueInt>>(
        dict[1 => opaque_int(1)],
        'dict[1 => opaque_int(1)]',
      ),

      // If type information is not provided, for example
      // in the `...` of a shape, the dumper for untyped values is used.
      static::createTestCase<MyShape>(
        shape(
          MyClass::SOME_CONSTANT => MyEnum::ANOTHER_ONE_INT,
          MyClass::SOME_OTHER_CONSTANT => MyEnum::ONE_INT,
        ),
        'shape('.
        '\HTL\ExprDump\Tests\MyClass::SOME_CONSTANT => \HTL\ExprDump\Tests\MyEnum::ANOTHER_ONE_INT, '.
        '\HTL\ExprDump\Tests\MyClass::SOME_OTHER_CONSTANT => 1'.
        ')',
      ),

      // All the flavors of shape optionality.
      static::createTestCase<shape(
        'required' => int,
        ?'optional' => int,
        'nullable' => ?int,
        ?'illusive' => ?int,
      )>(
        shape('required' => 1, 'nullable' => null, 'illusive' => 3),
        "shape('required' => 1, 'nullable' => null, 'illusive' => 3)",
      ),

      // The dumper for untyped values only knows about the runtime value,
      // so it can't distinguish between shape <-> dict / tuple <-> vec.
      static::createTestCase<shape(...)>(
        shape('pos' => shape('x' => 1, 'y' => 2)),
        "shape('pos' => dict['x' => 1, 'y' => 2])",
      ),

      // Tuples are not just vecs...
      static::createTestCase<(?int, ?string, arraykey, num, null)>(
        tuple(1, null, 'example', 4.2, null),
        "tuple(1, null, 'example', 4.2, null)",
      ),

      // vec_or_dict picks either vec or dict, depending on the runtime value.
      static::createTestCase<vec<vec_or_dict<int, string>>>(
        vec[dict[1 => '3'], vec['6']],
        "vec[dict[1 => '3'], vec['6']]",
      ),

      // Putting it all together, mostly checking for recursively correct stuff.
      static::createTestCase<shape(
        'dict' => dict<MyEnum, MyOpaqueInt>,
        'keyset' => keyset<MyEnum>,
        'vec' => vec<MyOpaqueInt>,
        'tuple' => (mixed, MyOpaqueInt),
        'nesting_galore' =>
          (shape('deeper' => vec<dict<string, (keyset<MyEnum>)>>)),
      )>(
        shape(
          'dict' => dict[MyEnum::ONE_STR => opaque_int(5)],
          'keyset' => keyset[MyEnum::ONE_STR],
          'vec' => vec[opaque_int(5)],
          'tuple' => tuple(2.2, opaque_int(3)),
          'nesting_galore' => tuple(
            shape(
              'deeper' => vec[dict['and' => tuple(keyset[MyEnum::ONE_STR])]],
            ),
          ),
        ),
        'shape('.
        "'dict' => dict[\HTL\ExprDump\Tests\MyEnum::ONE_STR => opaque_int(5)], ".
        "'keyset' => keyset[\HTL\ExprDump\Tests\MyEnum::ONE_STR], ".
        "'vec' => vec[opaque_int(5)], ".
        "'tuple' => tuple(2.2, opaque_int(3)), ".
        "'nesting_galore' => tuple(shape('deeper' => vec[dict['and' => tuple(keyset[\HTL\ExprDump\Tests\MyEnum::ONE_STR])]]))".
        ')',
      ),
    ];
  }

  <<DataProvider('provideTestCases')>>
  public function test_the_cases<T>(
    T $value,
    ExprDump\Dumper<T> $dumper,
    string $expected,
  ): void {
    expect($dumper->dump($value))->toEqual($expected);
  }

  public function test_enum_not_provided(): void {
    expect(() ==> ExprDump\create_dumper<MyEnum>(shape()))->toThrow(
      \UnexpectedValueException::class,
      'Missing enum definition for: HTL\\ExprDump\\Tests\\MyEnum',
    );
  }

  public function test_newtype_not_provided(): void {
    expect(() ==> ExprDump\create_dumper<MyOpaqueInt>(shape()))->toThrow(
      \UnexpectedValueException::class,
      'Missing custom dumper for: HTL\\ExprDump\\Tests\\MyOpaqueInt',
    );
  }

  public function test_class_constant_with_int_value_must_be_named(): void {
    expect(() ==> ExprDump\dump<shape(...)>(shape(MyClass::SOME_CONSTANT => 3)))
      ->toThrow(
        \UnexpectedValueException::class,
        'The key 1 in shape() [<unnamed-shape>] has type int '.
        'and the shape namer did not resolve to a class constant.',
      );

    expect(() ==> ExprDump\dump<OpenShape>(shape(MyClass::SOME_CONSTANT => 3)))
      ->toThrow(
        \UnexpectedValueException::class,
        'The key 1 in shape() [HTL\\ExprDump\\Tests\\OpenShape] has type int '.
        'and the shape namer did not resolve to a class constant.',
      );
  }

  public function test_class_constant_with_string_value_decays_silently(
  ): void {
    expect(ExprDump\dump<shape(...)>(shape(MyClass::SOME_STRING_CONSTANT => 3)))
      ->toEqual('shape(\'str\' => 3)');
  }

  public function test_undumpable_values_throw_an_exception(): void {
    expect(() ==> ExprDump\dump<vec<mixed>>(vec[new \stdClass()]))
      ->toThrow(
        \UnexpectedValueException::class,
        'Unable to dump type without specific instructions: stdClass',
      );
  }

  public function provideDumpersThatRequireKeepAlive(
  ): vec<(mixed, ExprDump\Dumper<nothing>, string)> {
    return vec[
      static::createTestCase<dict<int, dynamic>>(dict[1 => 2 as dynamic], 'dict[1 => 2]'),
      static::createTestCase<vec<mixed>>(vec[1], 'vec[1]'),
      static::createTestCase<shape(...)>(shape('a' => 1), "shape('a' => 1)"),
      static::createTestCase<(?nonnull)>(tuple(6), 'tuple(6)'),
    ];
  }

  <<DataProvider('provideDumpersThatRequireKeepAlive')>>
  public function test_circular_references_are_made_harmless_with_a_weakref<T>(
    T $value,
    ExprDump\Dumper<T> $dumper,
    string $expected,
  ): void {
    expect($dumper->dump($value))->toEqual($expected);

    // This method is not available on the TypedDumper interface.
    $dumper as _Private\TypedDumperShell<_>;
    // When you release the TypedDumper, the whole thing is cleaned up.
    // In order to demonstrate this, I'll drop the reference to the keep-alive.
    // The WeakUntypedDumper can now be cleaned up, since it looks like the
    // TypedDumper has gone out of scope.
    // If I now call `->dump()` again, the WeakUntypedDumper throws, noting that
    // it expected to the WeakRef to still be alive for as long as it is reachable.
    // This should never happen, expect for when you mess in the internals.
    $dumper->dropTheReferenceToTheDumperForUntypedValues__DO_NOT_USE();
    expect(() ==> $dumper->dump($value))->toThrow(
      InvariantException::class,
      'This HTL\\ExprDump\\_Private\\WeakUntypedDumper should have still been alive.',
    );
  }

  private static function createTestCase<reify T>(
    T $expression,
    string $expected,
  ): (T, ExprDump\Dumper<T>, string) {
    return tuple(
      $expression,
      ExprDump\create_dumper<T>(static::$options as nonnull),
      $expected,
    );
  }
}
