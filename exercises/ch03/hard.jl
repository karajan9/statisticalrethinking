using DrWatson
@quickactivate "StatReth"

# %%
using Plots
using StatsPlots
using DataFrames
using StatsBase
using Distributions

# %%
data = DataFrame(
    birth1 = [1,0,0,0,1,1,0,1,0,1,0,0,1,1,0,1,1,0,0,0,1,0,0,0,1,0,
              0,0,0,1,1,1,0,1,0,1,1,1,0,1,0,1,1,0,1,0,0,1,1,0,1,0,0,0,0,0,0,0,
              1,1,0,1,0,0,1,0,0,0,1,0,0,1,1,1,1,0,1,0,1,1,1,1,1,0,0,1,0,1,1,0,
              1,0,1,1,1,0,1,1,1,1],
    birth2 = [0,1,0,1,0,1,1,1,0,0,1,1,1,1,1,0,0,1,1,1,0,0,1,1,1,0,
              1,1,1,0,1,1,1,0,1,0,0,1,1,1,1,0,0,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,
              1,1,1,0,1,1,0,1,1,0,1,1,1,0,0,0,0,0,0,1,0,0,0,1,1,0,0,1,0,0,1,1,
              0,0,0,1,1,1,0,0,0,0]
)

# %%
boys = sum(data.birth1) + sum(data.birth2)
all_births = length(data.birth1) + length(data.birth2)

p_grid = range(0, 1, length = 1000)
prior = ones(length(p_grid))
likelihood = @. pdf(Binomial(all_births, p_grid), boys)
posterior = likelihood .* prior
posterior ./= sum(posterior)
plot(p_grid, posterior)

p_grid[argmax(posterior)]

N = 10_000
samples = sample(p_grid, pweights(posterior), N)

# %%
plot(p_grid, posterior .* length(posterior))
density!(samples)

# %%
using Turing
chn = MCMCChains.Chains(reshape(samples, N, 1, 1), ["boys"])
hpd(chn; alpha = 0.5)
hpd(chn; alpha = 1-0.89)
hpd(chn; alpha = 1-0.97)

# %%
mix = MixtureModel(Binomial.(200, samples))
predpos_samples = rand(mix, 10_000)
density(predpos_samples)

# %%
mix = MixtureModel(Binomial.(100, samples))
predpos_samples = rand(mix, 10_000)
density(predpos_samples)
vline!([sum(data.birth1), sum(data.birth2)])

# %%
firstborn_girls = count(data.birth1 .== 0)
born_after_girls = data.birth2[data.birth1 .== 0]
boy_after_girl = count(born_after_girls .== 1)

mix = MixtureModel(Binomial.(firstborn_girls, samples))
predpos_samples = rand(mix, 10_000)
density(predpos_samples)
vline!([boy_after_girl])
