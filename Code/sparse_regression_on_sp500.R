setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load the S&P 500 weekly price data and prepare for analysis via Stan.

predictor_filename <- '../Data/sp500_components_weekly_price.csv'
outcome_filename <- '../Data/sp500_weekly_price.csv'

X <- as.matrix(
  read.csv(predictor_filename, row.names = 'date')
)
y <- c(as.matrix(
  read.csv(outcome_filename, row.names = 'date')
))
y <- log(y[-1]) - log(y[-length(y)])
X <- log(X[-1, ]) - log(X[-dim(X)[1], ])
  # Take the log-return.

# Preprocess and prepare the data for analysis.

standardize_predictors <- TRUE 
  # To standardize or not, that is the question.
scale_outcome <- TRUE
  # If true, scale the outcome so that its variance is 
  # comparable to the sum of the predictor variances.
  
if (standardize_predictors) {
  X <- scale(X, center = TRUE, scale = TRUE)
}
if (scale_outcome) {
  pred_var <- sapply(
    1:dim(X)[2], function (col_index) var(X[, col_index])
  )
  y <- sqrt(sum(pred_var)) / sd(y) * y
}

  
## Fit the regularized horseshoe model with Stan.
library(rstan)

hierarchical_parametrization <- TRUE
if (hierarchical_parametrization) {
  stancode_filename <- 'horseshoe_linear_model_hierarchical_parametrization.stan'
} else {
  stancode_filename <- 'horseshoe_linear_model.stan'
}

n_warmup <- 2000
n_sample <- 1000
save_stan_output <- TRUE
initial_state <- "random" # Convenient, but not the best approach.
params_to_save <- c('lp__', 'beta', 'lscale', 'gscale', 'sigma_obs')
stan_data <- list(
  y=y, X=X, 
  sample_size=length(y), 
  n_predictor=dim(X)[2],
  regularizing_slab_size=1.
)

stan_fit <- stan(
  stancode_filename, data = stan_data,
  warmup = n_warmup, 
  iter = n_warmup + n_sample, 
  init = initial_state, 
  chains = 3, cores = 3, seed = 1,
  control = list(
    adapt_delta = .95,
    adapt_init_buffer = 150,
    adapt_term_buffer = 100
  ),
  pars = params_to_save
)

if (hierarchical_parametrization) {
  stan_output_filename <- 'sp500_sparse_regression_stanfit_hierarchical_parametrization.rds'
} else {
  stan_output_filename <- 'sp500_sparse_regression_stanfit.rds'
}

if (save_stan_output) {
  saveRDS(stan_fit, file=stan_output_filename)
}

## Examine the output.
load_stan_output <- FALSE
if (load_stan_output) {
  stan_fit <- readRDS(stan_output_filename)
}

get_coef_name <- function (ticker_symbol) {
  col_index <- which(colnames(X) %in% ticker_symbol)
  coef_names <- sapply(
    col_index, function (index) sprintf('beta[%d]', index)
  )
  return(coef_names)
}
FAAMG_symbol <- c('MSFT', 'AAPL', 'AMZN', 'FB', 'GOOG', 'GOOGL')
FAAMG_coef_names <- get_coef_name(FAAMG_symbol)
small_cap_symbol <- c('GRMN', 'M', 'CPB', 'XRX', 'HRB')
small_cap_coef_names <- get_coef_name(small_cap_symbol)
plot(stan_fit, pars=c(FAAMG_coef_names, small_cap_coef_names))


print(stan_fit, pars=c(FAAMG_coef_names, small_cap_coef_names))
traceplot(stan_fit, pars=c(FAAMG_coef_names, small_cap_coef_names))
traceplot(stan_fit, pars='lp__')
traceplot(stan_fit, pars='gscale')

