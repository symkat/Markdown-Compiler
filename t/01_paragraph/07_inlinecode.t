#!/usr/bin/env perl
use Markdown::Compiler::Test;

build_and_test( "Inline code in paragraphs works.",
    "This causes an error: `> hello`.", [
    [ result_is => "<p>This causes an error: <span class=\"inline-code\">> hello</span>.</p>\n\n" ],
]);



done_testing;

