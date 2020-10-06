package TeX::Interpreter::LaTeX::Class::amscommon;

## All of the metadata-related code has been ripped out of this.

use strict;
use warnings;

use version; our $VERSION = qv '1.0.0';

use TeX::Utils::Misc;

use TeX::Constants qw(:named_args);

use TeX::Token qw(:factories);

use TeX::WEB2C qw(:save_stack_codes :token_types :catcodes);

use TeX::Command::Executable::Assignment qw(:modifiers);

use TeX::Node::Extension::UnicodeCharNode qw(:factories);

######################################################################
##                                                                  ##
##                             METHODS                              ##
##                                                                  ##
######################################################################

sub install ( $ ) {
    my $class = shift;

    my $tex     = shift;
    my @options = @_;

    $tex->class_load_notification(__PACKAGE__, @options);

    $tex->load_package("amsthm");
    $tex->load_package("amsfonts");

    $tex->define_csname(em => make_font_declaration("italic"));
    $tex->define_csname(it => make_font_declaration("italic"));
    $tex->define_csname(bf => make_font_declaration("bold"));
    $tex->define_csname(sc => make_font_declaration("sc"));
    $tex->define_csname(rm => make_font_declaration("roman"));
    $tex->define_csname(tt => make_font_declaration("monospace"));
    $tex->define_csname(sf => make_font_declaration("sans-serif"));

    $tex->define_csname(sl => make_font_declaration("styled-content", "oblique") );

    ## If I understood perl symbol tables better, I could probably do
    ## this in a less verbose way.

    $tex->read_package_data(*TeX::Interpreter::LaTeX::Class::amscommon::DATA{IO});

    $tex->define_csname(revertcopyright => \&do_revertcopyright);

    ## TODO: Much of this should probably be redone at the TeX macro level.

    $tex->define_csname(title => \&do_title);
    $tex->define_csname(subtitle => \&do_subtitle);

    for my $tag (qw(author editor translator contrib)) {
        $tex->define_csname($tag, make_contributor_handler());
    }

    $tex->define_csname(issueinfo => \&do_issueinfo);
    $tex->define_csname(publinfo => \&do_publinfo);    # deprecated
    $tex->define_csname(seriesinfo => \&do_seriesinfo);# preferred

    $tex->define_csname(PII => \&do_PII);

    $tex->define_csname(commby => \&do_commby);
    $tex->define_csname(pagespan => \&do_pagespan);
    $tex->define_csname(date => \&do_date);
    $tex->define_csname(dateposted => \&do_dateposted);
    $tex->define_csname(keywords => \&do_keywords);
    $tex->define_csname(copyrightinfo => \&do_copyrightinfo);
    $tex->define_csname(subjclass     => \&do_subjclass);

    $tex->define_csname(abstract    => \&do_abstract);
    $tex->define_csname(endabstract => \&do_endabstract);

    $tex->define_csname(maketitle => \&do_maketitle);

    $tex->define_pseudo_macro(MR => \&do_MR);

    return;
}

######################################################################
##                                                                  ##
##                     OLD STYLE FONT COMMANDS                      ##
##                                                                  ##
######################################################################

use constant RIGHT_BRACE_TOKEN => make_character_token("}", CATCODE_LETTER);
use constant RIGHT_BRACE_CHAR  => new_unicode_character(ord("}"));

