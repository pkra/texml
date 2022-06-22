package TeX::Interpreter::LaTeX::Package::braket;

# Copyright (C) 2022 American Mathematical Society
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# For more details see, https://github.com/AmerMathSoc/texml

# This code is experimental and is provided completely without warranty
# or without any promise of support.  However, it is under active
# development and we welcome any comments you may have on it.

# American Mathematical Society
# Technical Support
# Publications Technical Group
# 201 Charles Street
# Providence, RI 02904
# USA
# email: tech-support@ams.org

use strict;
use warnings;

sub install ( $ ) {
    my $class = shift;

    my $tex = shift;

    $tex->package_load_notification();

    $tex->read_package_data();

    return;
}

1;

__DATA__

\ProvidesPackage{braket}

\DeclareMathPassThrough{bra}[1]
\DeclareMathPassThrough{ket}[1]
\DeclareMathPassThrough{braket}[1]
\DeclareMathPassThrough{set}[1]
\DeclareMathPassThrough{Bra}[1]
\DeclareMathPassThrough{Ket}[1]
\DeclareMathPassThrough{Braket}[1]
\DeclareMathPassThrough{Set}[1]
\DeclareMathPassThrough{ketbra}[1]
\DeclareMathPassThrough{Ketbra}[1]

\endinput

__END__
