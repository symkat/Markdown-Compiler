# ABSTRACT: Perl Markdown Compiler
package Markdown::Compiler;
use Moo;
use Markdown::Compiler::Lexer;
use Markdown::Compiler::Parser;
use Markdown::Compiler::Target::HTML;

has source => (
    is       => 'ro',
    required => 1,
);

has lexer => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Lexer->new( source => shift->source );
    },
);

has parser => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Parser->new( stream => shift->stream );
    },
);

has stream => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        shift->lexer->tokens;
    },
);

has tree => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        shift->parser->tree;
    },
);

has compiler => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        Markdown::Compiler::Target::HTML->new( tree => shift->tree );
    },
);

has result => (
    is      => 'ro',
    lazy    => 1,
    builder => sub {
        shift->compiler->result;
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

__END__

=encoding utf8

=head1 NAME

Markdown::Compiler - A Markdown Compiler

=head1 DESCRIPTION

Markdown::Compiler is a malleable markdown parser and compiler.

=head1 SYNOPSIS

=head1 CONSTRUCTOR

=head2 source

=head2 lexer

=head2 parser

=head2 compiler

=head1 METHODS

=head2 lexer

=head2 parser

=head2 stream

=head2 tree

=head2 compiler

=head2 result

=head2 metadata

=head1 AUTHOR

Kaitlyn Parkhurst (SymKat) I<E<lt>symkat@symkat.comE<gt>> ( Blog: L<http://symkat.com/> )

=head1 CONTRIBUTORS

=head1 COPYRIGHT

Copyright (c) 2021 the Markdown::Compiler L</AUTHOR> and L</CONTRIBUTORS> as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms as perl itself.

=head1 AVAILABILITY

The most current version of Markdown::Compiler can be found at L<https://github.com/symkat/Markdown-Compiler>

