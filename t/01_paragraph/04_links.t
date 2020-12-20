#!/usr/bin/env perl
use Markdown::Compiler::Test;

build_and_test( "Autolinking HTTP Addresses", 
    "That one http://google.com/", [
    [ result_is => "<p>That one <a href=\"http://google.com/\">http://google.com/</a></p>\n\n" ],
]);

build_and_test( "Autolinking HTTP Addresses inside italics", 
    "That one _ http://google.com/ _", [
    [ result_is => "<p>That one <em> <a href=\"http://google.com/\">http://google.com/</a> </em></p>\n\n" ],
]);

build_and_test( "Link with title", 
    "This is [an example](http://example.com/ \"Title\") inline link.", [
    [ result_is => "<p>This is <a href=\"http://example.com/\" title=\"Title\">an example</a> inline link.</p>\n\n" ],
]);

build_and_test( "Link without title", 
    "[This link](http://example.net/) has no title attribute.", [
    [ result_is => "<p><a href=\"http://example.net/\">This link</a> has no title attribute.</p>\n\n" ],
]);

done_testing;
