using DrWatson
@quickactivate "StatReth"

# %%
using DataFrames
using CSV
using Distributions
using Turing
using Plots
# using StatsPlots
using Statistics

include(srcdir("quap.jl"))

# %% 4.64
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))

# %% 4.65, 6.66
d.weight_s = (d.weight .- mean(d.weight)) / std(d.weight)

f_parabola(weight_s, a, b1, b2) = a + b1 * weight_s + b2 * weight_s^2

@model function parabola(weight_s, heights)
    a ~ Normal(178, 20)
    b1 ~ LogNormal(0, 1)
    b2 ~ Normal(0, 1)
    σ ~ Uniform(0, 50)
    μ = f_parabola.(weight_s, a, b1, b2)
    heights ~ MvNormal(μ, σ)
end

m4_5 = quap(parabola(d.weight_s, d.height), NelderMead())

# precis(m4_5)

# %% 4.67
weight_seq = range(-2.2, 2, length = 30)
post = DataFrame(rand(m4_5.distr, 1_000)', ["a", "b1", "b2", "σ"])
mu = f_parabola.(weight_seq, post.a', post.b1', post.b2')
sim = rand.(Normal.(mu, post.σ'))

mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)
sim_m = mean.(eachrow(sim))
sim_lower = quantile.(eachrow(sim), 0.055)
sim_upper = quantile.(eachrow(sim), 0.945)

# %% 4.68
scatter(d.weight_s, d.height, ms = 3, alpha = 0.7, legend = false)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %% 4.69
f_cube(weight_s, a, b1, b2, b3) = a + b1 * weight_s + b2 * weight_s^2 + b3 * weight_s^3

@model function cube(weight_s, heights)
    a ~ Normal(178, 20)
    b1 ~ LogNormal(0, 1)
    b2 ~ Normal(0, 10)
    b3 ~ Normal(0, 10)
    σ ~ Uniform(0, 50)
    μ = f_cube.(weight_s, a, b1, b2, b3)
    heights ~ MvNormal(μ, σ)
end

m4_6 = quap(cube(d.weight_s, d.height), NelderMead())

# %% 4.70, 4.71
weight_seq = range(-2.2, 2, length = 30)
post = DataFrame(rand(m4_6.distr, 1_000)', ["a", "b1", "b2", "b3", "σ"])
mu = f_cube.(weight_seq, post.a', post.b1', post.b2', post.b3')
sim = rand.(Normal.(mu, post.σ'))

mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)
sim_m = mean.(eachrow(sim))
sim_lower = quantile.(eachrow(sim), 0.055)
sim_upper = quantile.(eachrow(sim), 0.945)

weight_seq_rescaled = weight_seq .* std(d.weight) .+ mean(d.weight)
scatter(d.weight, d.height, ms = 3, alpha = 0.7, legend = false)
plot!(weight_seq_rescaled, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq_rescaled, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %% 4.72
d = DataFrame(CSV.File(datadir("exp_raw/cherry_blossoms.csv"), missingstring = "NA"))

precis(d)

scatter(d.year, d.doy)

# %%
