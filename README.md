# Functional-Data-Analysis


What is Functional Data Analysis (FDA)?

In standard data analysis, the data points are usually discrete and finite. FDA treats data as **continuous functions over time or space**. Instead of individual points, FDA models data as smooth curves/functions. For example, instead of looking at daily stock prices, FDA would model the entire price trajectory over time as a smooth function.

The advantage of it over standard data analysis is **capturing trends**. FDA inherently **smooths data** by fitting it into continuous functions, which helps in detecting long-term trends and underlying patterns while filtering out random noise. It is particularly **good for analyzing temperature, growth curves, or stock prices over time**.


# FDA on S&P 500 
In our project, we analyze S&P 500 volatility (measured as an absolute value of log returns) and explore the correlation between the index and related economic factors, such as interest rates, inflation, company stock movements, past stock price data, etc. 
We then use functional regression to create a model that predicts the S&P 500’s annualized volatility the next month. Volatility, in simple terms, refers to how much stock prices move up and down in that month.

<img width="516" alt="Screen Shot 2024-09-15 at 11 54 17 AM" src="https://github.com/user-attachments/assets/011f6e53-6cef-4844-94c3-04f9899b0078">

$\beta_0(X_i(t)) is a function that describes how one of the economic indicators changes over the month. This part of the equation smooths the data over time.
$\Z_i_j

# Why Do We Annualize Monthly Volatility?
Annualizing the volatility makes it easier to compare volatility across different months and periods. Volatility in one month might be high, but if we annualize it, we can compare it to the average annual volatility over multiple years or months, giving us a clearer picture of whether a particular month is unusually volatile.

# Results
The model performs well in general, it struggles slightly with extreme volatility predictions, as seen in the residuals. The errors are small enough to validate the model’s usefulness, but there’s room for improvement in predicting outlier events.
<img width="582" alt="Screen Shot 2024-09-15 at 11 58 28 AM" src="https://github.com/user-attachments/assets/a84fc57a-23b0-4d80-9679-c11edf4e9adf">
