using DrWatson
@quickactivate "StatReth"

# %%
using CSV
using DataFrames
using Turing
using Plots

include(srcdir("quap.jl"))
include(srcdir("tools.jl"))

# %%
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))
sort!(d, :weight)  # to make the plots look nice
new_weights = [46.95, 43.72, 64.78, 32.59, 54.63]

# %%
"""
Alright, what's the model here? As a physicist, I'll try to model humans as a uniform
ball. So I have
weight =̂ mass ~ diameter³ =̂ height³,
which means
height ~ cbrt(weight).
Of course, humans aren't acutally balls, they're a bunch of cylinders stuck together,
everyone knows that. But for a model it's a good start, hopefully. To account for all
the anatomy I might be missing I'll slap a spline on top to allow for some corrections and
some wiggle. Since it's reasonable to expect a person with weight 0kg to have a height of
0cm I don't use an intercept.
"""

using BSplines: BSplineBasis, basismatrix

num_knots = 5
# For B-splines you have to define the range you want to use beforehand, which is why I
# include the new weigts here as well.
knot_list = range(extrema([d.weight; new_weights])..., length = num_knots)
basis = BSplineBasis(3, knot_list)
B = basismatrix(basis, d.weight)

@model function height(weight, height, B = B)
    # Priors!
    # β: A person with 64kg will be maybe 160cm. cbrt(64) = 4. So we are missing a factor
    #    of ~40.
    # w: Eh, not too much, not too little... I expect the cbrt to be off by ± 10cm easily.
    # σ: Previously σ was between 5 and 10, so this should work.
    β ~ Normal(40, 20)
    w ~ filldist(Normal(0, 10), size(B, 2))
    σ ~ Exponential(5)
    μ = f(weight, β, w, B)
    height ~ MvNormal(μ, σ)
end

f(weight, β, w, B) = β .* cbrt.(weight) .+ B * w

q = quap(height(d.weight, d.height))
w_str = ["w[$i]" for i in 1:length(basis)]  # this'll match the Chains later on
post = DataFrame(rand(q.distr, 1000)', ["β"; w_str; "σ"])

# %%
# Predict and plot
mu = f(d.weight, post.β', Array(post[!, w_str])')
mu_m, mu_lower, mu_upper = link(mu)

# need a new basismatrix for the new weights
B2 = basismatrix(basis, new_weights)
new_mu = f(new_weights, post.β', Array(post[!, w_str])', B2)
new_m, new_lower, new_upper = link(new_mu)

scatter(d.weight, d.height, alpha = 0.3, legend = false, xlims = (0, 70), ylims = (0, 185))
plot!(d.weight, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
scatter!(new_weights, new_m, yerror = (new_m .- new_lower, new_upper .- new_m))
