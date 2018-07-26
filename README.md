# Plural
Plural language interpreter

This is the beginnings of a Plural interpreter.  It is very basic, still only a toy, mostly incomplete, primitive, buggy, but should work with some very simple examples.

This implementation of Plural is not fast, rather it's a testbed for experiments in lexical analysis, parsing, language syntax, and data structures.  Plural is written in D in an easy and simplistic style, and can be easily ported to languages such as Java or C#.

Plural currently uses the Pratt parser, which is very easy to use and is very well suited to "expression" languages.  More info can be found in http://effbot.org/zone/simple-top-down-parsing.htm.  A PDF copy of this article is in lundh.pdf.  A far cry from YACC (which was outstanding for its time) from years ago.  Lexical analysis is also simplistic and suboptimal.
