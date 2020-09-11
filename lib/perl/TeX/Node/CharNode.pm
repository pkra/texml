package TeX::Node::CharNode;

use strict;
use warnings;

use base qw(TeX::Node::AbstractNode);

use TeX::Class;

use TeX::Arithmetic qw(scaled_to_string);

use TeX::Utils qw(print_char_code);

use TeX::WEB2C qw(:node_params :type_bounds);

use TeX::Node::HListNode qw(:factories);

my %font_of      :ATTR(:get<font>      :set<font>);
my %char_code_of :ATTR(:get<char_code> :set<char_code>);

sub BUILD {
    my ($self, $ident, $arg_ref) = @_;

    $self->set_type(max_halfword);

    $font_of{$ident}      = $arg_ref->{font};
    $char_code_of{$ident} = $arg_ref->{char_code};

    return;
}

# sub to_string :STRINGIFY {
#     my $self = shift;
# 
#     my $font = $self->get_font();
#     my $char = $self->get_char_code();
# 
#     return sprintf ("Character %s of %s", print_char_code($char), $font);
# }

sub to_string :STRINGIFY {
    my $self = shift;

    my $char = $self->get_char_code();

    return chr($char);
}

sub show_node {
    my $self = shift;

    my $font = $self->get_font();
    my $char = $self->get_char_code();

    return sprintf "%s %s", $font, print_char_code($char);
}

sub to_string_detailed {
    my $self = shift;

    my $font = $self->get_font();
    my $char = $self->get_char_code();

    if ($font->isa("TeX::Font")) {
        return sprintf ("Character %s of %s: (%5f+%5f)x%5f + %5f",
                        print_char_code($char),
                        $font,
                        scaled_to_string $font->get_char_height($char),
                        scaled_to_string $font->get_char_depth($char),
                        scaled_to_string $font->get_char_width($char),
                        scaled_to_string $font->get_char_italic_correction($char));
    } else {
        return sprintf ("Character %s of font number %s",
                        print_char_code($char), $font);
    }
}

sub is_char_node {
    return 1;
}

sub get_width {
    my $self = shift;

    my $font = $self->get_font();
    my $char_code = $self->get_char_code();

    return $font->get_char_width($char_code);
}

sub get_height {
    my $self = shift;

    my $font = $self->get_font();
    my $char_code = $self->get_char_code();

    return $font->get_char_height($char_code);
}

sub get_depth {
    my $self = shift;

    my $font = $self->get_font();
    my $char_code = $self->get_char_code();

    return $font->get_char_depth($char_code);
}

sub incorporate_size {
    my $self = shift;

    my $hlist = shift;

    my $font = $self->get_font();
    my $char = $self->get_char_code();

    $hlist->update_natural_width($font->get_char_width($char));

    $hlist->update_height($font->get_char_height($char));
    $hlist->update_depth($font->get_char_depth($char));

    # This seemed like it would be a good idea, but the recursion
    # actually results in each node being counted multiple times.
    # D'oh.

    # for (my $node = $self->get_link(); defined $node; $node = $node->get_link()) {
    #     $node->incorporate_size($hlist);
    # }

    return;
}

sub hpack {
    my $self = shift;

    return new_null_box({ list_ptr => $self })->hpack(@_);
}

1;

__END__
