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
# Load the data, don't forget to drop everything missing.
d = DataFrame(CSV.File(datadir("exp_raw/cherry_blossoms.csv"), missingstring = "NA"))
d2 = dropmissing(d, :doy)

# %%
using BSplines: BSplineBasis, basismatrix

num_knots = 15
knot_list = quantile(d2.year, range(0, 1, length = num_knots))

basis = BSplineBasis(4, knot_list)
B = basismatrix(basis, d2.year)

@model function spline(doy, B = B)
    α ~ Normal(100, 10)
    w ~ filldist(Normal(0, 2), size(B, 2))
    σ ~ Exponential(1)
    μ = α .+ B * w
    doy ~ MvNormal(μ, σ)
end

m = spline(d2.doy)

# %%
# Sample from the prior. Looks pretty reasonable.
prior = sample(m, Prior(), 100) |> DataFrame
w_str = ["w[$i]" for i in 1:length(basis)]

scatter(d2.year, d2.doy, alpha = 0.3)
for r in eachrow(prior)
    p = r.α .+ B * Array(r[w_str])
    plot!(d2.year, p, color = :black, alpha = 0.2)
end
plot!(legend = false)

# %%
"""
It looks like the prior on the weights "controls" the possible amplitude of the wiggle (as
opposed to the number of knots which controls its frequency).
"""
