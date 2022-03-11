package TeX::Node::DiscretionaryNode;

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

use TeX::WEB2C qw(:node_params);

use base qw(TeX::Node::AbstractNode);

use TeX::Class;

use TeX::WEB2C qw(:node_params);

my %replace_count_of :ATTR(:get<replace_count> :set<replace_count> :default(0));
my %pre_break_of     :ATTR(:get<pre_break>     :set<pre_break>);
my %post_break_of    :ATTR(:get<post_break>    :set<post_break>);

sub BUILD {
    my ($self, $ident, $arg_ref) = @_;

    $self->set_type(disc_node);

    $replace_count_of{$ident} = $arg_ref->{replace_count};
    $pre_break_of    {$ident} = $arg_ref->{pre_break};
    $post_break_of   {$ident} = $arg_ref->{post_break};

    return;
}

1;

__END__
