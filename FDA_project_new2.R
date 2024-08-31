------------------------------------------------------------------------------------------------
# Fall'23 UIC MURL Project
# All work shown here is done by Anna Yelisseyeva
------------------------------------------------------------------------------------------------

  # This Project focuses on exploring the methods of Functional Data Analysis. 
  # Here it is applied to analyze the S&P 500 data over 20 years, and how it is affected by relevant economic predictors. 
  

##############################################################################################
## GPR Data
# War Threats (Category 1), Peace Threats (Category 2), Military Buildups (Category 3), Nuclear Threats (Category 4), Terror Threats (Category 5), Beginning of War (Category 6),
# Escalation of War (Category 7), Terror Acts (Category 8). Based on the search groups above, Caldara and Iacoviello also constructs two subindexes. 
# The Geopolitical Threats (GPRT) includes words belonging to categories 1 to 5 above. 
# The Geopolitical Acts (GPRA) index includes words belonging to categories 6 to 8.

setwd("/Users/annayelisseyeva//Desktop/school/stat research/RelevantData")

library(readxl)
gpr_data <- read_excel("data_gpr_daily_recent.xls")
gpr_data = gpr_data[gpr_data$date > "2009-12-31",]
gpr_data = gpr_data[gpr_data$date < "2022-12-31",]  

library(xts)

gpr_xts <- xts(gpr_data$GPRD_MA30, order.by = as.Date(gpr_data$date))
gpr_monthly <- to.monthly(gpr_xts, OHLC = FALSE)
gpr_monthly_vector <- coredata(gpr_monthly)

gpr_yearly <- to.yearly(gpr_xts, OHLC = FALSE)

gpr_yearly = as.matrix(gpr_yearly)
gpr_yearly = as.numeric(gpr_yearly)


plot(gpr_data$date, gpr_data$GPRD_MA30, type = "l", xlab = "Time", ylab = "GPR", main = "GPR Over Time (Monthly)")

##############################################################################################
# Federal Funds Effective Rate data
# The federal funds rate is the interest rate at which depository institutions trade federal funds

fedfund_data <- read.csv("FEDFUNDS.csv")
fedfund_data = fedfund_data[fedfund_data$DATE > "2009-12-31",]
fedfund_data = fedfund_data[fedfund_data$DATE < "2022-12-31",]

fedfund_data$DATE <- as.Date(fedfund_data$DATE)
fedfund_data <- xts(fedfund_data$FEDFUNDS, order.by = as.Date(fedfund_data$DATE))
fedfund_data <- to.yearly(fedfund_data, OHLC = FALSE)

fedfund_data = as.matrix(fedfund_data)
fedfund_data = as.numeric(fedfund_data)


#plot(fedfund_data$DATE, fedfund_data$FEDFUNDS, type = "l", xlab = "Time", ylab = "Percent", main = "Federal Fund Rate")


##############################################################################################
# Top SP500 holdings

library(tidyverse)


tickers <- c("AAPL", "MSFT", "AMZN", "NVDA")

for(ticker in tickers) {
  file_path = file.path("/Users/annayelisseyeva/Downloads", paste0(ticker, ".csv"))
  data <- read.csv(file_path)
  data = data[data$Date < "2023-01-01",]  
  data = data[data$Date > "2009-12-31",]  
  
  
  data <- data.frame(Date = data$Date, Price = data$Close)
  data$Price = as.numeric(data$Price) 
  data$Price = log(data$Price)  # to scale down 
  data$Date <- as.Date(data$Date)
  
  # get the year and month from the Date column
  data$Year <- format(data$Date, "%Y")
  data$Month <- format(data$Date, "%m")
  
  data <- data[-1]  # no longer need date column
  
  # yearly columns format
  data_wide <- data %>%
    pivot_wider(names_from = Year, values_from = Price)
  
  # store the data frame in the list with the ticker symbol as the name
  assign(paste0(ticker, "_yearly"), data_wide)
  
}



##############################################################################################
# SP500
library(xts)
sp500_data <-  read.csv("S&PINDEXYALE.csv", header = T)

sp500_data<- subset(sp500_data, select= c("X", "X.1"))
sp500_data = sp500_data[-c(1:7),]
colnames(sp500_data)<- c("Date", "Price")
sp500_data= sp500_data[sp500_data$Date > "2009.12", ]   # take the last month in 1999 to compute log return of Jan 2000
sp500_data$Price <- as.numeric(sp500_data$Price)


# taking the logarithm of the ratio of the closing price at each time point 
# to the closing price at the previous time point. 
log_returns_monthly <- diff(log(sp500_data$Price), lag=1)

start_date <- as.Date("2010-02-01")
end_date <- as.Date("2023-09-01")
new_dates <- seq(start_date, end_date, by = "months")

# Add the new date column to the log returns data
monthly_returns <- data.frame(Date = new_dates, LogReturns = log_returns_monthly)
monthly_returns2 <- data.frame(Date = new_dates, LogReturns = log_returns_monthly)


plot(y = monthly_returns$LogReturns, x = monthly_returns$Date, type = "l", 
     main = "S&P 500 Monthly Log Returns", xlab = "Date", ylab = "Log Returns")

#  months
monthly_returns$Year <- format(monthly_returns$Date, "%Y")
monthly_returns$Month <- format(monthly_returns$Date, "%m")

