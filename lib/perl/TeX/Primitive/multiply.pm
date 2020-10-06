package TeX::Primitive::multiply;

use strict;
use warnings;

use base qw(TeX::Primitive::RegisterArithmetic);

use TeX::Class;

use TeX::WEB2C qw(:command_codes);

sub BUILD {
    my ($self, $ident, $arg_ref) = @_;

    $self->set_opcode(multiply);

    return;
}

1;

__END__
