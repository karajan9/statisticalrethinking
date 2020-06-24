using DrWatson
@quickactivate "StatReth"

# %%
using DataFrames
using CSV
using Turing
using Plots
# using StatsPlots
# using Statistics
using StatsBase

include(srcdir("quap.jl"))
include(srcdir("tools.jl"))

# %% 5.1, 5.2
d = DataFrame(CSV.File(datadir("exp_raw/WaffleDivorce.csv")))
d.D = zscore(d.Divorce)
d.M = zscore(d.Marriage)
d.A = zscore(d.MedianAgeMarriage)

std(d.MedianAgeMarriage)

# %% 5.3
lin_divorce_A(A, a, bA) = a .+ bA .* A
@model function divorce_A(A, D)
    a ~ Normal(0, 0.2)
    bA ~ Normal(0, 0.5)
    σ ~ Exponential(1)
    μ = lin_divorce_A(A, a, bA)
    D ~ MvNormal(μ, σ)
end

m5_1 = divorce_A(d.A, d.D)
prior = sample(m5_1, Prior(), 50) |> DataFrame

# %% 5.4
x = -2:0.1:2
plot()
for r in eachrow(prior)
    p = lin_divorce_A(x, r.a, r.bA)
    plot!(x, p, color = :black, alpha = 0.4)
end
plot!(legend = false)

# %% 5.5
q5_1 = quap(m5_1)
post = DataFrame(rand(q5_1.distr, 1000)', ["a", "bA", "σ"])

A_seq = range(-3, 3.2, length = 30)
mu = lin_divorce_A(A_seq, post.a', post.bA')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

scatter(d.A, d.D, alpha = 0.4, legend = false)
plot!(A_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))

# %% 5.6
lin_divorce_M(M, a, bM) = a .+ bM .* M
@model function divorce_M(M, D)
    a ~ Normal(0, 0.2)
    bM ~ Normal(0, 0.5)
    σ ~ Exponential(1)
    μ = lin_divorce_M(M, a, bM)
    D ~ MvNormal(μ, σ)
end

q5_1 = quap(divorce_M(d.M, d.D))
post = DataFrame(rand(q5_1.distr, 1000)', ["a", "bM", "σ"])

M_seq = range(-3, 3.2, length = 30)
mu = lin_divorce_M(M_seq, post.a', post.bM')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

scatter(d.M, d.D, alpha = 0.4, legend = false)
plot!(M_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))

# %% 5.7 - 5.9
missing  # TODO

# %% 5.10
lin_divorce_AM(A, M, a, bA, bM) = a .+ bA .* A .+ bM .* M
@model function divorce_AM(A, M, D)
    a ~ Normal(0, 0.2)
    bM ~ Normal(0, 0.5)
    bA ~ Normal(0, 0.5)
    σ ~ Exponential(1)
    μ = lin_divorce_AM(A, M, a, bA, bM)
    D ~ MvNormal(μ, σ)
end

m5_3 = divorce_AM(d.A, d.M, d.D)
q5_3 = quap(m5_3)




# %%

q5_3 = quap(m5_3)
post = DataFrame(rand(q5_3.distr, 1000)', ["a", "bM", "bA", "σ"])

M_seq = range(-3, 3.2, length = 30)
mu = lin_divorce_M(M_seq, post.a', post.bM')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

scatter(d.M, d.D, alpha = 0.4, legend = false)
plot!(M_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
