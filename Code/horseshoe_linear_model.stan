data {
  int<lower=1> sample_size;
  int<lower=1> n_predictor;
  matrix[sample_size, n_predictor] X;
  real y[sample_size];
  real<lower=0> regularizing_slab_size; // For regularizing the shrinkage prior.
}

parameters {
  vector[n_predictor] beta_unit_scale;
  vector<lower=0>[n_predictor] lscale;
  real<lower=0> gscale;
  real intercept;
  real<lower=0> sigma_obs;
}

transformed parameters {
  vector[n_predictor] beta = beta_unit_scale .* lscale * gscale;
}

model {
  // Priors.
  lscale ~ cauchy(0, 1);
  target += log(1 / gscale);
  target += log(1 / sigma_obs);
  beta_unit_scale ~ normal(0, 1);
  target += - 0.5 * sum( 
    square(beta / regularizing_slab_size) 
  ); 
  
  // Likelihood.
  y ~ normal(intercept + X * beta, sigma_obs);
}
