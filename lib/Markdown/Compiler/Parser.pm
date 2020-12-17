package Markdown::Compiler::Parser;
BEGIN {
    {
        package Markdown::Compiler::Parser::Node;
        use Moo;

        has tokens => (
            is       => 'ro',
            required => 1,
        );
        
        has children => (
            is       => 'ro',
        );

        has content => (
            is => 'ro',
        );

        1;
    }
    {
        package Markdown::Compiler::Parser::Node::Header;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        has size => (
            is => 'ro',
        );

        1;
    }
    {
        package Markdown::Compiler::Parser::Node::HR;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;
    }
    
    {
        package Markdown::Compiler::Parser::Node::Paragraph;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Paragraph::BoldItalic;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Paragraph::Bold;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Paragraph::Italic;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Paragraph::String;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;

    }
    
    {
        package Markdown::Compiler::Parser::Node::Paragraph::Link;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        has [qw( href title text )] => (
            is => 'ro',
        );

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Paragraph::Image;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node::Paragraph::Link';

        1;

    }

    {
        package Markdown::Compiler::Parser::Node::Table;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;
    }

    {
        package Markdown::Compiler::Parser::Node::Blockquote;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;
    }

    {
        package Markdown::Compiler::Parser::Node::Codeblock;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;
    }

    {
        package Markdown::Compiler::Parser::Node::List;
        use Moo;
        extends 'Markdown::Compiler::Parser::Node';

        1;
    }
}
use Moo;

has stream => (
    is       => 'ro',
    required => 1,
);

has tree => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_tree',
);


sub _build_tree {
    my ( $self ) = @_;

    my @tokens = @{$self->stream};

    return $self->_parse(\@tokens);
}

sub _parse {
    my ( $self, $tokens ) = @_;
    my @tree;

    while ( defined ( my $token = shift @{ $tokens } ) ) {
        # Header
        if ( $token->type eq 'Header' ) {
            push @tree, Markdown::Compiler::Parser::Node::Header->new(
                size    => $token->size,
                tokens  => [ $token ],
                content => $token->content,
            );
            next;
        }

        # Paragraphs
        elsif ( grep { $token->type eq $_ } ( qw( EscapedChar Image Link Word Char Bold Italic BoldItalic ) ) ) {
            unshift @{$tokens}, $token; # Put the token back and go to paragraph context.
            push @tree, Markdown::Compiler::Parser::Node::Paragraph->new(
                tokens   => [ $token ],
                children => [ $self->_parse_paragraph( $tokens ) ],
            );
            next;
        }
        
        # HR
        elsif ( $token->type eq 'HR' ) {
            push @tree, Markdown::Compiler::Parser::Node::HR->new(
                tokens   => [ $token ],
            );
            next;
        }

        # Tables
        elsif ( $token->type eq 'TableStart' ) {
            push @tree, Markdown::Compiler::Parser::Node::Table->new(
                tokens   => [ $token ],
                children => [ $self->_parse_table( $tokens ) ],
            );
            next;
        }
        
        # Blockquotes
        elsif ( $token->type eq 'Blockquote' ) {
            push @tree, Markdown::Compiler::Parser::Node::Blockquote->new(
                tokens   => [ $token ],
                children => [ $self->_parse_blockquote( $tokens ) ],
            );
            next;
        }
        
        # Code Blocks
        elsif ( $token->type eq 'Codeblock' ) {
            push @tree, Markdown::Compiler::Parser::Node::Codeblock->new(
                tokens   => [ $token ],
                children => [ $self->_parse_codeblock( $tokens ) ],
            );
            next;
        }
        
        # Lists
        elsif ( $token->type eq 'Item' ) {
            push @tree, Markdown::Compiler::Parser::Node::List->new(
                tokens   => [ $token ],
                children => [ $self->_parse_codeblock( $tokens ) ],
            );
            next;
        }

        # Tokens To Ignore
        elsif ( grep { $token->type eq $_ } ( qw( LineBreak ) ) ) {
            # Do Nothing.
            next;
        }

        # Unknown Token?
        else {
            die "Parser::_parse() could not handle token " . $token->type;
        }
    }
    return [ @tree ];
}

