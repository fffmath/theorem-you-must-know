#!/usr/bin/env bash

# Usage: ./build.sh to build pdf and html outputs. ./build.sh clean to remove outputs.

# Assumes that you have programs installed including pdflatex, bibtex, htlatex, and ebook-convert from Calibre.

# If you change the name of your main TeX source file, change this variable to the new name.
MAINFILE=ebookbook
AUTHOR="Dominic Widdows" # Of course, you'll want to change this.

# This is the main build process, from running "./build.sh".
if [[ $# -eq 0 ]]
   then
       # This command makes sure that these images have correponding .xbb files to tell the htlatex / make4ht process how big to make them.
       extractbb -x images/*.png images/*.jpg
       
       pdflatex $MAINFILE
       bibtex $MAINFILE
       pdflatex $MAINFILE
       pdflatex $MAINFILE

       #htlatex $MAINFILE.tex "xhtml,fn-in" # ,graphics-"
       make4ht $MAINFILE.tex 
	
       ebook-convert $MAINFILE.html $MAINFILE.epub --cover images/cover.png --authors "$AUTHOR" --language English
       ebook-convert $MAINFILE.html $MAINFILE.mobi --cover images/cover.png --authors "$AUTHOR" --language English

# This is the build cleanup process, from running "./build.sh clean".
# It removes all the output files known to be generated by pdflatex and htlatex.	
elif [[ $# -eq 1 ]] && [[ $1 == "clean" ]]
    then
	for extension in 4ct 4tc aux bbl blg css dvi epub kpf html idv lg log mobi out pdf ps tmp toc xref; do \
	    for file in "$MAINFILE"*."$extension"; do \
		if [[ -f "$file" ]]; then
		    echo "Removing output file $file";
		    rm -f $file;
		fi
	    done;
	done
    echo "Removing autogenerated png and image bounding box (.xbb) files."
    rm -f "$MAINFILE"*x.png
    rm -f "$MAINFILE"-conversionLog.csv
    rm -f images/*.xbb
    
else
    echo Arguments not recognized: $@
    echo Usage: ./build.sh to build pdf, html, epub and mobi outputs.
    echo ./build.sh clean to remove outputs.
fi