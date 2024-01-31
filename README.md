# expr-dump

Dump runtime values to typed static initializers.

## var_dump() for the era of Hack

In Hack, the same runtime value can represent two separate types.

```HACK
final class X { const string CLASS_CONSTANT = 'name'; }
shape('name' => 'value') === dict['name' => 'value']; // true
shape('name' => 'value') === shape(X::CLASS_CONSTANT => 'value'); // true
vec[1, 2, 3] === tuple(1, 2, 3); // true
6 === MyEnum::ENUMERATOR; // true
```

This means that `\var_dump()` doesn't have enough information to accurately
represent the complete type of the expression. The syntax from \var_dump()
is also not something you can just embed into a Hack file.

`ExprDump\dump<reify T>(T $value): string` takes a **type** _and a_ value.
This gives it enough information to represent shapes as shapes, tuples as tuples,
enums as enums, whilst not confusing them for dicts, vecs, and arraykeys.

## Why do you need this?

If you have runtime data that is not going to change, you can embed it
into your Hack source code. This performs better than
`json_decode_with_error()`'ing it on every request and you can skip
asserting the type at runtime, or using type unsafe mechanisms.

## Usage

```HACK
// var_dump() with Hack syntax, all type information is lost.
//  - shapes become dicts
//  - tuples become vecs
//  - enums become ints / strings
ExprDump\dump<mixed>($x);

// There are multiple options that can be combined in any way.

// Encode Hack types and aliasses how you please.
// \App\user_id_from_int(4) types the value as an App\UserId.
ExprDump\dump<vec<shape('name' => string, 'friends' => vec<App\UserId>)>>(
  $users,
  shape(
    'custom_dumpers' => dict[
      App\UserId::class => (mixed $id)[] ==>
        '\App\user_id_from_int('.($id as int).')',
    ],
  ),
);

// Serialize enums as enumeration expression, such as Roles::ADMIN.
ExprDump\dump<vec<Roles>>(
  $roles,
  shape(
    'enum_definitions' => ExprDump\EnumDefinition::create(Roles::class),
  ),
);

// Keep class constant names in the dumped output.
// shape(\SomeClass::CONSTANT => 1) instead of shape('val' => 1)
ExprDump\dump<shape(SomeClass::CONSTANT => int)>(
  shape(SomeClass::CONSTANT => 1),
  shape(
    'shape_key_namer' => (
      ?string $_parent_shape_name,
      arraykey $key,
    )[] ==> {
      $prefix = '\\'.SomeClass::class.'::';
      return dict<arraykey, string>[
        SomeClass::CONSTANT => $prefix.'CONSTANT',
      ][$key];
    },
  ),
);

// Create a reusable dumper, call `->dump()`
$dumper = ExprDump\create_dumper<SomeType>(shape(
  // The options go here
));

$dumper->dump($value_of_that_given_type);
```
