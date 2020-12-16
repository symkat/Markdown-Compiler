package Markdown::Compiler;
use Moo;
use Markdown::Compiler::Lexer;
use Markdown::Compiler::Parser;
use Markdown::Compiler::Target::HTML;

has source => (
    is       => 'ro',
    required => 1,
);

has stream => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Lexer->new( source => shift->source )->tokens;
    },
);

has tree => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Parser->new( stream => shift->stream )->tree;
    },
);

has compiler => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Target::HTML->new( tree => shift->tree );
    },
);

has markdown => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        shift->compiler->markdown;
    }
);

has metadata => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        shift->compiler->metadata;
    }
);

1;
