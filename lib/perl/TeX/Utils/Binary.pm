package TeX::Utils::Binary;

use strict;
use warnings;

use version; our $VERSION = qv '1.0.0';

use Carp;

use base qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(
    encode_byte
    encode_font_name
    encode_one_argument
    encode_op_code
    encode_pointer
    encode_signed
    encode_signed_pair
    encode_signed_quad
    encode_unsigned
    encode_unsigned_byte
    encode_unsigned_pair
    encode_unsigned_quad
    encode_string
) ]);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{all} } );

our @EXPORT = ( @{ $EXPORT_TAGS{all} } );

sub encode_byte($) {
    my $value = shift;

    return pack "C", $value;
}

sub encode_op_code($) {
    my $value = shift;

    return encode_byte($value);
}

sub encode_unsigned($;$) {
    my $value = shift;
    my $size  = shift || 4;

    my $encoded = pack "N", $value;

    return substr $encoded, -$size;
}

sub encode_unsigned_pair( $ ) {
    my $value = shift;

    return encode_unsigned($value, 2);
}

sub encode_unsigned_byte( $ ) {
    my $value = shift;

    return encode_unsigned($value, 1);
}

sub encode_unsigned_quad( $ ) {
    my $value = shift;

    return encode_unsigned($value, 4);
}

## ???
sub encode_signed($;$) {
    my $value = shift;
    my $size  = shift || 4;

    return encode_unsigned($value, $size);
}

sub encode_signed_pair( $ ) {
    my $value = shift;

    return encode_signed($value, 2);
}

sub encode_signed_quad( $ ) {
    my $value = shift;

    return encode_signed($value, 4);
}

sub encode_pointer($) {
    my $value = shift;

    return encode_signed($value, 4);
}

sub encode_string($;$) {
    my $string = shift;
    my $size   = shift || 1;

    my $length;

    if ($size == 4) {
        $length = encode_signed(length($string), $size);
    } else {
        $length = encode_unsigned(length($string), $size);
    }

    return "$length$string";
}

sub encode_font_name($$) {
    my $area = shift || '';
    my $name = shift;

    my $area_length = encode_unsigned(length($area), 1);
    my $name_length = encode_unsigned(length($name), 1);

    return "$area_length$name_length$area$name";
}

sub encode_one_argument($$) {
    my $spec = shift;

    my $args = shift;

    for ($spec) {
        /^f$/ and do {
            my $fix_word = shift @{ $args };

            $fix_word = int($fix_word * 2**20);

            return encode_signed($fix_word, 4);
        };

        /^i(\d)?$/ and do {
            my $size = $1 || 1;

            return encode_signed(shift @{ $args }, $size);
        };

        /^u(\d)?$/ and do {
            my $size = $1 || 1;

            return encode_unsigned(shift @{ $args }, $size);
        };

        /^S(\d)?$/ and do {
            my $size = $1 || 1;

            my $string = shift @{ $args };

            return encode_string($string, $size);
        };

        /^F$/ and do {
            return encode_font_name(shift @{ $args }, shift @{ $args });
        };

        /^p$/ and do {
            return encode_pointer(shift @{ $args });
        };

        die "Invalid DVI opcode spec: $spec\n";
    }
}

1;

__END__
