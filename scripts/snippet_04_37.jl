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
using StatsPlots

include(srcdir("quap.jl"))

# %% 4.26
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))
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
x = range(minimum(d2.weight), maximum(d2.weight), length = 100)     # either
x = range(extrema(d2.weight)..., length = 100)                      # or
for (a, b) in zip(a, b)
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

@model function height(weights, heights)
    a ~ Normal(178, 20)
    b ~ LogNormal(0, 1)
    σ ~ Uniform(0, 50)
    μ = a .+ b .* (weights .- x̄)

    # This can't do the predictive posterior:
    # heights .~ Normal.(μ, σ)

    # This is pretty slow but works:
    # for i ∈ eachindex(heights)
    #     heights[i] ~ Normal(μ[i], σ)
    # end

    # This seems to work, fast:
    heights ~ MvNormal(μ, σ)
end

m = height(d2.weight, d2.height)
m4_3 = quap(m, NelderMead())

# %% 4.43
@model function height_log(weights, heights)
    a ~ Normal(178, 20)
    log_b ~ Normal(0, 1)
    σ ~ Uniform(0, 50)
    μ = a .+ exp(log_b) .* (weights .- mean(weights))
    heights .~ Normal.(μ, σ)
end

m = height(d2.weight, d2.height)
m4_3b = quap(m, NelderMead())

# %% 4.44, 4.45
# precis(m4_3)

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

# %% 4.48, 4.49
N = 10  # rerun with 50, 150, 352
dN = d2[1:N, :]
mN = quap(height(dN.weight, dN.height))

post = rand(mN.distr, 20)
post = DataFrame(post', ["a", "b", "σ"])

scatter(dN.weight, dN.height)
for p in eachrow(post)
    plot!(x, p.a .+ p.b .* (x .- mean(dN.weight)), color = "black", alpha = 0.3)
end
plot!(legend = false, xlabel = "weight", ylabel = "height")

# %% 4.50 - 4.52
post = rand(m4_3.distr, 1_000)
postdf = DataFrame(post', ["a", "b", "σ"])
mu_at_50 = postdf.a + postdf.b * (50 - x̄)

density(mu_at_50)

quantile(mu_at_50, (0.1, 0.9))

# %% 4.53 - 4.55
weight_seq = 25:70

# It's a little unfortunate that you have to write out the formula you have already put
# into the model. I don't have a better way at the moment though.
mu = postdf.a' .+ postdf.b' .* (weight_seq .- x̄)

scatter(weight_seq, mu[:, 1:100], legend = false, c = 1, alpha = 0.1)

# %% 4.56, 4.57
mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)

scatter(d2.weight, d2.height, ms = 3)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))

# %% 4.59 - 4.61
# This isn't really pretty either. I'm not sure how to put this into a function since
# there isn't a way to know how to create `predict_model` from `height`.
chn = Chains(post', ["a", "b", "σ"])
predict_model = height(weight_seq, missing)
sim = predict(predict_model, chn) |> Array

sim_m = mean.(eachcol(sim))
sim_lower = quantile.(eachcol(sim), 0.055)
sim_upper = quantile.(eachcol(sim), 0.945)

scatter(d2.weight, d2.height, ms = 3, legend = false)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %% 4.62
sim = predict(predict_model, Chains(rand(m4_3.distr, 10_000)', ["a", "b", "σ"])) |> Array

sim_m = mean.(eachcol(sim))
sim_lower = quantile.(eachcol(sim), 0.055)
sim_upper = quantile.(eachcol(sim), 0.945)

scatter(d2.weight, d2.height, ms = 3, legend = false)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %% 4.63
post = rand(m4_3.distr, 1_000)
postdf = DataFrame(post', ["a", "b", "σ"])
weight_seq = 25:70
normals = Normal.(postdf.a' .+ postdf.b' .* (weight_seq .- x̄), postdf.σ')
sim = rand.(normals)

sim_m = mean.(eachrow(sim))
sim_lower = quantile.(eachrow(sim), 0.055)
sim_upper = quantile.(eachrow(sim), 0.945)

scatter(d2.weight, d2.height, ms = 3, legend = false)
plot!(weight_seq, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)
