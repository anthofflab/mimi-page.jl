# Installation Guide

This guide will briefly explain how to install Julia and Mimi-PAGE.

## Installing Julia

Mimi-PAGE requires the programming language [Julia](http://julialang.org/) to run. You can download the current release from the Julia [download page](http://julialang.org/downloads/). You should download and install the command line version from that page.

### Julia Editor Support

There are various editors around that have Julia support:

- [IJulia](https://github.com/JuliaLang/IJulia.jl) adds Julia support to the [jupyter](http://jupyter.org/) (formerly IPython) notebook system.
- [Juno](http://junolab.org/) adds Julia specific features to the [Atom](https://atom.io/) editor.
- [Sublime](https://www.sublimetext.com/), [VS Code](https://code.visualstudio.com/), [Emacs](https://www.gnu.org/software/emacs/) and many other editors all have Julia extensions that add various levels of support for the Julia language.

### A Note on Julia Versions

The current version of Mimi-PAGE works best with Julia 5.0. We are working on Julia 6.0 compatibility.

## Installing Mimi

Once Julia is installed, start Julia and you should see a Julia command prompt. To install the Mimi package, issue the following command:
```julia
julia> Pkg.add("Mimi")
```
You only have to run this command once on your machine.

For more information about the Mimi component framework, you can refer to the [Mimi](https://github.com/anthofflab/Mimi.jl) Github repository, which has a documentation andlinks to various models that are based on Mimi.

## Installing Mimi-PAGE

Clone or download the Mimi-PAGE repository from the Mimi-PAGE [Github website](https://github.com/anthofflab/mimi-page.jl).

## Using Mimi-PAGE

To run the model, run the `main_model` file in the src folder. This runs the deterministic version of Mimi-PAGE with central parameter estimates. The `getpage` function retrieves the model object. The model `m` returns a list of components and each of their incoming parameters and outgoing variables. Results can be called by running `m[:ComponentName, :VariableName]` for the desired component and variable.

To run the stochastic version of Mimi-PAGE, which uses parameter distributions, since the montecarlo.jl file in the src folder. The current Monte Carlo  process outputs a selection of variables that are important for validation. For more information, see the Technical Guide.

## Troubleshooting

To troubleshoot individual components, you can refer to the test directory, which has separate files that check each component.

For specific questions, you can send an email to [David Anthoff](http://www.david-anthoff.com/) (<anthoff@berkeley.edu>).