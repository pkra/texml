package TeX::Interpreter::LaTeX::Package::accents;

use strict;
use warnings;

use version; our $VERSION = qv '1.0.0';

sub install ( $ ) {
    my $class = shift;

    my $tex     = shift;
    my @options = @_;

    $tex->package_load_notification(__PACKAGE__, @options);

    $tex->read_package_data(*TeX::Interpreter::LaTeX::Package::accents::DATA{IO});

    return;
}

1;

__DATA__

\TeXMLprovidesPackage{accents}

\DeclareMathPassThrough{accentset}[2]

\TeXMLendPackage

\endinput

__END__
