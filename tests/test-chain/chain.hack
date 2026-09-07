/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\Project_GnDe82S9ecSl\GeneratedTestChain;

use namespace HTL\TestChain;
use type HTL\Pragma\Pragmas;

<<file: Pragmas(vec['PhaLinters', 'digest:888b0ac51855bca11a04'])>>

async function tests_async(
  TestChain\ChainController<\HTL\TestChain\Chain> $controller,
)[defaults]: Awaitable<TestChain\ChainController<\HTL\TestChain\Chain>> {
  return $controller
    ->addTestGroup(\HTL\ExprDump\Tests\dump_test<>);
}
