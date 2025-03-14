# Install necessary packages  
install.packages("gridExtra")  
install.packages("MSGARCH")  
install.packages("GAS")  

# Load required libraries  
library(ggplot2)  
library(MSGARCH)  
library(gridExtra)  

# Data preparation: Extract numeric values from vector_output  
numeric_values <- as.vector(as.matrix(vector_output))[4500:(4500 + 2499)]  
print(numeric_values)  

# Create time index for plotting  
time_index <- seq.Date(from = as.Date("2014-04-24"), to = as.Date("2022-04-05"), length.out = 2500)  

# Plot time series of stock market log-returns  
plot(  
  time_index,  
  numeric_values,  
  type = "l",  
  col = "black",  
  lwd = 0.8,  
  main = "Taiwan Stock Market Index log-returns (%)",  
  xlab = "Date (year)",  
  ylab = ""  
)  

# Define and fit the Markov-switching GJR-GARCH model  
ms2.gjr.s <- CreateSpec(  
  variance.spec = list(model = c("gjrGARCH")),  
  distribution.spec = list(distribution = c("std")),  
  switch.spec = list(K = 2),  
  constraint.spec = list(regime.const = "nu")  
)  

fit.ml <- FitML(ms2.gjr.s, data = numeric_values)  
summary(fit.ml)  

# Compute annualized volatility  
vol <- sqrt(250) * Volatility(fit.ml)  

# Extract state probabilities  
set.seed(1234)  
sqrt(250) * sapply(ExtractStateFit(fit.ml), UncVol)  

smooth.prob <- State(fit.ml)$SmoothProb[, 1, 2, drop = TRUE]  
smooth.prob <- smooth.prob[1:length(vol)]  

# Prepare data for visualization  
data <- data.frame(  
  Time = time_index,  
  SmoothedProbRegime2 = smooth.prob,  
  Volatility = vol  
)  

# Plot smoothed probabilities and volatility  
p1 <- ggplot(data, aes(x = Time, y = SmoothedProbRegime2)) +  
  geom_line(color = "black") +  
  labs(title = "Estimated Smoothed Probabilities", x = "Time", y = "Smoothed Probability") +  
  theme_minimal()  

p2 <- ggplot(data, aes(x = Time, y = Volatility)) +  
  geom_line(color = "blue") +  
  labs(title = "Filtered Conditional Volatilities", x = "Time", y = "Volatility") +  
  theme_minimal()  

# Combine the two plots  
grid.arrange(p1, p2, nrow = 2)  