using DrWatson
@quickactivate "StatReth"

# %%
using DataFrames
using CSV
using Turing
using Plots

include(srcdir("quap.jl"))
include(srcdir("tools.jl"))

# %% 5.45
d = DataFrame!(CSV.File(datadir("exp_raw/Howell_1.csv")))

# %% 5.46
μ_female = rand(Normal(178, 20), 10_000)
μ_male = rand(Normal(178, 20), 10_000) .+ rand(Normal(0, 10), 10_000)
DataFrame((; μ_female, μ_male)) |> precis

# %% 5.47
d.sex = ifelse.(d.male .== 1, 2, 1)

# %%
@model function categ(sex, height)
    σ ~ Uniform(0, 50)
    a ~ filldist(Normal(178, 20), 2)
    μ = a[sex]
    height ~ MvNormal(μ, σ)
end

q5_8 = quap(categ(d.sex, d.height), NelderMead())