sub _parse_paragraph {
    my ( $self, $tokens ) = @_;

    my @tree;

    while ( defined ( my $token = shift @{ $tokens } ) ) {
        # Exit Conditions:
        #
        #   - No more tokens (after while loop)
        #   - Two new line tokens in a rwo (first one is eaten)
        if ( $token->type eq 'LineBreak' ) {
            if ( exists $tokens->[0] and $tokens->[0]->type eq 'LineBreak' ) {
                # Double Line Break, Bail Out
                return @tree;
            }
            # Single Line Break - Ignore
            next;
        }
        # Exit Conditions Continued:
        #
        #    - Tokens which are invalid in this context, put the token back and return our @ree
        if ( grep { $token->type eq $_ } (qw(TableStart CodeBlock BlockQuote List HR)) ) {
            unshift @$tokens, $token;
            return @tree;
        }


        # Parsing
        if ( grep { $token->type eq $_ } (qw(EscapedChar Space Word Char)) ) {
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::String->new(
                content => $token->content,
                tokens  => [ $token ],
            );
            next;
        }

        if ( grep { $token->type eq $_ } (qw(Link)) ) {
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::Link->new(
                text    => $token->text,
                title   => $token->title,
                href    => $token->href,
                tokens  => [ $token ],
            );
            next;
        }
        
        if ( $token->type eq 'Image' ) {
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::Image->new(
                text    => $token->text,
                title   => $token->title,
                href    => $token->href,
                tokens  => [ $token ],
            );
            next;
        }
        
        if ( $token->type eq 'BoldItalic' ) {
            my @todo;

            # Eat tokens until the next BoldItalic block, these tokens will be recursively processed.
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->type eq 'BoldItalic';
                push @todo, $todo_token;
            }

            # Process the children with _parse_paragraph.
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::BoldItalic->new(
                content => $token->content,
                tokens  => [ $token ],
                children => [ $self->_parse_paragraph( \@todo ) ],
            );
            next;
        }
        
        if ( $token->type eq 'Bold' ) {
            my @todo;

            # Eat tokens until the next Bold block, these tokens will be recursively processed.
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->type eq 'Bold';
                push @todo, $todo_token;
            }

            # Process the children with _parse_paragraph.
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::Bold->new(
                content => $token->content,
                tokens  => [ $token ],
                children => [ $self->_parse_paragraph( \@todo ) ],
            );
            next;
        }

        if ( $token->type eq 'Italic' ) {
            my @todo;

            # Eat tokens until the next Italic block, these tokens will be recursively processed.
            while ( defined ( my $todo_token = shift @{ $tokens } ) ) {
                last if $todo_token->type eq 'Italic';
                push @todo, $todo_token;
            }

            # Process the children with _parse_paragraph.
            push @tree, Markdown::Compiler::Parser::Node::Paragraph::Italic->new(
                content => $token->content,
                tokens  => [ $token ],
                children => [ $self->_parse_paragraph( \@todo ) ],
            );
            next;
        }
        
        # Unknown Token?
        else {
            die "Parser::_parse_paragraph() could not handle token " . $token->type;
        }
    }
    return @tree;
}

sub _parse_table {
    my ( $self, $tokens ) = @_;
        # Token Types:
        # package Markdown::Compiler::Lexer;
        # package Markdown::Compiler::Lexer::Token;
        # package Markdown::Compiler::Lexer::Token::EscapedChar;
        # package Markdown::Compiler::Lexer::Token::CodeBlock;
        # package Markdown::Compiler::Lexer::Token::HR;
        # package Markdown::Compiler::Lexer::Token::Image;
        # package Markdown::Compiler::Lexer::Token::Link;
        # package Markdown::Compiler::Lexer::Token::Item;
        # package Markdown::Compiler::Lexer::Token::TableStart;
        # package Markdown::Compiler::Lexer::Token::TableHeaderSep;
        # package Markdown::Compiler::Lexer::Token::BlockQuote;
        # package Markdown::Compiler::Lexer::Token::Header;
        # package Markdown::Compiler::Lexer::Token::Bold;
        # package Markdown::Compiler::Lexer::Token::Italic;
        # package Markdown::Compiler::Lexer::Token::BoldItalic;
        # package Markdown::Compiler::Lexer::Token::BoldItalicMaker;
        # package Markdown::Compiler::Lexer::Token::LineBreak;
        # package Markdown::Compiler::Lexer::Token::Space;
        # package Markdown::Compiler::Lexer::Token::Word;
        # package Markdown::Compiler::Lexer::Token::Char;

}

