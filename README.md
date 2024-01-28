# expr-dump

Dump runtime values to typed static initializers.

## var_dump() for the era of Hack

In Hack, the same runtime value can represent two separate types.

```HACK
final class X { const string CLASS_CONSTANT = 'name'; }
shape('name' => 'value') === dict['name' => 'value']; // true
shape('name' => 'value') === shape(X::CLASS_CONSTANT => 'value'); // true
```

This means that `\var_dump()` doesn't have enough information to accurately
represent the complete type of the expression.

`ExprDump\dump<reify T>(T $value): string` takes a **type** _and a_ value.
This gives it enough information to represent shapes as shapes, tuples as tuples,
whilst not confusing them for dicts and vecs.

// TODO: Design an API that understands class constant keys for shapes.

## Why do you need this?

If you have runtime data that is not going to change, and this value can be
represented as a static initializer, you can write it to a constant.
This performs better than `json_decode_with_error()`'ing it on every request.
Plus, you can skip the effort of asserting the runtime type.
