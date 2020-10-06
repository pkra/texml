package TeX::Primitive::Extension::TeXMLGenerateSVG;

use strict;
use warnings;

use base qw(TeX::Command::Executable);

use TeX::Class;

use TeX::Constants qw(:named_args);

use TeX::Utils::Misc;

use Digest::MD5 qw(md5_hex);

use File::Spec::Functions qw(catdir);

use File::Copy;

use XML::LibXML;

sub execute {
    my $self = shift;

    my $tex     = shift;
    my $cur_tok = shift;

    $tex->define_simple_macro(TeXMLlastSVGfile   => "");
    $tex->define_simple_macro(TeXMLlastSVGwidth  => "");
    $tex->define_simple_macro(TeXMLlastSVGheight => "");

    my $tex_fragment = $tex->read_undelimited_parameter();

    my $md5_sum = md5_hex($tex_fragment->to_string());

    my $id = "img$md5_sum";

    my $out_file = "$id.svg";

    my $svg_dir = $tex->TeXML_SVG_dir();

    $svg_dir = "" if $svg_dir eq '.';

    if (nonempty($svg_dir)) {
        $out_file = catdir($svg_dir, $out_file);
    }

    my $regenerate = $tex->do_svg();

    if (-e $out_file) {
        my $tex_file = $tex->get_file_name();

        if (file_mtime($tex_file) < file_mtime($out_file)) {
            $tex->print_nl("Found up-to-date $out_file.  Not regenerating.");

            $regenerate = 0;
        }
    }

    if ($regenerate) {
        my $svg = $tex->get_svg_agent();

        my $svg_file = $svg->convert_tex($tex_fragment, $id, $tex);

        if (empty($svg_file)) {
            undef $out_file;
        } else {
            if (nonempty($svg_dir) && ! -e $svg_dir) {
                mkdir $svg_dir or do {
                    $tex->print_err("Unable to create $svg_dir directory");

                    $tex->error();

                    return;
                };
            }

            copy($svg_file, $out_file) or do {
                $tex->fatal_error("Couldn't copy $svg_file to $out_file: $!");
            };

            $tex->print_nl("Wrote SVG file $out_file");
            $tex->print_ln();
        }
    }

    if (nonempty($out_file)) {
        my $doc = XML::LibXML->load_xml(location => $out_file);

        my $root = $doc->documentElement();

        my $width  = $root->getAttribute("width");
        my $height = $root->getAttribute("height");

        $tex->define_simple_macro(TeXMLlastSVGfile   => $out_file);
        $tex->define_simple_macro(TeXMLlastSVGwidth  => $width);
        $tex->define_simple_macro(TeXMLlastSVGheight => $height);
    }

    return;
}

1;

__END__
