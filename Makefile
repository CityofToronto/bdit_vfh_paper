# Modified from https://github.com/tompollard/phd_thesis_markdown

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/source
STYLEDIR=$(BASEDIR)/style

# Change output name here.
OUTNAME=dumas_etal_2019

tex:
	pandoc "$(INPUTDIR)"/0*.md \
	-o "$(OUTNAME).tex" \
	--wrap=preserve \
	--template="$(STYLEDIR)/trb_bdit.tex" \
	--include-before="$(INPUTDIR)/00-title.tex" \
	-N \
	--filter pandoc-crossref 2>pandoc.log \
#	--bibliography="$(INPUTDIR)/references.bib" 2>pandoc.log \
#	-V classoption="numbered" \

exampletex:
	pandoc "$(INPUTDIR)"/pandoc_markdown_examples.md \
	-o "pandoc_markdown_examples.tex" \
	--wrap=preserve \
	--template="$(STYLEDIR)/trb_bdit.tex" \
	-N \
	--filter pandoc-crossref \
	--bibliography="$(INPUTDIR)/references.bib" 2>pandoc.log \

pdffromtex:
	pdflatex $(OUTNAME).tex
	bibtex $(OUTNAME).aux
	pdflatex $(OUTNAME).tex
	pdflatex $(OUTNAME).tex

examplepdf: exampletex
	pdflatex pandoc_markdown_examples.tex
	bibtex pandoc_markdown_examples.aux
	pdflatex pandoc_markdown_examples.tex
	pdflatex pandoc_markdown_examples.tex	

pdf: tex pdffromtex

.PHONY: help tex pdf
