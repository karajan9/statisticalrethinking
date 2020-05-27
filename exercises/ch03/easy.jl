using DrWatson
@quickactivate "StatReth"

# %%
using Plots
using StatsPlots
using StatsBase
using Distributions
using Turing  # for MCMCChains

# %%
n = 1_000
p_grid = range(0, 1, length = n)
prior = ones(n)
likelihood = @. pdf(Binomial(9, p_grid), 6)
posterior = likelihood .* prior
posterior ./= sum(posterior)

plot(p_grid, posterior)

# %%
ns = 10_000
weights = pweights(posterior)
samples = sample(p_grid, weights, ns)

density(samples)
plot!(p_grid, posterior * n)

# %%
mean(samples) do s
    s < 0.2
end

mean(samples) do s
    s > 0.8
end

mean(samples) do s
    0.2 < s < 0.8
end

quantile(samples, (0.2, 0.8))

chn = MCMCChains.Chains(reshape(samples, ns, 1, 1), ["no_water"])
hpd(chn; alpha = 0.66)

quantile(samples, ((1-0.66)/2, 1 - (1-0.66)/2))


mix = MixtureModel(Binomial.(9, samples))
rand(mix, 10_000) |> histogram
