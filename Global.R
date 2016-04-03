#Global.R
# Load required libraries
library(ggplot2)
library(reshape2)
library(MASS)

# Define input (x) range
GP.prior.input <- data.frame(x = seq(-3, 3, 0.1))

f.init <- data.frame(x=NA,y=NA)

# Define Kernel function
GP.calc.sigma <- function(x, y, alpha = 1){
    # Create covariance matrix
    sigma <- data.frame(matrix(0, ncol = length(y), nrow = length(x)))
    
    # Calculate covariance values based on kernel equation
    for(i in 1:length(x)){
        for(j in 1:length(y)){
            sigma[i, j] <- exp(-alpha * .5 * (x[i] - y[j]) * (x[i] - y[j]))
        }
    }
    return(sigma)
}

Gen.prior <- function(alpha = 1) {
    # Set random number generator seed for reproducibility
    set.seed(121)
    # ****** Generate Prior Visualisation ******
    # Calculate the prior's covariance matrix
    GP.prior.K <- GP.calc.sigma(GP.prior.input$x, GP.prior.input$x, alpha)
    
    # Using mvrnorm
    GP.prior <- GP.prior.input
    
    for(i in 1:15){
        GP.prior.output <- mvrnorm(1, rep(0, nrow(GP.prior.input)), GP.prior.K)
        GP.prior[paste("f",i, sep = "")] <- GP.prior.output
    }
    
    # Shape data for visualisation
    GP.prior.vis <- melt(GP.prior, id="x")
    
    # Visualise GP prior
    g.prior <- ggplot(data = GP.prior.vis, aes(x = x, y = value))
    g.prior <- g.prior + geom_line(aes(group=variable), colour="grey80")
    g.prior <- g.prior + theme_bw() + xlab("x") + ylab("f(x)")
    g.prior <- g.prior + geom_line(data=data.frame(x = c(-3,3), y = c(0,0)),
                                   aes(x=x,y=y),
                                   colour="blue",
                                   size=1)
    
    return(g.prior)
}

Gen.posterior <- function(alpha = 1) {
    # Set random number generator seed for reproducibility
    set.seed(121)
    # ****** Generate Posterior Visualisation ******
    # Define training data frame

    if (nrow(f.init) > 1) {
        # Perform regression
        f <- f.init[complete.cases(f.init),]
        x <- f$x
        k.xx <- data.matrix(GP.calc.sigma(x,x,alpha))
        k.xxs <- data.matrix(GP.calc.sigma(x,GP.prior.input$x,alpha))
        k.xsx <- data.matrix(GP.calc.sigma(GP.prior.input$x,x,alpha))
        k.xsxs <- data.matrix(GP.calc.sigma(GP.prior.input$x,
                                            GP.prior.input$x,
                                            alpha))
        
        f.star.bar <- k.xsx %*% solve(k.xx) %*% f$y
        cov.f.star <- k.xsxs - k.xsx %*% solve(k.xx) %*% k.xxs
        
        # Using mvrnorm
        GP.posterior <- GP.prior.input
        
        for(i in 1:15){
            GP.posterior.output <- mvrnorm(1, f.star.bar, cov.f.star)
            GP.posterior[paste("f",i, sep = "")] <- GP.posterior.output
        }
        
        # Shape data for visualisation
        GP.posterior.vis <- melt(GP.posterior, id="x")
        
        # Visualise GP posterior
        g.post <- ggplot(data = GP.posterior.vis, aes(x = x, y = value))
        g.post <- g.post + geom_line(aes(group=variable), colour="grey80")
        g.post <- g.post + theme_bw() + xlab("x") + ylab("f(x)")
        g.post <- g.post + geom_line(data=data.frame(x = GP.posterior$x, y = f.star.bar),
                                     aes(x=x,y=y),
                                     colour="blue",
                                     size=1)
        g.post <- g.post + geom_point(data=f,aes(x=x,y=y))
        
        return(g.post)
    }
}