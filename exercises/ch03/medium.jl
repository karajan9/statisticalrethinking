using DrWatson
@quickactivate "StatReth"

# %%
using Plots
using StatsBase
using Distributions
using StatsPlots

# %%
n = 1_000
p_grid = range(0, 1, length = n)
prior = ones(n)
# prior[p_grid .< 0.5] .= 0.0
likelihood = @. pdf(Binomial(15, p_grid), 8)
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
using Turing
chn = Chains(samples, ["waters"])
hpd(chn; alpha = 0.1)

mix = MixtureModel(Binomial.(15, samples))
predpos_samples = rand(mix, 10_000)
histogram(predpos_samples, normalize = :probability)
mean(predpos_samples) do s
    s == 8
end

mix = MixtureModel(Binomial.(9, samples))
predpos_samples = rand(mix, 10_000)
histogram(predpos_samples, normalize = :probability)
mean(predpos_samples) do s
    s == 6
end
