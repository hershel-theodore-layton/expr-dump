/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\Tests;

use namespace HH\Lib\Str;
use namespace HTL\{ExprDump, TestChain};
use namespace HTL\ExprDump\_Private;
use function HTL\Expect\{expect, expect_invoked};

<<TestChain\Discover>>
function dump_test(TestChain\Chain $chain)[]: TestChain\Chain {
  $options = shape(
    'custom_dumpers' => dict[
      'bool' => ($v)[] ==> 'intercepted('.($v as bool ? 'true' : 'false').')',
      (string)MyOpaqueInt::class => ($v)[] ==> 'opaque_int('.$v as int.')',
    ],
    'enum_definitions' => vec[ExprDump\EnumDefinition::create(MyEnum::class)],
    'shape_key_namer' => ($parent, $key)[] ==> {
      $const = '\\'.(string)MyClass::class.'::';

      if ($parent === MyShape::class) {
        return dict<arraykey, string>[
          MyClass::SOME_CONSTANT => $const.'SOME_CONSTANT',
          MyClass::SOME_OTHER_CONSTANT => $const.'SOME_OTHER_CONSTANT',
        ][$key];
      }

      return null;
    },
  );

  return $chain->group(__FUNCTION__)
    ->testWith3Params(
      'test_the_cases',
      () ==>
        vec[
          // Simple, but with bool intercepted via the custom_dumpers.
          create_test_case<vec<mixed>>(
            $options,
            vec[1, 2.2, '3', false, null],
            "vec[1, 2.2, '3', intercepted(false), null]",
          ),

          // Everybody loves the special float values...
          create_test_case<vec<float>>(
            $options,
            vec[\INF, -\INF, \NAN],
            'vec[\INF, -\INF, \NAN]',
          ),

          // In case of duplicate enum values, the last enumerator is chosen.
          create_test_case<keyset<MyEnum>>(
            $options,
            keyset[MyEnum::ONE_INT, MyEnum::ONE_STR],
            'keyset['.
            '\HTL\ExprDump\Tests\MyEnum::ANOTHER_ONE_INT, '.
            '\HTL\ExprDump\Tests\MyEnum::ONE_STR'.
            ']',
          ),

          // You are able to intercept your type aliasses.
          create_test_case<dict<int, MyOpaqueInt>>(
            $options,
            dict[1 => opaque_int(1)],
            'dict[1 => opaque_int(1)]',
          ),

          // If type information is not provided, for example
          // in the `...` of a shape, the dumper for untyped values is used.
          create_test_case<MyShape>(
            $options,
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
          create_test_case<shape(
            'required' => int,
            ?'optional' => int,
            'nullable' => ?int,
            ?'illusive' => ?int,
            /*_*/
          )>(
            $options,
            shape('required' => 1, 'nullable' => null, 'illusive' => 3),
            "shape('required' => 1, 'nullable' => null, 'illusive' => 3)",
          ),

          // The dumper for untyped values only knows about the runtime value,
          // so it can't distinguish between shape <-> dict / tuple <-> vec.
          create_test_case<shape(...)>(
            $options,
            shape('pos' => shape('x' => 1, 'y' => 2)),
            "shape('pos' => dict['x' => 1, 'y' => 2])",
          ),

          create_test_case<(int, int)>($options, tuple(1, 1), 'tuple(1, 1)'),

          // Tuples are not just vecs...
          create_test_case<(?int, ?string, arraykey, num, null)>(
            $options,
            tuple(1, null, 'example', 4.2, null),
            "tuple(1, null, 'example', 4.2, null)",
          ),

          // vec_or_dict picks either vec or dict, depending on the runtime value.
          create_test_case<vec<vec_or_dict<int, string>>>(
            $options,
            vec[dict[1 => '3'], vec['6']],
            "vec[dict[1 => '3'], vec['6']]",
          ),

          // Putting it all together, mostly checking for recursively correct stuff.
          create_test_case<shape(
            'dict' => dict<MyEnum, MyOpaqueInt>,
            'keyset' => keyset<MyEnum>,
            'vec' => vec<MyOpaqueInt>,
            'tuple' => (mixed, MyOpaqueInt),
            'nesting_galore' =>
              (shape('deeper' => vec<dict<string, (keyset<MyEnum>)>>/*_*/)),
            /*_*/
          )>(
            $options,
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
        ],
      ($value, $dumper, $expected) ==> {
        $dumper as _Private\TypedDumperShell<_>;
        expect(
          $dumper->dumpUntypedForUnitTest__DO_NOT_USE($value)
            |> Str\replace($$, "\n", ''),
        )->toEqual($expected);
      },
    )
    ->test('test_enum_not_provided', () ==> {
      expect_invoked(() ==> ExprDump\create_dumper<MyEnum>(shape()))
        ->toHaveThrown<\UnexpectedValueException>(
          'Missing enum definition for: HTL\\ExprDump\\Tests\\MyEnum',
        );
    })
    ->test('test_newtype_not_provided', () ==> {
      expect_invoked(() ==> ExprDump\create_dumper<MyOpaqueInt>(shape()))
        ->toHaveThrown<\UnexpectedValueException>(
          'Missing custom dumper for: HTL\\ExprDump\\Tests\\MyOpaqueInt',
        );
    })
    ->test('test_class_constant_with_int_value_must_be_named', () ==> {
      expect_invoked(
        () ==> ExprDump\dump<shape(...)>(shape(MyClass::SOME_CONSTANT => 3)),
      )
        ->toHaveThrown<\UnexpectedValueException>(
          'The key 1 in shape() [<unnamed-shape>] has type int '.
          'and the shape namer did not resolve to a class constant.',
        );

      expect_invoked(
        () ==> ExprDump\dump<OpenShape>(shape(MyClass::SOME_CONSTANT => 3)),
      )
        ->toHaveThrown<\UnexpectedValueException>(
          'The key 1 in shape() [HTL\\ExprDump\\Tests\\OpenShape] has type int '.
          'and the shape namer did not resolve to a class constant.',
        );
    })
    ->test('test_class_constant_with_string_value_decays_silently', () ==> {
      expect(ExprDump\dump<shape(...)>(shape(MyClass::SOME_STRING_CONSTANT => 3)))
        ->toEqual("shape('str' => 3)");
    })
    ->test('test_undumpable_values_throw_an_exception', () ==> {
      expect_invoked(() ==> ExprDump\dump<vec<mixed>>(vec[new \stdClass()]))
        ->toHaveThrown<\UnexpectedValueException>(
          'Unable to dump type without specific instructions: stdClass',
        );
    })
    ->testWith3Params(
      'test_circular_references_are_made_harmless_with_a_weakref',
      () ==> vec[
        create_test_case<dict<int, dynamic>>(
          $options,
          dict[1 => 2 as dynamic],
          'dict[1 => 2]',
        ),
        create_test_case<vec<mixed>>($options, vec[1], 'vec[1]'),
        create_test_case<shape(...)>(
          $options,
          shape('a' => 1),
          "shape('a' => 1)",
        ),
        create_test_case<(?nonnull)>($options, tuple(6), 'tuple(6)'),
      ],
      ($value, $dumper, $expected)[write_props] ==> {
        $dumper as _Private\TypedDumperShell<_>;
        expect($dumper->dumpUntypedForUnitTest__DO_NOT_USE($value))->toEqual($expected);

        // This method is not available on the TypedDumper interface.
        // When you release the TypedDumper, the whole thing is cleaned up.
        // In order to demonstrate this, I'll drop the reference to the keep-alive.
        // The WeakUntypedDumper can now be cleaned up, since it looks like the
        // TypedDumper has gone out of scope.
        // If I now call `->dump()` again, the WeakUntypedDumper throws, noting that
        // it expected to the WeakRef to still be alive for as long as it is reachable.
        // This should never happen, expect for when you mess in the internals.
        $dumper->dropTheReferenceToTheDumperForUntypedValues__DO_NOT_USE();
        expect_invoked(
          () ==> $dumper->dumpUntypedForUnitTest__DO_NOT_USE($value),
        )->toHaveThrown<InvariantException>(
          'This HTL\\ExprDump\\_Private\\WeakUntypedDumper should have still been alive.',
        );
      },
    );
}

function create_test_case<reify T>(
  ExprDump\DumpOptions $options,
  T $expression,
  string $expected,
)[]: (T, ExprDump\Dumper<T>, string) {
  return tuple($expression, ExprDump\create_dumper<T>($options), $expected);
}
