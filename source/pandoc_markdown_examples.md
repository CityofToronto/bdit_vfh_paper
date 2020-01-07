# Pandoc Markdown Examples

Pandoc using pandoc crossref is a simplified but imperfect means of producing
\LaTeX manuscripts.  For an exhaustive list of commands and customization of
Pandoc, see [their site](https://pandoc.org/MANUAL.html).  For using and
customizing pandoc crossref, see [its site](https://lierdakil.github.io/pandoc-crossref/)

We can also write \LaTeX command directly into the Markdown files: `\LaTeX`
itself is one such command!

## Here's a subsection

Headings get automatic labels, which can be used for citations (see Sec. [-@sec:refcite]).

### Here's a subsubsection with a manual label {#sec:mylabel}

We're using pandoc crossref (rather than vanilla Pandoc) to do our cross
referencing, since crossref produces valid \LaTeX reference commands (except
for citations, which we'll discuss below).  Crossref requires that:

- Section labels start with `sec:`, eg. `sec:mylabel`
- Equation labels start with `eq:`
- Figure labels start with `fig:`
- Table labels start with `tbl:`

### Let's try some syntax

Here's a [hyperlink](www.toronto.ca).  How about some *italics* or **bold**?
~~Here's some deleted text.~~

(@)  Here's a
(@)  numbered list

\noindent which can be

(@)  extended.

and

1. Here's a
2. numbered
3. list

\noindent which

1. cannot

Meanwhile, here's

- a
- bulleted
- list

## Math

Here's some math (with a pan)

$$ y = mx + b $$ {#eq:myline}

\noindent Alternatively, we can write raw \LaTeX :

$$ \partial_t\rho + \partial_j(\rho u^j) = 0 $$ {#eq:continuityeqn}

Here's some inline math $3x + 4 = 5$.

I have no idea how to add an equation array using dollar signs, so just write
literal \LaTeX :

\begin{eqnarray}
y = ax^2 + bx + c \\
ds^2 = c dt^2 - d\vec{x}^2
\label{eq:somenonsense}
\end{eqnarray}

## Figures

<!-- Based off of 12_chapter_4.md from https://github.com/tompollard/phd_thesis_markdown
For more information and options, see https://pandoc.org/MANUAL.html#images
 -->

Figure [-@fig:citywide_vfh] shows how to add a figure.

![Citywide growth rate of monthly average TNC trips per day from September 2017
to May 2019. \label{fig:citywide_vfh}](source/figures/citywide_vfh_trip_growth.png){ width=100% }

## Adding Tables

Here's a table, Table [-@tbl:awesometable]

  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1

: What a great table {#tbl:awesometable}

## References {#sec:refcite}

You can also reference sections, either directly (eg. Sec. \ref{sec:mylabel})
or through pandoc crossref syntax (eg. Sec. [-@sec:mylabel]; the `-` is to
prevent crossref from appending an unnecessary `sec.` in front of the reference.
The end result is identical in \LaTeX .  You can do this with equations,
tables, etc.

Note that using Pandoc's default reference system (eg. [Section 1](@sec:mylabel)),
leads to *incorrect* reference labels!

## Citations

Sadly pandoc crossref does a bad job of handling in-line citations -
`[@henao2018impact]` reproduces a citation in plain text, rather than
`\cite{henao2018impact}`.  Moreover, the `trbunofficial_bdit` style defines
`\trbcite` for in-line citation consistent with TRB requrements.

Therefore, to cite a reference, use \trbcite{henao2018impact} to print out
author and year, and \cite{vazifeh2018addressing} for only the reference number.