sub _parse_blockquote {
    my ( $self, $tokens ) = @_;

        # Token Types:
        # package Markdown::Compiler::Lexer;
        # package Markdown::Compiler::Lexer::Token;
        # package Markdown::Compiler::Lexer::Token::EscapedChar;
        # package Markdown::Compiler::Lexer::Token::CodeBlock;
        # package Markdown::Compiler::Lexer::Token::HR;
        # package Markdown::Compiler::Lexer::Token::Image;
        # package Markdown::Compiler::Lexer::Token::Link;
        # package Markdown::Compiler::Lexer::Token::Item;
        # package Markdown::Compiler::Lexer::Token::TableStart;
        # package Markdown::Compiler::Lexer::Token::TableHeaderSep;
        # package Markdown::Compiler::Lexer::Token::BlockQuote;
        # package Markdown::Compiler::Lexer::Token::Header;
        # package Markdown::Compiler::Lexer::Token::Bold;
        # package Markdown::Compiler::Lexer::Token::Italic;
        # package Markdown::Compiler::Lexer::Token::BoldItalic;
        # package Markdown::Compiler::Lexer::Token::BoldItalicMaker;
        # package Markdown::Compiler::Lexer::Token::LineBreak;
        # package Markdown::Compiler::Lexer::Token::Space;
        # package Markdown::Compiler::Lexer::Token::Word;
        # package Markdown::Compiler::Lexer::Token::Char;
}

sub _parse_codeblock {
    my ( $self, $tokens ) = @_;

        # Token Types:
        # package Markdown::Compiler::Lexer;
        # package Markdown::Compiler::Lexer::Token;
        # package Markdown::Compiler::Lexer::Token::EscapedChar;
        # package Markdown::Compiler::Lexer::Token::CodeBlock;
        # package Markdown::Compiler::Lexer::Token::HR;
        # package Markdown::Compiler::Lexer::Token::Image;
        # package Markdown::Compiler::Lexer::Token::Link;
        # package Markdown::Compiler::Lexer::Token::Item;
        # package Markdown::Compiler::Lexer::Token::TableStart;
        # package Markdown::Compiler::Lexer::Token::TableHeaderSep;
        # package Markdown::Compiler::Lexer::Token::BlockQuote;
        # package Markdown::Compiler::Lexer::Token::Header;
        # package Markdown::Compiler::Lexer::Token::Bold;
        # package Markdown::Compiler::Lexer::Token::Italic;
        # package Markdown::Compiler::Lexer::Token::BoldItalic;
        # package Markdown::Compiler::Lexer::Token::BoldItalicMaker;
        # package Markdown::Compiler::Lexer::Token::LineBreak;
        # package Markdown::Compiler::Lexer::Token::Space;
        # package Markdown::Compiler::Lexer::Token::Word;
        # package Markdown::Compiler::Lexer::Token::Char;
}

sub _parse_list {
    my ( $self, $tokens ) = @_;

        # Token Types:
        # package Markdown::Compiler::Lexer;
        # package Markdown::Compiler::Lexer::Token;
        # package Markdown::Compiler::Lexer::Token::EscapedChar;
        # package Markdown::Compiler::Lexer::Token::CodeBlock;
        # package Markdown::Compiler::Lexer::Token::HR;
        # package Markdown::Compiler::Lexer::Token::Image;
        # package Markdown::Compiler::Lexer::Token::Link;
        # package Markdown::Compiler::Lexer::Token::Item;
        # package Markdown::Compiler::Lexer::Token::TableStart;
        # package Markdown::Compiler::Lexer::Token::TableHeaderSep;
        # package Markdown::Compiler::Lexer::Token::BlockQuote;
        # package Markdown::Compiler::Lexer::Token::Header;
        # package Markdown::Compiler::Lexer::Token::Bold;
        # package Markdown::Compiler::Lexer::Token::Italic;
        # package Markdown::Compiler::Lexer::Token::BoldItalic;
        # package Markdown::Compiler::Lexer::Token::BoldItalicMaker;
        # package Markdown::Compiler::Lexer::Token::LineBreak;
        # package Markdown::Compiler::Lexer::Token::Space;
        # package Markdown::Compiler::Lexer::Token::Word;
        # package Markdown::Compiler::Lexer::Token::Char;
}

1;