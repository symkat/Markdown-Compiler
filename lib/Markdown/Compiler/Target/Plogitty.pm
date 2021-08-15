package Markdown::Compiler::Target::Plogitty;
use Moo;
extends 'Markdown::Compiler::Target::HTML';

sub codeblock {
    my ( $self, $node, $content ) = @_;

    return "<div class=\"mermaid\">\n$content\n</div>\n\n"
        if $node->{language} and $node->{language} eq 'mermaid';

    return $node->{language}
        ? "<pre><code class=\"" . $node->{language} . "\">\n$content\n</code></pre>\n\n"
        : "<pre><code class=\"plaintext\">\n$content\n</code></pre>\n\n";
}

sub paragraph_image {
    my ( $self, $node ) = @_;

    if ( $node->{title} ) {
        return sprintf( '<img class="img-fluid" src="%s" title="%s" alt="%s">',
            $node->{href},
            $node->{title},
            $node->{text}
        );
    } else {
        return sprintf( '<img class="img-fluid" src="%s" alt="%s">',
            $node->{href},
            $node->{text} ? $node->{text} : $node->{href},
        );
    }
}

1;
