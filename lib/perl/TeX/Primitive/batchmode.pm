package TeX::Primitive::batchmode;

use strict;
use warnings;

use base qw(TeX::Command::Executable);

use TeX::WEB2C qw(:interaction_modes);

use TeX::Class;

sub execute {
    my $self = shift;

    my $tex     = shift;
    my $cur_tok = shift;

    $tex->set_interaction_mode(batch_mode);

    return;
}

1;

__END__
