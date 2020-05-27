using DrWatson
@quickactivate "StatReth"

# %%
using StatsBase
using Distributions
# using Plots
# using StatsPlots

# %% 3.20 - 3.23
pdf.(Binomial(2, 0.7), 0:2)

rand(Binomial(2, 0.7), 1)

rand(Binomial(2, 0.7), 10)

N = 10_000
dummy_w = rand(Binomial(2, 0.7), N)
counts(dummy_w) ./ N |> display   # either
countmap(dummy_w)                 # or, depending on what you want

# %% 3.24
dummy_w = rand(Binomial(9, 0.7), N)
histogram(dummy_w)

# %% 3.25
w = rand(Binomial(9, 0.7), N)


###################################################################



# %%
n = 1_000_000
p_grid = range(0, 1, length = n)
prob_p = ones(n)
prob_data = @. pdf(Binomial(9, p_grid), 6)
posterior = prob_data .* prob_p
posterior ./= sum(posterior)

plot(p_grid, posterior)

# %%
ns = 1_000_000
weights = pweights(posterior)
samples = sample(p_grid, weights, ns)

density(samples)
plot!(p_grid, posterior * n)

# %%
mix1 = MixtureModel(Binomial.(9, p_grid), posterior)
mix2 = MixtureModel(Binomial.(9, samples))

rand(mix, 1_000_000) |> histogram
rand(mix, 1_000_000) .+ 0.5 |> histogram!

# %%
@btime rand($mix2, 10000)


rand.(Binomial.(9, samples), 1)

[rand(Binomial(9, s), 1)[1] for s in samples] |> histogram




# %%
using Turing

k = 6
n = 9

# Define the model

@model globe_toss(n, k) = begin
  theta ~ Beta(1, 1) # prior
  k ~ Binomial(n, theta) # model
  return k, theta
end

# Use Turing mcmc

chns = sample(globe_toss(n, k), NUTS(0.65), 1000)

# Look at the proper draws (in corrected chn2)

describe(chns) |> display

# Show the hpd region
plot(chns)
