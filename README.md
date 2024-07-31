# FPGA Example Design Project

This repository contains the source code for our FPGA example design project.

## Compiling the Documentation

To compile the LaTeX documentation into a PDF:

1. Ensure you have the necessary tools installed (see "Required Tools" section below).
2. Open a terminal and navigate to the project's root directory.
3. Run the following command:

   ```
   ./scripts/mkdoc.bash
   ```

4. The generated PDF will be available in the 'generated' folder.

## Required Tools

To compile the documentation, you need the following tool accessible from the command line:

- pdflatex (part of a LaTeX distribution like TeX Live)

To check if pdflatex is installed, run:

```
pdflatex --version
```

If it's not installed, you can install it on Ubuntu with:

```
sudo apt install texlive-base
```

Or on macOS using MacTeX or BasicTeX.

