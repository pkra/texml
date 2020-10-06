package TeX::Primitive::splitfirstmark;

use strict;
use warnings;

use base qw(TeX::Primitive::TopBotMark);

use TeX::Class;

use TeX::WEB2C qw(:mark_codes);

sub BUILD {
    my ($self, $ident, $arg_ref) = @_;

    $self->set_mark_code(split_first_mark_code);

    return;
}

1;

__END__
