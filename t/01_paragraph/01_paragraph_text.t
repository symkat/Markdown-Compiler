#!/usr/bin/env perl
use Markdown::Compiler::Test;

build_and_test( "Single string of text.",
    "Hello World", [
    [ result_is => "<p>Hello World</p>\n\n" ],
]);

build_and_test( "Single new-line is ignored.",
    "Hello World\nHello World", [
    [ result_is => "<p>Hello WorldHello World</p>\n\n" ],
]);

build_and_test( "Double Line break treated as new paragraph.",
    "Hello World\n\nHello World", [
    [ result_is => "<p>Hello World</p>\n\n<p>Hello World</p>\n\n" ],
]);

build_and_test( "Excess double-linebreaks are ignored",
    "Hello World\n\nHello World\n\n", [
    [ result_is => "<p>Hello World</p>\n\n<p>Hello World</p>\n\n" ],
]);

build_and_test( "Excess single-linebreaks are ignored",
    "Hello World\n\nNew World\n", [
    [ result_is => "<p>Hello World</p>\n\n<p>New World</p>\n\n" ],
]);

done_testing;
