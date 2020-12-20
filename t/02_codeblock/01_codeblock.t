#!/usr/bin/env perl
use Markdown::Compiler::Test;

build_and_test( "Single string of text.",
    "```\nHello World\n```", [
    [ result_is => "<pre>\nHello World\n</pre>\n\n" ],
]);

build_and_test( "Hash symbols are hash symbols, not headers in code blocks.",
    "```\n# Hello World\n```", [
    [ result_is => "<pre>\n# Hello World\n</pre>\n\n" ],
]);


done_testing;

