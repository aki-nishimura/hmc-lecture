data {
  int<lower=1> sample_size;
  int<lower=1> n_predictor;
  matrix[sample_size, n_predictor] X;
  real y[sample_size];
  real<lower=0> regularizing_slab_size; // For regularizing the shrinkage prior.
}

parameters {
  vector[n_predictor] beta;
  vector<lower=0>[n_predictor] lscale;
  real<lower=0> gscale;
  real intercept;
  real<lower=0> sigma_obs;
}

model {
  // Priors.
  lscale ~ cauchy(0, 1);
  target += log(1 / gscale);
  target += log(1 / sigma_obs);
  beta ~ normal(0, gscale * lscale);
  target += - 0.5 * sum( 
    square(beta / regularizing_slab_size) 
  ); 
  
  // Likelihood.
  y ~ normal(intercept + X * beta, sigma_obs);
}
