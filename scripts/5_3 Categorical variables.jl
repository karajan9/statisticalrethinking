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

# %% 5.48
@model function categ(sex, height)
    σ ~ Uniform(0, 50)
    a ~ filldist(Normal(178, 20), 2)
    μ = a[sex]
    height ~ MvNormal(μ, σ)
end

q5_8 = quap(categ(d.sex, d.height), NelderMead())
# precis

# %% 5.49
post = DataFrame(rand(q5_8.distr, 1000)', q5_8.params)
post.diff_fm = post[:, "a[1]"] .- post[:, "a[2]"]
precis(post)

# %% 5.50
d = CSV.read(datadir("exp_raw/milk.csv"), DataFrame; missingstring = "NA")
d.clade |> unique |> sort

# %% 5.51
# You can't just turn Strings into Integers in Julia but hashing them should give the same
# result
d.clade_id = Int.(indexin(d.clade, unique(d.clade)))

# %% 5.52
d.K = zscore(d.kcal_per_g)

@model function clade(clade_id, K)
    σ ~ Exponential(1)
    α ~ filldist(Normal(0, 0.5), length(unique(clade_id)))
    μ = α[clade_id]
    K ~ MvNormal(μ, σ)
end

q5_9 = quap(clade(d.clade_id, d.K))
post = DataFrame(rand(q5_9.distr, 1000)', q5_9.params)
precis(post)

# TODO: plot

# %%
mu = lin(post.a', d.A, post.bAM') |> meanlowerupper
resid = d.M .- mu.mean

scatter(d.A, d.M, legend = false)
plot!(d.A, mu.mean, ribbon = (mu.mean .- mu.lower, mu.upper .- mu.mean))
