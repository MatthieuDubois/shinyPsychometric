# shinyPsychometric

A shiny App to illustrate the variability in fitting psychometric functions and threshold estimates.

## The aim

Measuring the psychometric function is a classical method in [psychophysics](http://en.wikipedia.org/wiki/Psychophysics). The [psychometric function](http://en.wikipedia.org/wiki/Psychometric_function) relates the strength of an external stimulus and the observer's responses. The aim in measuring a psychometric function is often to estimate a [threshold](http://en.wikipedia.org/wiki/Psychophysics#Thresholds): the stimulus strength corresponding to a given level of performance. 

I wrote this shiny app to help my students (undergrads in Psychology) understand how experimental choices affect the variability of parameter estimates. It also serves as an introduction to the notion of curve fitting, optimization, Monte Carlo simulation and bootstrapping. 

## What the app does

The user defines a set of experimental choices, such as the number of data points, their placement, the number of observations per data point, and the threshold criterion. Given these choices, 

1. a data set is generated:  data is randomly sampled from a binomial distribution, with probabilities given by a known psychometric function;
2. a curve is fitted: A psychometric function is then fitted to the simulated data set by (constrained) maximum likelihood. The resulting threshold is estimated;
3. Monte Carlo simulation of the threshold estimate variability: It is possible to increase the number of generated data sets at step 1 (from 1 to 500). Step 2 is then done separately on each data set. This results in the display of the *distribution* of the threshold estimates. 

The user can then try different experimental scenarii and compare how they affect the variability of the threshold estimate. 

## To run the app

1. To run the app, you need [R](http://www.r-project.org), and some additional packages: `shiny`, `shinyIncubator`, `plyr` an `reshape2`. You can install most of them from the R console with the `install.packages()` command, e.g.:

    ```r
    install.packages(c('shiny', 'plyr', 'reshape2'))
    ```

    Things are a little bit different for `shinyIncubator`, which is still experimental and hosted at [github](https://github.com/rstudio/shiny-incubator). So you need the `devtools` package (install it if required with `install.packages('devtools')`), and run:

    ```r
    devtools::install_github("shiny-incubator", "rstudio")
    ```

2. Once you have the required packages, you can just run the app by
typing/pasting the following commands at the R prompt:

    ```r
    shiny::runGitHub('shinyPsychometric', 'MatthieuDubois')
    ```