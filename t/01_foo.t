#!/usr/bin/env perl
use Markdown::Compiler::Test;

my $test = <<EOF;
*Hello World!*


| Header | Header |
| Value  | Value |


| Header | Header |
| :---: | :---:     |
| Value  | Value  |

* Hello World!
- Another world?

EOF

$test = "Hello World!\n";

_test_dump_lexer( $test );
_test_dump_parser( $test );
_test_dump_html( $test );


done_testing;
