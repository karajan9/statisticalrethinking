using DrWatson
@quickactivate "StatReth"

# %%
using DataFrames
using CSV
using Distributions
using Turing
using Plots
using StatsPlots
using Statistics

include(srcdir("quap.jl"))

# %% 4.64
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))

# %% 4.65, 6.66
d.weight_s = (d.weight .- mean(d.weight)) / std(d.weight)

f(weight_s, a, b1, b2) = a + b1 * weight_s + b2 * weight_s^2

@model function parabola(weight_s, heights)
    a ~ Normal(178, 20)
    b1 ~ LogNormal(0, 1)
    b2 ~ Normal(0, 1)
    σ ~ Uniform(0, 50)
    μ = f.(weight_s, a, b1, b2)
    heights ~ MvNormal(μ, σ)
end


Turing.VarInfo
m4_5 = quap(parabola(d.weight_s, d.height))

# precis(m4_5)

# %% 4.67
weight_seq = range(-2.2, 2, length = 30)
post = DataFrame(rand(m4_5.distr, 1_000)', ["a", "b1", "b2", "σ"])
normals = Normal.(postdf.a' .+ postdf.b' .* (weight_seq .- x̄), postdf.σ')
sim = rand.(normals)

sim_m = mean.(eachrow(sim))
sim_lower = quantile.(eachrow(sim), 0.055)
sim_upper = quantile.(eachrow(sim), 0.945)

scatter(d2.weight, d2.height, ms = 3, legend = false)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

rand(m4_5.distr, 1_000, 4)
