/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\Project_GnDe82S9ecSl\GeneratedTestChain;

use namespace HTL\TestChain;

async function tests_async<T as TestChain\Chain>(
  TestChain\ChainController<T> $controller
)[defaults]: Awaitable<TestChain\ChainController<T>> {
  return $controller
    ->addTestGroup(\HTL\ExprDump\Tests\dump_test<>);
}
