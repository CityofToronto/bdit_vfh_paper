# TRB Paper

## Overview

This repo holds the Markdown source code for the TRB paper, and some utility
scripts.  It's heavily based off of Tom Pollard's [phd_thesis_markdown](
https://github.com/tompollard/phd_thesis_markdown) repo, and uses the [TRB latex
template](https://github.com/khaeru/trb-latex) from Paul Kishimoto.  The TRR
CSL is from [the styles repo](https://github.com/citation-style-language/styles/blob/master/transportation-research-record.csl)

### Companion Code

This paper references two repositories containing code used to process trip OD data into vehicle volumes:

1. [**bdit_triprouter:**](https://github.com/CityofToronto/bdit_triprouter) 
uses the PostgreSQL [pgRouting](http://pgrouting.org/) extension to route trip
Origins and Destinations on a street network using historic and modelled traffic
data. It was also used to generate a feasible set of Destination-Origin links 
with costs as an input to the next algorithm.
2. [**bdit_triplinker:**](https://github.com/CityofToronto/bdit_triplinker) uses
Python to link vehicle-for-hire trips together into driver work shifts.


## Installing Dependencies

On the EC2, LaTeX and Pandoc should already be installed and accessible to all
users.  Pandoc-crossref is available at `/usr/bin`, which should also be
accessible to all.

### LaTeX

The LaTeX template used requires a number of additional packages on top of the
base package.

#### For Ubuntu

The simplest way of getting LaTeX is through `texlive`:

```
sudo apt install texlive texlive-science texlive-formats-extra
```

### Pandoc

Pandoc binaries are available [here](https://pandoc.org/installing.html), with
Windows and Debian both supported.

### Pandoc-Crossref

The [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref) filter
handles cross-referencing in Markdown.  It's downloadable from its GitHub repo.

#### For Ubuntu

On Ubuntu systems, the easiest way to install pandoc-crossref is to download
the pre-built executable from the [releases page](https://github.com/lierdakil/pandoc-crossref/releases).
Remember to download the version compiled against your version of pandoc (
which you can find by typing `pandoc --version` on the command line).

Once downloaded, untar using:

```
tar -xzf linux-pandoc_X_X_X.tar.gz 
```

Now, move the `pandoc-crossref` executable to the folder of your choice.  Don't
forget to append your `PATH`:

```
PATH="$HOME/<your_bin_director>:$PATH"
```

### Why is `longtable_bugfix.sty` in the Main Directory?

`longtable_bugfix.sty` fixes a longstanding bug in `longtable` (Pandoc's use of
`longtable` [is hardcoded](https://groups.google.com/forum/#!topic/pandoc-discuss/znkTLPkekOg)).
LaTeX doesn't have an easy flag to (you need to specify an [environmental
variable](https://stackoverflow.com/questions/3936565/how-to-load-latex-sty-files-from-a-subdirectory)), and rather than randomly generating environmental variables i just put the
file in the same directory as the `.tex` file so it can be auto detected.

## Writing the Paper

The paper's source files are in `./source`, and spread out into sections.
They're written in a mix of Markdown and LaTeX (because it is impossible to
write the manuscript otherwise).  Only the title page is pure LaTeX, while
all other sections are Markdown with the option of writing LaTeX inline.

An example of how to write the paper is in `./source/pandoc_markdown_examples.md`.
Note that in-line citations to the bibliography are done with LaTeX commands
(because pandoc-crossref does not properly support them), but all other in-line
references are done using Pandoc's version of Markdown.

BibTeX references used to make the bibliography are stored in
`./source/references.bib`.  The fastest way to generate BibTeX entries for your
sources is to search the name and author of an article on Google Scholar, then
clicking the `Cite` button (the quotes) underneath the relevant entry, then
clicking the `BibTeX` link at the bottom of the Cite popup.  Alternatively,
you'll have to [create your own entry](https://nwalsh.com/tex/texhelp/bibtx-7.html).

Commands to build the example file as a paper are below.

## Building the Paper

### On Ubuntu

Use the Makefile to build the paper.  The file is based off of Tom Pollard's,
but drops support for `docx` and `html` formats.

```
make
```

or

```
make tex
```

generates the manuscript `.tex` file.

```
make pdf
```

both generates the manuscript `.tex` and compiles it as a PDF.

```
make exampletex
```

generates `pandoc_markdown_examples.tex` from the corresponding `.md` file, and

```
make examplepdf
```

additionally compiles it.

### On Windows

For Windows users, the raw Pandoc call to build the `.tex` is:

```
pandoc "<PATH_TO_SOURCE_DIRECTORY>"/0*.md \ 
-o "<OUTPUTNAME>.tex" \
--wrap=preserve \ 
--template="<PATH_TO_STYLE_DIRECTORY>/trb_bdit.tex" \
--include-before="<PATH_TO_SOURCE_DIRECTORY>/00-title.tex" \
-N \
--filter pandoc-crossref 2>pandoc.log \
```

To generate the PDF:

```
pdflatex <OUTPUTNAME>.tex
bibtex <OUTPUTNAME>
pdflatex <OUTPUTNAME>.tex
pdflatex <OUTPUTNAME>.tex
```

## Uploading the Paper to TRB

To have the paper build on TRB, first build the PDF locally. Then, make a copy
of the `.tex` manuscript.  Call it something like `<NAME>_final.tex`. In this
copy, replace the lines

```
\bibliographystyle{style/trb}
\bibliography{source/references}
```

with the entire contents of the `.bbl` file. This merges the bibliography and
manuscript together (technically the LaTeX system should be able to handle
`.bib` and `.bbl` files, but I never got it to work).

Next, in `<NAME>_final.tex`, remove all references to subfolders (eg.
`source/figures/fig1.pdf` should just be `fig1.pdf`).  Don't forget to change
`style/trbunofficial_bdit` to `trbunofficial_bdit` in the document class.

Next, gather together `<NAME>_final.tex`, `trbunofficial_bdit.cls`,
`longtable_bugfix.sty` and all figure files. Either upload them individually or
`tar` them then upload the `tar` file.

Finally, in the Attach Files page of the TRR submission system, change the file
order (left column) to the following:

1. Primary manuscript file (.tex)
2. Bibliography files
3. Optional style files
4. Nomenclature files
5. Figure files

For troubleshooting, see the [File Upload Options](https://www.editorialmanager.com/robohelp/16.0/index.htm#t=File_Upload_Options.htm)
on TRR's submission site, or the [Aries Systems web resources](https://www.ariessys.com/wp-content/uploads/EM_PM_LaTeX_Guide.pdf) (Aries is the submission platform provider of TRR).
