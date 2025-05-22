/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\Project_GnDe82S9ecSl\GeneratedTestChain;

use namespace HH;
use namespace HH\Lib\{IO, Vec};
use namespace HTL\TestChain;

// The initial stub was generated with vendor/bin/test-chain.
// It is now yours to edit and customize.
<<__DynamicallyCallable, __EntryPoint>>
async function run_tests_async()[defaults]: Awaitable<void> {
  $_argv = HH\global_get('argv') as Container<_>
    |> Vec\map($$, $x ==> $x as string);
  $tests = await tests_async(
    TestChain\ChainController::create(TestChain\TestChain::create<>)
  );
  $result = await $tests
    ->withParallelGroupExecution()
    ->runAllAsync($tests->getBasicProgressReporter());

  $output = IO\request_output();
  if ($result->isSuccess()) {
    await $output->writeAllAsync("\nNo errors!\n");
    return;
  }

  await $output->writeAllAsync("\nTests failed!\n");
  exit(1);
}
