using DrWatson
@quickactivate "StatReth"

# %%
using CSV
# using DataFrames
using StatsBase
using Distributions
using Plots
using StatsPlots
using Optim
using Turing

# include(srcdir("quap.jl"))

# %%
d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
d2 = filter(row -> row.age >= 18, d)
d2 = d[d.age .>= 18, :]

# %%
@model height(heights) = begin
    μ ~ Normal(178, 20)
    # σ ~ Uniform(0, 50)
    # heights .~ Normal(μ, σ)
    heights .~ Normal(μ, 5.0)
end

@model line(x, y) = begin
    #priors
    alpha ~ Normal(178.0, 100.0)
    beta ~ Normal(0.0, 10.0)
    s ~ Uniform(0, 50)

    #model
    mu = alpha .+ beta*x
    y .~ Normal.(mu, s)
end

m = height(d2.height)
m2 = line(d2.weight, d2.height)


# %%
sample(m, NUTS(0.65), 1000)


opt = optimize(m, MAP(), [178.0, 25.0])
coeftable(opt)
informationmatrix(opt)

using LinearAlgebra
function quap(model::Turing.Model, args...; kwargs...)
    opt = optimize(model, MAP(), args...; kwargs...)

    map = opt.values.array
    var_cov_matrix = informationmatrix(opt)
    sym_var_cov_matrix = Symmetric(var_cov_matrix)  # lest MvNormal complains, loudly
    converged = Optim.converged(opt.optim_result)

    distr = if length(map) == 1
        Normal(map[1], √sym_var_cov_matrix[1])  # Normal expects stddev
    else
        @show sym_var_cov_matrix
        MvNormal(map, sym_var_cov_matrix)       # MvNormal expects variance matrix
    end

    (coef = map, vcov = sym_var_cov_matrix, converged = converged, distr = distr)
end

r = quap(m)
r2 = quap(m2, Optim.NelderMead())

rand(MvNormal([0.0], [0.5]), 10000) |> histogram

rand(MvNormal([0.0], [0.5]), 10000)' |> histogram
rand(Normal(0.0, 0.5), 10000) |> histogram

MvNormal([0.0], [0.5])


I now also return a normal distribution to sample from since the 1D case had the `Normal(MAP[1], vcov[1])` pitfall which would incorrectly use the variance instead of the std dev.
