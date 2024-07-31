#!/bin/bash

# Change to the docs directory
cd docs

# Run pdflatex on main.tex
pdflatex -output-directory=../generated main.tex

# Return to original directory
cd ..

echo "PDF generated in the 'generated' folder"
