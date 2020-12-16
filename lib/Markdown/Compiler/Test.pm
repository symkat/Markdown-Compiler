package Markdown::Compiler::Test;
use warnings;
use strict;
use Test::More;
use Import::Into;
use Exporter;
use Markdown::Compiler::Lexer;
use Markdown::Compiler::Parser;
use Markdown::Compiler::Target::HTML;

push our @ISA, qw( Exporter );
push our @EXPORT, qw( _test_dump_lexer _test_dump_parser _test_dump_html );

sub import {
    shift->export_to_level(1);
    
    my $target = caller;

    warnings->import::into($target);
    strict->import::into($target);
    Test::More->import::into($target);
}

sub _test_dump_lexer {
    my ( $source ) = @_;

    my $lexer = Markdown::Compiler::Lexer->new( source => $source );

    foreach my $token ( @{$lexer->tokens} ) {
        ( my $content = $token->content  ) =~ s/\n//g;
        printf( "%20s | %s\n", $content, $token->type );
    }
}

sub _test_dump_parser {
    my ( $source ) = @_;

    my $lexer = Markdown::Compiler::Lexer->new( source => $source );
    my $tree = Markdown::Compiler::Parser->new( stream => $lexer->tokens )->tree;

    use Data::Dumper;
    print Dumper $tree;

    # return @tree;

}

sub _test_dump_html {
    my ( $source ) = @_;

    my $lexer = Markdown::Compiler::Lexer->new( source => $source );
    my $tree = Markdown::Compiler::Parser->new( stream => $lexer->tokens )->tree;
    my $html = Markdown::Compiler::Target::HTML->new( tree => $tree )->html;

    print "==== HTML BEGIN ====\n";
    print "$html\n";
    print "==== HTML END   ====\n";

}

sub assert_lexer {

}



1;