sub make_font_declaration( $;$ ) {
    my $qName = shift;
    my $style = shift;

    return sub {
        my $tex   = shift;
        my $token = shift;

        my $cur_group = $tex->cur_group();

        my $name = $token->get_csname();

        if ($tex->is_mmode()) {
            my $csname = "math" . ($name eq 'em' ? "it" : $name);

            my $begin = $tex->tokenize("\\string\\${csname}\\string{");

            $tex->begin_token_list($begin, macro);

            if ($cur_group == math_shift_group) { # $\rm x$
                $tex->set_node_register(end_math_list => RIGHT_BRACE_CHAR);
            }
            elsif ($cur_group == math_left_group) { # $\left(\rm b\right)$
                $tex->set_node_register(end_math_list => RIGHT_BRACE_CHAR);
            }
            else {
                $tex->save_for_after(RIGHT_BRACE_TOKEN);
            }
        } else {
            if ($cur_group != simple_group) {
                my $file_name = $tex->get_file_name() || '<undef>';
                my $line_no   = $tex->input_line_no() || '<undef>';

                $tex->print_err("Ignoring improper \\$name at $file_name l. $line_no");
                $tex->error();

                return;
            }

            $tex->leavevmode();

            my $start = qq{\\startinlineXMLelement{$qName}};

            if ($name eq 'em') {
                $start .= qq{\\setXMLattribute{toggle}{yes}};
            } elsif (nonempty($style)) {
                $start .= qq{\\setXMLattribute{style-type}{$style}};
            }

            my $begin = $tex->tokenize($start);

            $tex->begin_token_list($begin, macro);

            my $end = sub { $tex->end_xml_element($qName) };

            $tex->save_for_after(make_anonymous_token($end));
        }

        return;
    };
}

######################################################################
##                                                                  ##
##                              MACROS                              ##
##                                                                  ##
######################################################################

