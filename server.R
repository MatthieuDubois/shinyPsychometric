# TODO comment the code

# Define the server logic
shinyServer(function(input, output) 
{

	# parameters of the psychometric function used in this simulation
	# Rem: in the functions that define the psychometric function, we use exp(beta), instead of beta, to force beta to be non negative in the fitting procedure. so here we define beta as log(beta)
	p <- c(0, log(1), 0.01, 0)
	names(p) <- c('alpha', 'logbeta', 'lambda', 'gamma')

	# generate the sampling scheme
	xr <- reactive({	
		# obtain the quantiles corresponding to range of expected answer probabilities
		xRange <- qpsy(input$xRange, p)
		seq(xRange[1], xRange[2], length=input$nPoints) # stimulus intensities used in the computations
	}) 

	# generate the data
	getData <- reactive({
		# take dependance of the action button
		input$runAgain

		llply(1:input$nBoot, function(i) data.gen(xr(), p, input$nObs))
	})

	# fit the curve
	modelFit <- reactive({
		laply(getData(), function(df) getParam(fitPsy(df, opts=input), opts=input), .drop=FALSE)
	})

	# get the threshold
	computeTheta <- reactive({
		aaply(modelFit(), 1, function(v) qpsy(input$criterion, v), .drop=FALSE)
	})

	# generate the curves for plotting
	bootPred <- reactive({
		# TODO adjust all these functions
		results <- modelFit()
			
		# generate a vector of stimulus intensities
		x <- seq(qnorm(0.01, p[1], exp(p[2])), qnorm(0.99, p[1], exp(p[2])), length=101)
		# generate an array of predicted probabilities, given x and the bootstrapped parameter estimates
		bootSamples <- aaply(results, 1, function(v) ppsy(x,v), .drop=FALSE, .parallel=FALSE)
		dimnames(bootSamples) <- list(iteration=1:input$nBoot, x=x)
		#reshape2::melt(bootSamples)
		t(bootSamples)

	})

	# generate the plot
	output$plot <- renderPlot({

		aa <- bootPred()
		x <- as.numeric(dimnames(aa)[[1]])

		theta <- qpsy(input$criterion, p)
		samp <- xr()


		# define the plotting parameters
		# ------------------------------
		opar <- par(
			bty = 'n',
			mgp=c(2, 0.75, 0))
		colLines <- 'grey50' 	# color for line annotations
		colTxt <- 'grey30'		# color for text annotations
		colTheta <- 'red'
		alpha <- min(0.5, 20/input$nBoot)	# alpha, as a function of the number of bootSamples

		# define the layout
		layout(matrix(1:2, ncol=1, nrow=2), heights=c(2, 1))
		# layout.show(2)

		# First plot
		# ----------
		par(mar=c(0, 3, 0, 0))
		# plot the simulated lines
		matplot(x, aa, type='l', 
			lty=1, col=rgb(0,0,0,alpha), 
			xlim = range(x),
			ylim = c(0,1.1), 
			main=NULL, xlab='', ylab='performance', 
			axes=FALSE) 
		# add the generative function
		curve(ppsy(x, p), col=colTheta, lwd=ifelse(input$nBoot>10, 2, 1), add=TRUE)	
		# add the threshold
		abline(h = input$criterion, col=colLines, lty=3)
		segments(theta, input$criterion, theta, -2, col=colTheta, lty=2)
		# add annotations
		text(x = max(x), y = input$criterion, labels=c('threshold\ncriterion'), adj=c(1, 1.2), col=colTxt)
		text(x = theta, y = 0, labels=c('real threshold'), adj=c(-0.1, 0.5), col=colTheta)
		
		if (input$nBoot==1) {
			# show the real points
			dd <- getData()[[1]]
			points(dd[,'x'], dd[,'nYes']/(dd[,'nYes']+dd[, 'nNo']), pch = 19 )
			
		} else {
			# add the sampling scheme
			points(samp, y=rep(1.075, length(samp)), pch=16, col=colLines)
			segments(min(samp), 1.075, max(samp), 1.075, col=colLines)
			text(min(samp), 1.075, labels='sampling scheme', adj=c(0.01, -0.7), col=colTxt)	
		}
		
		# add left axis
		axis(2)

		# add legend
		legend('topleft', inset=c(0.025, 0),
			legend=c('original', 'fitted'),
			col=c(colTheta, rgb(0,0,0,alpha)) , lty=1,
			title='Psychometric functions', 
			bty='n')

		# second plot
		# -----------
		thetaHat <- computeTheta()
		thetaHist <- hist(thetaHat, breaks=pretty(x, n = 100), plot=FALSE)
		if (input$nBoot > 1) {
			thetaDens <- density(thetaHat)
			yRange <-  c(0, max(c(thetaHist$density, thetaDens$y)))
		} else {
			yRange <- c(0, max(thetaHist$density))
		}
		

		par(mar=c(3, 3, 0, 0))
		# plot the histogram
		plot(thetaHist, freq=FALSE, 
			col='grey80', border='grey70',
			main=NULL, 	xlab='stimulus intensity (arbitrary unit)', ylab=NULL, 
			xlim=range(x), ylim=1.1*yRange, 
			axes=FALSE)
		# add the density (if there are more than one generated data set)
		if (input$nBoot > 1)
		{
			lines(thetaDens$x, thetaDens$y, col=colLines)
			# add annotations
			text(min(thetaDens$x), 0, label='distribution\nof threshold estimates', col=colTxt, adj=c(1.05, -0.2))
		} else {
			text(min(thetaHat), 0, label='threshold estimate', col=colTxt, adj=c(1.1, -0.3))
		}
		# add the threshold
		abline(v=theta, col=colTheta, lty=2)
		# add bottom axis
		axis(1)

		par(opar)
	})
})