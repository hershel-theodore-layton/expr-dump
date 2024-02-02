# expr-dump

Dump runtime values to typed Hack source code.

## Why do you need this?

Run code during build-time, codegen the values you were interested in back to
Hack code, write it to a Hack source file, and you have build-time compute.

You have data you need in your program that will not change between releases.
All data that enters your program has the type `mixed`, therefore you must cast
it to a typed value in order to process it. If you do this safely, this incurs
runtime costs. Doing it using an unsafe mechanism, such as `HH\FIXME\UNSAFE_CAST`
or `HH_FIXME[4110]` is trading correctness for performance. But what if the
data was already part of your program, fully typed and ready to use?

```HACK
const TheTypeYouNeed THE_DATA_YOU_NEED = /* embed the data here */;
```

## Why the existing tools can not meet this need

In Hack, the same runtime value can represent two different types.

```HACK
shape('name' => 'value') === dict['name' => 'value']; // true
shape('name' => 'value') === shape(SomeClass::CLASS_CONSTANT => 'value'); // true
vec[1, 2, 3] === tuple(1, 2, 3); // true
6 === MyEnum::ENUMERATOR; // true
```

HHVM is unable to distinguish between these types, but Hack is, and will emit
errors if you initialize a value with the wrong type, even if the runtime value
would be exactly the same as the correct initializer.

`const (int, int) A_TUPLE = vec[1, 2]; // type error`

`ExprDump\dump<reify T>(T $value): string` takes a **type** _and a_ value.
This gives it enough information to represent shapes as shapes, tuples as tuples,
enums as enums, whilst not confusing them for dicts, vecs, and arraykeys.

## Usage

```HACK
// Like var_dump(), with Hack syntax, all type information is lost.
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
  $shape,
  shape(
    'shape_key_namer' => (
      ?string $_parent_shape_name,
      arraykey $key,
    )[] ==> {
      $prefix = '\\'.SomeClass::class.'::';
      return dict<arraykey, string>[
        SomeClass::CONSTANT => $prefix.'CONSTANT',
      ][$key] ?? $key;
    },
  ),
);

// Create a reusable dumper, call `->dump()`
$dumper = ExprDump\create_dumper<SomeType>(shape(
  // The options go here
));

$dumper->dump($value_of_that_given_type);
```

## Note about the stability of this api

This library depends on [HTL\TypeVisitor](https://github.com/herhsel-theodore-layton/type-visitor)
to provide its functionality. `TypeVisitor` depends on unstable Hack apis,
`TypeStructure<T>` and `\HH\ReifiedGenerics\get_type_structure<T>()`. For more
details, see [stability](https://github.com/herhsel-theodore-layton/type-visitor/README.md).
This api has been unstable since 2016, so take this with a grain of salt.

In order to minimize the potential impact of a removal of these apis, you should
not use this library in places where the performance of bootstrapping the dumper
is critical. A far less performant variant of `TypeVisitor` could be written, even
without these api affordances.
