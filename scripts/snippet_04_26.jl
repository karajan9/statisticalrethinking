using DrWatson
@quickactivate "StatReth"

# %%
using CSV
using StatsBase
using Distributions
using DataFrames
using Turing

include(srcdir("quap.jl"))

# %% 4.26
d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
d2 = d[d.age .>= 18, :]

# %% 4.27 - 4.29
@model height(heights) = begin
    μ ~ Normal(178, 20)
    σ ~ Uniform(0, 50)
    heights .~ Normal(μ, σ)
end
m = height(d2.height)

m4_1 = quap(m)

# precis(m4_1)

# %% 4.30
start = [mean(Normal(178, 20)), mean(Uniform(0, 50))]
# currently broken https://github.com/TuringLang/Turing.jl/issues/1298
# m4_1 = quap(m, start)

# %% 4.31
@model height(heights) = begin
    μ ~ Normal(178, 0.1)
    σ ~ Uniform(0, 50)
    heights .~ Normal(μ, σ)
end
m = height(d2.height)
m4_2 = quap(m, NelderMead())
# precis(m4_2)

# %% 4.32, 4.33
m4_1.vcov

diag(m4_1.vcov)
cov2cor(Matrix(m4_1.vcov), sqrt.(diag(m4_1.vcov)))

# %% 4.34 - 4.36
post = rand(m4_1.distr, 10_000)
post = DataFrame(post', ["μ", "σ"])

precis(post)

post = rand(MvNormal(m4_1.coef, m4_1.vcov), 10_000)
post = DataFrame(post', ["μ", "σ"])
