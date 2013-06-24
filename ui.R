shinyUI(pageWithSidebar(

	# Application title
	headerPanel('Estimating psychometric functions'),

	# Sidebar
	sidebarPanel(
		h5('Experimental parameters'), 
		sliderInput("nPoints", 
			"Number of data points:", 
			min = 3, 
			max = 15, 
			value = 6), 
		sliderInput("nObs", 
			"Number of observations / data point:", 
			min = 10, 
			max = 200, 
			value = 50,
			step=5),
		sliderInput("xRange", 
			"Performance range in which data is sampled:", 
			min = 0.01, 
			max = 0.99, 
			value = c(0.25, 0.85), 
			step=0.01),
		sliderInput("criterion", 
			"Threshold criterion:", 
			min = 0.1, 
			max = 0.9, 
			value = 0.5, 
			step= 0.05),
	
		br(), 
		h5('Monte Carlo simulation'), 
		checkboxInput("estimateLambda", "Is the lapsing rate a free parameter?", FALSE), 
		sliderInput("nBoot", 
			"Number of generated data sets:", 
			min = 1, 
			max = 1000, 
			value = 1),
		helpText("Note: Increasing the number of generated data sets increases the computing time. "),
		# the function 'actionButton' is from the 'shinyIncubator' package
		actionButton('runAgain', 'Generate new data sample')
	),

	# Main Panel 
	mainPanel(
		tabsetPanel(
			tabPanel('Results', 
				plotOutput("plot"),
				br(), 
				p('The', HTML('<a href="http://en.wikipedia.org/wiki/Psychometric_function">psychometric function</a>'), " relates the strength of an external stimulus and the observer's responses. The aim in measuring a psychometric function is often to estimate a ", HTML('<a href="http://en.wikipedia.org/wiki/Psychophysics#Thresholds">threshold</a>'), ": the stimulus strength corresponding to a given level of performance. Here we illustrate how variable are the fitted curves and the estimated thresholds, given a set of experimental choices, such as the number of stimulus intensities at which performance is measured, their placement, the number of observations per data point, etc. See the 'Explanation' tab for a description of the data generation and fitting process. ")), 
			tabPanel('Explanation', 
				p(em('Simulate a data sample.'), "A given set of experimental choices determines a sampling scheme, i.e. stimulus intensities at which data will be collected. For each tested intensity, we sample random values from a binomial distribution with probabilities given by a --known-- underlying psychometric function (a cummulative gaussian distribution, displayed in red). The threshold is computed from the estimated psychometric function (displayed in gray), fitted to the simulated data points by maximum likelihood. Click on the button to generate a new sample from the same experimental choices. See how successive samples can give very different results, and how this changes with the experimental settings. "),
				p(em('Monte Carlo Simulation.'), "Increase the number of generated data sets. All data sets are from the same underlying true psychometric function, and share the same experimental parameters. This results in a ", em('distribution'), " of threshold estimates. Play with the various sampling and fitting parameters to see how they affect its shape and width."),  
				p(em('Is the lapsing rate a free parameter of the model?'), 'Observers are prone to ', em('lapses'), ", i.e. errors that are independent of the stimulus strength. Wichmann and Hill (2001a) have shown that a failure to take the laspe rate into account can seriously bias the parameter estimates. By checking the box, the lapsing rate is estimated from the data, according to the constrained maximum-likelihood method proposed by Wichmann and Hill (2001a). Check/uncheck to compare it's effect on a given (set of) data sample(s). Note that more elaborate methods have recently been proposed (see e.g. Fründ et al, 2011, Prins, 2012). "), 
				p(HTML(
					'Some further readings:
						<UL>
						<LI>Fründ, I., Haenel, N. V., & Wichmann, F. A. (2011). Inference for psychometric functions in the presence of nonstationary behavior. <i>Journal of Vision, 11(6)</i>, 1-19. <a href="http://dx.doi.org/10.1167/11.6.16" >doi:10.1167/11.6.16</a>.
						<LI>Klein, S. A. A. (2001). Measuring, estimating, and understanding the psychometric function: a commentary. <i>Perception & Psychophysics, 63(8)</i>, 1421–1455. <a href="http://dx.doi.org/10.3758/BF03194552">doi:10.3758/BF03194552</a>.
						<LI>Knoblauch, K., & Maloney, L. T. (2012). <i>Modeling Psychophysical Data in R.</i> New York: Springer-Verlag. <a href="http://dx.doi.org/10.1007/978-1-4614-4475-6">doi:10.1007/978-1-4614-4475-6</a>.
						<LI>Kuss, M., Jäkel, F., & Wichmann, F. A. (2005). Bayesian inference for psychometric functions. <i>Journal of Vision, 5(5)</i>, 478–492. <a href="http://dx.doi.org/10.1167/5.5.8">doi:10.1167/5.5.8</a>.
						<LI> Prins, N. (2012). The psychometric function: The lapse rate revisited. <i>Journal of Vision, 12(6)</i>, 1-16. <a href="http://dx.doi.org/10.1167/12.6.25">doi:10.1167/12.6.25</a>.
						<LI>Wichmann, F. A., & Hill, N. J. (2001a). The psychometric function: I. Fitting, sampling, and goodness of fit. <i>Perception & Psychophysics, 63(8)</i>, 1293–1313. <a href="http://dx.doi.org/10.3758/BF03194544">doi:10.3758/BF03194544</a>.
						<LI>Wichmann, F. A., & Hill, N. J. (2001b). The psychometric function: II. Bootstrap-based confidence intervals and sampling. <i>Perception & Psychophysics, 63(8)</i>, 1314–1329. <a href="http://dx.doi.org/10.3758/BF03194545">doi:10.3758/BF03194545</a>
						</UL>
					'))
				)
		)	
	)
))