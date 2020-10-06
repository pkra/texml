package TeX::Primitive::errmessage;

use strict;
use warnings;

use base qw(TeX::Command::Executable);

use TeX::Class;

sub execute {
    my $self = shift;

    my $tex     = shift;
    my $cur_tok = shift;

    $tex->issue_message(1);

    return;
}

1;

__END__