monthly_returns <- monthly_returns[-1]  # no longer need date column

# yearly columns format
monthly_returns <- monthly_returns %>%
  pivot_wider(names_from = Year, values_from = LogReturns)


monthly_returns2 = apply.yearly(monthly_returns2,sum)

##############################################################################################
library("fda")

par(mfrow = c(1,2))

# Create Fourier basis, smooth the data, and plot the functional data object
for (ticker in tickers) {
  basis.f <- create.fourier.basis(c(0, 12), 11, 12)
  
  # Load ticker-specific data
  ticker_data <- get(paste(ticker, "_yearly", sep = ""))  # Assumes the data is loaded in your environment
  
  #  the first column is "Month"
  data_matrix <- as.matrix(ticker_data[, -1])
  
  fd <- smooth.basis(ticker_data$Month, data_matrix, basis.f)$fd
  
  assign(paste0(ticker, "_fd"), fd)
  
  plot(fd, xlab = "Month", ylab = "Closing Price", main = paste(ticker, "Yearly Prices"))
}


##################################################################################
# VAR COVARIANCE

monnths <- seq(1, 12, length.out = 13)

str(nvdavarbifd <- var.fd(NVDA_fd))
str(nvda_varmar <- eval.bifd(monnths,monnths,nvdavarbifd))
var.fd(NVDA_fd)
persp(monnths, monnths, nvda_varmar,
      xlab="Months", ylab="Months", zlab="Covariance")



##################################################################################
# FPCA
par(mfrow= c(2,2))

fpca_result <- pca.fd(AAPL_fd, nharm = 5) 
plot(fpca_result, xlab = "Months")


fpca_result <- pca.fd(MSFT_fd, nharm = 5) 
plot(fpca_result, xlab = "Months")


##################################################################################
# FUNCTIONAL REGRESSION


# COEFFICIENTS
constbasis = create.constant.basis(c(0,12))
betafd1    <- fd(0, constbasis)
betafdPar1 <- fdPar(betafd1, 2, 1e-5) # order of peanlty, penalty coefficient

betabasis =  create.fourier.basis(c(0,12), 11, 12)
betafdPar2  <- fdPar(betabasis, 2, 1e3)


Lcoef = c(0,(2*pi/12)^2,0)
harmaccelLfd = vec2Lfd(Lcoef, c(0,12))
lambda = 10^12.5
betafdPar = fdPar(betabasis, harmaccelLfd, lambda)


##### RESPONSE
returns = coredata(monthly_returns2)
returns = as.matrix(returns)
returns_prev = returns[-nrow(returns)]
returns_prev = as.numeric(returns_prev)

returns_next = as.matrix(returns)
returns_next = returns_next[-1,]
returns_next = as.numeric(returns_next)

betalist <- list(const=betafdPar1, AAPL_fd=betafdPar2, MSFT_fd=betafdPar2, AMZN_fd=betafdPar2, NVDA_fd = betafdPar2, 
                 gpr_yearly=betafdPar1,
                 fedfund_data=betafdPar1,
                 returns_prev =betafdPar1
)

predictor_list <- list(const=rep(1, 13), AAPL_fd=AAPL_fd, MSFT_fd=MSFT_fd, AMZN_fd = AMZN_fd, NVDA_fd= NVDA_fd,
                       gpr_yearly=gpr_yearly,
                       fedfund_data=fedfund_data, 
                       returns_prev = returns_prev)


#betalist <- list( AAPL_fd=betafdPar2, MSFT_fd=betafdPar2, AMZN_fd=betafdPar2)
#predictor_list <- list( AAPL_fd=AAPL_fd, MSFT_fd=MSFT_fd, AMZN_fd = AMZN_fd)
library("MASS")

c <- abs(min(returns_next)) + 1  # make positive
transformed_data <- ((returns_next + c)^(0.5) - 1) / 0.5 # lambda = 0.5


fRegressList = fRegress(transformed_data, predictor_list, betalist)


##################################################################################
# TESTING

# Plot y vs y hat
#annualreturn.fit1<-fRegressList$yhatfdobj

plot(fRegressList$yhatfdobj, transformed_data,  type="p", pch="o")
lines(fRegressList$yhatfdobj, fRegressList$yhatfdobj, lty=2)

SSE <- sum((returns_next-fRegressList$yhatfdobj)^2)
SSR <- sum((returns_next-mean(fRegressList$yhatfdobj))^2)
SST <- SSR + SSE
R2 <- SSR/SST 

### F TEST
# MSR / MSE
# is the explained variance significantly larger than the unexplained variance
F = (SSR/(8-1)) / (SSE/ (23 - 8 -1)) # 9.440752


F.res = Fperm.fd(transformed_data, predictor_list, betalist)

#plot(fRegressList$betaestlist[[1]])

residuals_fd <- fRegressList$yfdobj - fRegressList$yhatfdobj

# Errors
plot(residuals_fd, xlab = "Time", ylab = "Residuals", main = "Functional Regression Residuals")

# Error vs y hat
plot(fRegressList$yhatfdobj, residuals_fd,  xlab = "Predicted Values (y-hat)",  ylab = "Residuals", main = "Errors vs Predicted Values")

abline(h = 0, col = "red", lty = 2)



