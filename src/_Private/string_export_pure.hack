/** expr-dump is MIT licensed, see /LICENSE. */
namespace HTL\ExprDump\_Private;

use namespace HH\Lib\Str;

/**
 * @see https://github.com/hershel-theodore-layton/static-type-assertion-code-generator/blob/master/src/_Private/string_export.hack
 */
function string_export_pure(string $string)[]: string {
  return
    Str\replace_every($string, dict['\\' => '\\\\', "'" => "\'"]) |> "'".$$."'";
}
