package TeX::Output::MathML;

use strict;
use warnings;

use integer;

use Carp;

use base qw(TeX::Output);

use TeX::Class;

use Class::Multimethods;

use List::Util qw(max);

use TeX::Arithmetic qw(scaled_to_string);

use TeX::Utils qw(print_char_code);

use TeX::WEB2C qw(:command_codes :node_params);

my %indent_of :ATTR(:get<indent> :set<indent> :default<0>);

sub increase_indent() {
    my $self = shift;

    my $indent = $self->get_indent();

    $self->set_indent($indent + 4);

    return;
}

sub decrease_indent() {
    my $self = shift;

    my $indent = $self->get_indent();

    $self->set_indent(max(0, $indent - 4));

    return;
}

sub output {
    my $self = shift;

    my $string = shift;

    my $indent = $self->get_indent();

    if ($indent > 0) {
        my $prefix = ' ' x $indent;

        $string =~ s{^}{$prefix}gsmx;
    }

    $self->SUPER::output($string);

    return;
}

multimethod ship_out
    => __PACKAGE__, qw(TeX::Node::HListNode)
    => sub {
    my $translator = shift;
    my $hlist = shift;

    translate($translator, $hlist, 1);

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::HListNode), qw(*)
    => sub {
    my $translator = shift;
    my $hlist = shift;

    my $suppress = shift;

    my $tag = $hlist->is_hbox() ? "hlist" : "vlist";

    $translator->output(qq{\n<$tag>\n}) unless $suppress;

    my $node = $hlist->get_list_ptr();

    while (defined $node) {
        $translator->increase_indent() unless $suppress;

        translate($translator, $node);

        $translator->decrease_indent() unless $suppress;

        $node = $node->get_link();
    }

    $translator->output("</$tag>") unless $suppress;

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::CharNode)
    => sub {
    my $translator = shift;
    my $node = shift;

    $translator->output("<char_node>\n");

    my $char_code = $node->get_char_code();
    my $font      = $node->get_font();

    $translator->output("    <font>$font</font>\n");
    $translator->output("    <char>" . print_char_code($char_code) . "</char>\n");

    $translator->output("</char_node>\n");

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::KernNode)
    => sub {
    my $translator = shift;
    my $node = shift;

    my $width = scaled_to_string($node->get_width());

    $translator->output(qq{<kern width="${width}pt"/>\n});

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::GlueNode)
    => sub {
    my $translator = shift;
    my $node = shift;

    my $subtype = $node->get_subtype();

    my $width = scaled_to_string($node->get_width());

    $translator->output(qq{<glue subtype="$subtype" width="${width}pt"/>\n});

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::RuleNode)
    => sub {
    my $translator = shift;
    my $node = shift;

    my $height = $node->get_height();
    my $depth  = $node->get_depth();
    my $width  = $node->get_width();

    $height = ($height == null_flag) ? "*" : scaled_to_string($height);
    $depth  = ($depth  == null_flag) ? "*" : scaled_to_string($depth);
    $width  = ($width  == null_flag) ? "*" : scaled_to_string($width);

    $translator->output(qq{<rule width="$width" height="$height" depth="$depth"/>\n});

    return;
};

multimethod "translate"
    => __PACKAGE__, qw(TeX::Node::MathNode)
    => sub {
    my $translator = shift;
    my $node = shift;

    my $subtype = $node->get_subtype();
    my $width = scaled_to_string($node->get_width());

    if ($subtype == before) {
        $translator->output(qq{\n<math>\n});
        $translator->increase_indent();
    } else {
        $translator->decrease_indent();
        $translator->output(qq{</math>});
    }

    return
};

1;

__END__
