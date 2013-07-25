# import the requested libraries 
# ------------------------------
# TODO if they are not available, install them? 
libs <- c('shiny', 'shinyIncubator', 'plyr', 'reshape2')
lapply(libs, require, character.only = TRUE)

# The psychometric function (function definitions)
# ------------------------------------------------
# A general form of the psychometric function is
# $\Psi(x;\alpha,\beta,\gamma,\lambda) = \gamma + (1 - \gamma - \lambda)F(x;\alpha,\beta)$
# where
# $F$ is a sigmoid function mapping the stimulus intensity $x$ to the range [0;1]. The cumulative distribution function of a distributional family (as the cummulative Gaussian) is typically used; 
# $\alpha$ and $\beta$ are the location parameters of $F$. In the case of a cummulative Gaussian, they correpond to its mean ($\mu$) and standard deviation ($\sigma$); and
# $\gamma$ and $\lambda$ adjust the range of $F$. $\gamma$ is the base rate of performance in the absence of signal. In the case when the participant is forced to choose between alternatives, $\gamma$ is the *guessing* rate. The psychometric function asymptotes at $1-\lambda$. $\lambda$ captures the rate at which observers *lapse*, responding incorrectly irrespective of the stimulus intensity. 

# psychometric function
# x are the stimulus intensities
# p is a vector of 4 paramaters: alpha, log(beta), lambda and gamma
# REM Note that we use exp(beta) in the function, to make sure that it is always positive.
# Here we use a cummulative Gaussian (pnorm) as sigmoid function. 
# the output is a vector of accurate response probabilities 
ppsy <- function(x, p) p[4] + (1- p[3] - p[4]) * pnorm(x, p[1], exp(p[2]))

# function to convert probabilities from the psychometric function 
# to the underlying cummulative distribution.
# Useful to compute a threshold
# prob is the response probability from $\Psi$ (in the range [gamma; 1-lambda])
# the output is a vector of corresponding probabilities on $F$ (in the range [0;1])
probaTrans <- function(prob, lambda, gamma) (prob-gamma) / (1-gamma-lambda)

# Quantile function (inverse of the psychometric function)
# prob is a vector of probabilities
# p is a vector of 4 paramaters: alpha, log(beta), gamma and lambda
# Here we use a cummulative Gaussian (qnorm) as sigmoid function. 
# the output is a vector of stimulus intensities
qpsy <- function(prob, p) qnorm(probaTrans(prob, p[3], p[4]), p[1], exp(p[2]))

# random generation from the psychometric function 
# We sample random values from a binomial distribution with probabilities given by the ---known--- underlying psychometric function. 
# x are the stimulus intensities
# p is a vector of 4 paramaters: alpha, log(beta), gamma and lambda
# nObs is the number of observations for each stimulus level x
rpsy <- function(x, p, nObs)
{
	prob <- ppsy(x, p)
	rbinom(prob, nObs, prob)
}


# Functions to generate the data and fit the psychometric function
# ----------------------------------------------------------------

# a function to generate a data set 
# x is a vector of stimulus intensities
# p is a vector of 4 paramaters: alpha, log(beta), gamma and lambda
# nObs is the number of observations for each stimulus level x
# the output is a 3 column matrix with the stimulus intensities (x), and the number of correct and incorrect responses (nYes and nNo)
data.gen <- function(x, p, nObs) 
{
		nYes <- rpsy(x, p, nObs) # simulated number of correct responses
		nNo <- nObs-nYes	# simulated number of incorrect responses
		cbind(x, nYes, nNo)
}

# define the likelihood function
# p is the parameters vector, in the order (alpha, log(beta), lambda, gamma)
# df is a 3-column matrix with the stimulus intensities (df[, 1]), and the number of correct and incorrect responses (df[, 2:3])
# opts is a list of options (set by the user of the shiny app)
likelihood <- function(p, df, opts) {	

	# do we estimate lambda? 
	if (opts$estimateLambda) {
		# if yes, we set gamma (the last parameter) to 0
		psi <- ppsy(df[, 1], c(p, 0))
	} else {
		# we set both gamma and lambda to 0
		psi <- ppsy(df[, 1], c(p, 0, 0))
	}

		
	# bayesian flat prior
	# implements the constraints put on lambda, according to Wichmann & Hill
	if (opts$estimateLambda && p[3] > 0.06) {
		-log(0)
	} else {
		# remove this part of the computation of the log likelihood, as it is constant:
		# lchoose(opts$nObs, df[,2])
		-sum(df[,2]*log(psi) + df[,3]*log(1-psi))
	}
}

# A function to fit the psychometric function 
# There are multiple ways to do it. Here we directly maximize the log likelihood. But see e.g. Knoblauch and Maloney (2012) for some R code examples on how to use glm with special link functions. 
# df is a 3-column matrix with the stimulus intensities (df[, 1]), and the number of correct and incorrect responses (df[, 2:3])
# opts is a list of options (set by the user of the shiny app)
fitPsy <- function(df, opts) 
{
	if(opts$estimateLambda){
		# estimating $\alpha$, $\beta$ and $\lambda$
		optim(c(1, log(3), 0.025), likelihood, df=df, opts=opts, 
			control=list(parscale=c(1, 1, 0.001)))
	} else {
		# estimating $\alpha$, $\beta$
		optim(c(1, log(3)), likelihood, df=df, opts=opts)
	}
}

# a function to extract the parameters of a psychometric function
# obj is an fitted object, the output of fitPsy
# opts is a list of options (set by the user of the shiny app)
getParam <- function(obj, opts) {
	if (opts$estimateLambda) {
		out <- c(obj$par, 0)
	} else {
		out <- c(obj$par, 0, 0)
	}
	names(out) <- c('alpha', 'log(beta)', 'lambda', 'gamma')
	return(out)
}