sub do_issueinfo {
    my $tex   = shift;
    my $token = shift;

    my $volume = $tex->read_undelimited_parameter();
    my $number = $tex->read_undelimited_parameter();
    my $month  = $tex->read_undelimited_parameter();
    my $year   = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_publinfo {
    my $tex   = shift;
    my $token = shift;

    my $publ_key  = $tex->read_undelimited_parameter();
    my $volume_id = $tex->read_undelimited_parameter();
    my $volume    = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_seriesinfo {
    my $tex   = shift;
    my $token = shift;

    my $publ_key  = $tex->read_undelimited_parameter();
    my $volume_id = $tex->read_undelimited_parameter();
    my $volume    = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_PII {
    my $tex   = shift;
    my $token = shift;

    my $pii = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_commby {
    my $tex   = shift;
    my $token = shift;

    my $commby = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_date {
    my $tex   = shift;
    my $token = shift;

    my $raw_date = $tex->read_undelimited_parameter(EXPANDED);

    ## DO SOMETHING WITH THIS

    return;
}

sub do_dateposted {
    my $tex   = shift;
    my $token = shift;

    my $raw_date = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_keywords {
    my $tex   = shift;
    my $token = shift;

    my $keywords = $tex->read_undelimited_parameter();

    my $atoms = qr{ ( \$\$ [^\$]+ \$\$ | \$ [^\$]+ \$ | [^,] ) }smx;

    ## DO SOMETHING WITH THIS

    return;
}

sub do_copyrightinfo( $ ) {
    my $tex   = shift;
    my $token = shift;

    my $year   = $tex->read_undelimited_parameter();
    my $holder = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_pagespan {
    my $tex   = shift;
    my $token = shift;

    my $start_page = $tex->read_undelimited_parameter();
    my $end_page   = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_revertcopyright {
    my $tex   = shift;
    my $token = shift;

    ## DO SOMETHING WITH THIS

    return;
}

sub do_subjclass( $ ) {
    my $tex   = shift;
    my $token = shift;

    my $schema = $tex->scan_optional_argument();

    my $subjclass = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_title {
    my $tex   = shift;
    my $token = shift;
    
    my $short_title = $tex->scan_optional_argument();

    my $title = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_subtitle {
    my $tex   = shift;
    my $token = shift;
    
    my $short_title = $tex->scan_optional_argument();

    my $title = $tex->read_undelimited_parameter();

    ## DO SOMETHING WITH THIS

    return;
}

sub do_maketitle {
    my $tex   = shift;
    my $token = shift;
    
    $tex->end_par();

    $tex->process_string(qq{\\mainmatter});

    $tex->let_csname("maketitle", '@empty', MODIFIER_GLOBAL);

    return;
}

sub do_MR {
    my $macro = shift;

    my $tex   = shift;
    my $token = shift;

    my $mrnum = trim($tex->read_undelimited_parameter(EXPANDED));

    $mrnum =~ s/\A MR\s*//smx;

    my $cno = $mrnum;

    if ( $mrnum =~ /.+?\s*\(.*?\)/ ) {
        $mrnum =~ /(.+?)\s*\(.*?\)/;
        $cno = $1;
    }

    my $url = "https://www.ams.org/mathscinet-getitem?mr=$cno";

    my $tex_text = << "EOF";
\\startXMLelement{ext-link}%
\\setXMLattribute{xlink:href}{$url}%
MR \\textbf{$mrnum}%
\\endXMLelement{ext-link}%
EOF

    return $tex->tokenize($tex_text);
}

######################################################################
##                                                                  ##
##                           CONTRIBUTORS                           ##
##                                                                  ##
######################################################################

sub make_contributor_handler( ;$ ) {
    my $document = shift;

    return sub {
        my $tex   = shift;
        my $token = shift;
        
        my $description = $tex->scan_optional_argument();

        my $unparsed = $tex->read_undelimited_parameter();

        return;
    };
}

######################################################################
##                                                                  ##
##                           ENVIRONMENTS                           ##
##                                                                  ##
######################################################################

sub do_abstract( $$ ) {
    my $tex   = shift;
    my $token = shift;

    my $abstract = $tex->scan_environment_body("abstract");

    ## DO SOMETHING WITH THIS

    return;
}

sub do_endabstract( $$ ) {
    my $tex   = shift;
    my $token = shift;

    $tex->print_err("Orphaned \\endabstract");

    $tex->error();

    return;
}

1;

__DATA__

\TeXMLprovidesClass{amscommon}

\UCSchardef\textprime"2032

\let\NoTOC\@gobble
\def\for#1#2{}

% \let\qed\@empty

\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{1}

\def\nonbreakingspace{\unskip\nobreakspace\ignorespaces}

%% Begin extract from new version of amsbook

\def\disable@footnotes{%
    \let\footnote\@gobble@opt
    \let\footnotemark\@gobbleopt
    \let\footnotetext\@gobble@opt
}

%% End extract from new version of amsbook

% \disable@footnotes

\def\newGif#1{%
  \count@\escapechar \escapechar\m@ne
    \global\let#1\iffalse
    \@Gif#1\iftrue
    \@Gif#1\iffalse
  \escapechar\count@}
\def\@Gif#1#2{%
  \expandafter\def\csname\expandafter\@gobbletwo\string#1%
                    \expandafter\@gobbletwo\string#2\endcsname
                       {\global\let#1#2}}

\newGif\if@frontmatter
\newGif\if@mainmatter
\newGif\if@backmatter

\AtBeginDocument{%
    \global\let\XML@component@tag\@empty
    \end@component
}

\def\start@component#1{%
    \gdef\XML@component@tag{#1}%
    \typeout{Entering <\XML@component@tag\ignorespaces>}%
    \startXMLelement{\XML@component@tag}%
    \addXMLid
}

\def\end@component{%
    \@clear@sectionstack
    \ifx\XML@component@tag\@empty\else
        \typeout{Exiting <\XML@component@tag\ignorespaces>}%
        \endXMLelement{\XML@component@tag}%
    \fi
    \@frontmatterfalse
    \@mainmatterfalse
    \@backmatterfalse
    \global\let\XML@component@tag\@empty    
}

\AtEndDocument{\end@component}

\def\frontmatter{%
    \if@frontmatter\else
        \end@component
        \@frontmattertrue
        \start@component{front}%
    \fi
}

\def\mainmatter{%
    \if@mainmatter\else
        \end@component
        \@mainmattertrue
        \start@component{body}%
        %%
        %% If there is any text before the first sectioning command,
        %% we need to make sure there is still a <sec> element
        %% wrapping that text.  A \chapter or \section command will
        %% reset \everypar{}
        %%
        \everypar{\section*{}}%
    \fi
}

\def\backmatter{%
    \if@backmatter\else
        \end@component
        \@backmattertrue
        \start@component{back}%
    \fi
}

\def\appendix{%
    \par
    \backmatter
    \startXMLelement{app-group}%
    \addXMLid
    \@push@sectionstack{0}{app-group}%
    \c@section\z@
    \c@subsection\z@
    \let\sectionname\appendixname
    \def\thesection{\@Alph\c@section}%
}

\newenvironment{dedication}{%
    \frontmatter
    \let\\\@centercr
    \startXMLelement{dedication}
    \addXMLid
        \startXMLelement{book-part-meta}
            \startXMLelement{title-group}
                \thisxmlpartag{title}%
                Dedication\par
            \endXMLelement{title-group}
        \endXMLelement{book-part-meta}
        \startXMLelement{named-book-part-body}
        \par
}{%
        \par
        \endXMLelement{named-book-part-body}
    \endXMLelement{dedication}
}

\UCSchardef\bysame"2014

\UCSchardef\DH"00D0
\UCSchardef\dh"00F0
\UCSchardef\DJ"0110
\UCSchardef\dj"0111

\let\@writetocindents\@empty

\RestoreEnvironmentDefinition{enumerate}
\RestoreEnvironmentDefinition{itemize}

%% TODO: Use \descriptionlabel, but first rewrite it to add a wrapping
%% element around #1.

\def\description{\list{}{}}
\let\enddescription\endlist

\def\labelitemi{\textbullet}
\def\labelitemii{{\normalfont\textbf{\textendash}}}
\def\labelitemiii{\textasteriskcentered}
\def\labelitemiv{\textperiodcentered}

% <ref-list>
%     <ref id ="AlexeevGibneySwinarsky">
%         <label>[1]</label>
%         <mixed-citation>.....</mixed-citation>
%     </ref>
% </ref-list>

\let\bibintro\@empty
\let\bibliographystyle\@gobble

\renewenvironment{thebibliography}[1]{%
    \if@backmatter
        \@clear@sectionstack
    \else
        \backmatter
    \fi
    %% I'm not sure what to do with \bibintro or if it should even be
    %% here to begin with, so I'm going to disable it for now.
    % \ifx\@empty\bibintro \else
    %     \begingroup
    %         \bibintro\par
    %     \endgroup
    % \fi
    \renewcommand\theenumiv{\arabic{enumiv}}%
    \let\p@enumiv\@empty
    \def\@listelementname{ref-list}%
    \def\@listitemname{ref}%
    % \def\@listlabelname{label}
    \let\@listlabelname\@empty
    \def\@listdefname{mixed-citation}
    \list{\@biblabel{\theenumiv}}{%
        \usecounter{enumiv}%
        \@listXMLidtrue
    }%
    \startXMLelement{title}%
    \refname
    \endXMLelement{title}%
    \let\@listpartag\@empty
}{%
    \def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
    \endlist
}

% <fig id="raptor" position="float">
%   <label>Figure 1</label>
%   <caption>
%     <title>Le Raptor.</title>
%     <p>Rapidirap.</p>
%   </caption>
%   <graphic xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="data/samples/raptor.jpg"/>
% </fig>

\def\jats@figure@element{fig}

\def\caption{%
    \ifx\@captype\@undefined
        \@latex@error{\noexpand\caption outside float}\@ehd
        \expandafter\@gobble
    \else
        \expandafter\@firstofone
    \fi
    \@ifstar{\st@rredtrue\caption@}{\st@rredfalse\caption@}%
}

\SaveMacroDefinition\caption

\def\caption@{\@dblarg{\@caption\@captype}}

\SaveMacroDefinition\caption@

\def\@caption#1[#2]#3{%
    \ifst@rred\else
        %%
        %% Try very very hard not to output an empty <label/>
        %%
        \protected@edef\@tempa{\csname #1name\endcsname}%
        \ifx\@tempa\@empty\else
            \protected@edef\@tempa{\@tempa\space}%
        \fi
        \expandafter\ifx\csname the#1\endcsname \@empty \else
            \refstepcounter{#1}%
            \protected@edef\@tempa{\@tempa\csname the#1\endcsname}%
        \fi
        \ifx\@tempa\@empty\else
            \startXMLelement{label}%
            \ignorespaces\@tempa
            \endXMLelement{label}%
        \fi
    \fi
    \if###3##\else
        \startXMLelement{caption}%
            \startXMLelement{p}%
            #3%
            \endXMLelement{p}%
        \endXMLelement{caption}%
    \fi
}

\SaveMacroDefinition\@caption

\renewenvironment{figure}[1][]{%
    \let\center\@empty
    \let\endcenter\@empty
    \ifnum\@listdepth > 0
        \list@endpar
    \else
        \par
    \fi
    \everypar{}%
    \xmlpartag{}%
    \leavevmode
    \def\@currentreftype{fig}%
    \def\@captype{figure}%
    \def\jats@graphics@element{graphic}
    \startXMLelement{\jats@figure@element}%
    \addXMLid
}{%
    \endXMLelement{\jats@figure@element}%
    \par
    \ifnum\@listdepth > 0
        \global\afterfigureinlist@true
    \fi
}

\expandafter\let\csname figure*\endcsname\figure
\expandafter\let\csname endfigure*\endcsname\endfigure

\SaveEnvironmentDefinition{figure}
\SaveEnvironmentDefinition{figure*}

\renewenvironment{table}[1][]{%
    \let\center\@empty
    \let\endcenter\@empty
    \par
    \everypar{}%
    \xmlpartag{}%
    \leavevmode
    \def\@currentreftype{table}%
    \def\@captype{table}%
    \def\jats@graphics@element{graphic}
    \startXMLelement{\jats@figure@element}%
    \addXMLid
}{%
    \endXMLelement{\jats@figure@element}%
    \par
}

\expandafter\let\csname table*\endcsname\table
\expandafter\let\csname endtable*\endcsname\endtable

\SaveEnvironmentDefinition{table}
\SaveEnvironmentDefinition{table*}

\def\@tocwriteb#1#2#3{%
    \addcontentsline{toc}{#2}%
        {\protect#1{\csname#2name\endcsname}{\@secnumber}{#3}{\@currentXMLid}}%
}

%% The typical .toc file line is something like
%%
%%   \contentsline {chapter}{\tocchapter {Chapter}{I}{Elementary...}{ltxid3}}{1}
%%
%% where
%%
%%   \contentsline{chapter} -> \l@chapter -> \@tocline{0}{8pt plus1pt}{0pt}{}{}

\gdef\@currtoclevel{-1}

\def\@tocline#1#2#3#4#5#6#7{%
    \relax
    \ifnum #1>\c@tocdepth
        % OMIT
    \else
        \def\@toclevel{#1}%
        \par
        \begingroup 
            \disable@footnotes
             \xmlpartag{}%
             #6\relax
        \endgroup
    \fi
}

% \def\set@toc@entry#1#2#3#4{%
%     \leavevmode
%     \startXMLelement{a}%
%     \setXMLattribute{href}{###4}%
%     \ams@measure{#2}%
%     \if@ams@empty % Unnumbered section
%     \else
%         \ignorespaces#1 #2%
%         \begingroup
%             \ams@measure{#3}%
%             \if@ams@empty\else.\quad\fi
%         \endgroup
%     \fi
%     #3%
%     \endXMLelement{a}%
%     \par
% }

% #1 = section name (Chapter, section, etc.)
% #2 = label (I, 1, 2.3, etc.)
% #3 = title
% #4 = id

\def\set@toc@entry#1#2#3#4{%
    \leavevmode
    \ams@measure{#2}%
    \if@ams@empty
        % Unnumbered section
    \else
        \startXMLelement{label}%
        \ignorespaces#1 #2%
        \endXMLelement{label}%
    \fi
    \startXMLelement{title}%
    #3%
    \endXMLelement{title}%
    \startXMLelement{nav-pointer}%
    \setXMLattribute{rid}{#4}%
    \endXMLelement{nav-pointer}%
    \par
}

\providecommand{\setTrue}[1]{}

\def\@starttoc#1#2{%
    \@clear@sectionstack
    \begingroup
        \setTrue{#1}%
        \let\@secnumber\@empty % for \@tocwrite and \chaptermark
        \ifx\contentsname#2 \else
            \@tocwrite{chapter}{#2}%
        \fi
        \typeout{#2}%
        \startXMLelement{toc}%
        \addXMLid
        \par
        \startXMLelement{title-group}%
        \label{@starttoc:#1}%
        \startXMLelement{title}%
        {\xmlpartag{}#2\par}%
        \endXMLelement{title}%
        \endXMLelement{title-group}%
        \gdef\@currtoclevel{-1}%
        \makeatletter
        \@input{\jobname.#1}%
        \@clear@tocstack
        \endXMLelement{toc}%
        \if@filesw
            \@xp\newwrite\csname tf@#1\endcsname
            \immediate\@xp\openout\csname tf@#1\endcsname \jobname.#1\relax
        \fi
        \global\@nobreakfalse
    \endgroup
    \newpage
}

\renewcommand{\tocsection}[4]{%
    \ifnum\@toclevel=\@currtoclevel
        \endXMLelement{toc-entry}%
        \startXMLelement{toc-entry}%
    \else
        \ifnum\@toclevel>\@currtoclevel
            \startXMLelement{toc-entry}%
            \@push@tocstack{\@toclevel}%
        \else
            \@pop@tocstack{\@toclevel}%
            %\endXMLelement{toc-entry}%
            \startXMLelement{toc-entry}%
            \@push@tocstack{\@toclevel}%
        \fi
        \global\let\@currtoclevel\@toclevel
    \fi
    \set@toc@entry{#1}{#2}{#3}{#4}%
}

\let\tocpart\tocsection
\let\tocchapter\tocsection
\let\tocsubsection\tocsection
\let\tocsubsubsection\tocsection
\let\tocparagraph\tocsection
\let\tocsubparagraph\tocsection
\let\tocappendix\tocsection

\def\@seccntformat#1{%
    \csname the#1\endcsname
}

\renewenvironment{quotation}{%
    \par
    \everypar{}%
    \startXMLelement{disp-quote}%
    \setXMLattribute{content-type}{\@currenvir}%
}{%
    \par
    \endXMLelement{disp-quote}%
}

\let\quote\quotation
\let\endquote\endquotation

\renewenvironment{verse}{%
    \par
    \everypar{}%
    \def\\{\emptyXMLelement{break}}%
    \startXMLelement{verse-group}%
}{%
    \par
    \endXMLelement{verse-group}%
}

\newcommand{\attrib}[1]{%
    \par
    \begingroup
        %\def\\{; }%
        \def\\{\emptyXMLelement{break}}%
        \thisxmlpartag{attrib}#1\par
    \endgroup
}
\let\aufm\attrib

%% ??? The \ifvmode version can't have worked if there were multiple
%% paragraphs in the scope of the font command.

\def\startinlineXMLelement#1{%
    % \ifvmode
    %     \everypar{\startXMLelement{#1}}%
    % \else
        \leavevmode
        \startXMLelement{#1}%
    % \fi
}

\UCSchardef\textregistered"00AE
\UCSchardef\textservicemark"2120
\UCSchardef\texttrademark"2122

\TeXMLendClass

__END__
