using DrWatson
@quickactivate "StatReth"

# %%
# using StatisticalRethinking
using CSV
# using StatsBase
using Distributions
using DataFrames
using Turing
using Plots

include(srcdir("quap.jl"))

# %% 4.26
d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
d2 = d[d.age .>= 18, :]

# %% 4.37
scatter(d2.weight, d2.height)

# %% 4.38
N = 100
a = rand(Normal(178.0, 20.0), N)
b = rand(Normal(0.0, 10.0), N)

# %% 4.39
plot(xlims = extrema(d2.weight), ylims = (-100, 400), xlable = "weight", ylabel = "height")
hline!([0.0, 272.0])
x̄ = mean(d2.weight)
x = range(minimum(d2.weight), maximum(d2.weight), length = 100)
foreach(zip(a, b)) do (a, b)
    plot!(x, a .+ b .* (x .- x̄), color = "black", alpha = 0.2)
end
plot!(legend = false)

# %% 4.40
b = rand(LogNormal(0.0, 1.0), 10_000)
density(b, xlims = (0, 5))

# %% 4.41
N = 100
a = rand(Normal(178.0, 20.0), N)
b = rand(LogNormal(0.0, 1.0), N)

plot(xlims = extrema(d2.weight), ylims = (-100, 400), xlable = "weight", ylabel = "height")
hline!([0.0, 272.0])
x̄ = mean(d2.weight)
x = range(minimum(d2.weight), maximum(d2.weight), length = 100)
foreach(zip(a, b)) do (a, b)
    plot!(x, a .+ b .* (x .- x̄), color = "black", alpha = 0.2)
end
plot!(legend = false)

# %% 4.42
d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
d2 = d[d.age .>= 18, :]
x̄ = mean(d2.weight)

@model height(weights, heights) = begin
    a ~ Normal(178, 20)
    b ~ LogNormal(0, 1)
    σ ~ Uniform(0, 50)
    μ = a .+ b .* (weights .- x̄)
    heights .~ Normal.(μ, σ)
end

m = height(d2.weight, d2.height)
m4_3 = quap(m, NelderMead())

# %% 4.43
@model height(weights, heights) = begin
    a ~ Normal(178, 20)
    log_b ~ Normal(0, 1)
    σ ~ Uniform(0, 50)
    μ = a .+ exp(log_b) .* (weights .- mean(weights))
    heights .~ Normal.(μ, σ)
end

m = height(d2.weight, d2.height)
m4_3b = quap(m, NelderMead())

# %% 4.44
# precis(m4_3)

# %% 4.45
round.(m4_3.vcov, digits = 3)

# %% 4.46
scatter(d2.weight, d2.height)
post = rand(m4_3.distr, 10_000)
post = DataFrame(post', ["a", "b", "σ"])
a_map = mean(post.a)
b_map = mean(post.b)
plot!(x, a_map .+ b_map .* (x .- x̄))

# %% 4.47
post = rand(m4_3.distr, 10_000)
post = DataFrame(post', ["a", "b", "σ"])
post[1:5, :]

# %% 4.48
N = 10
dN = d2[1:N, :]
mN = quap(height(dN.weight, dN.height), NelderMead())

# %% 4.49
post = rand(mN.distr, 20)
post = DataFrame(post', ["a", "b", "σ"])



sample(m, Prior(), 100)
