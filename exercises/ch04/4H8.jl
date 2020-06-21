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
    # α ~ Normal(100, 10)
    # w ~ filldist(Normal(0, 10), size(B, 2))
    w ~ filldist(Normal(100, 10), size(B, 2))
    σ ~ Exponential(1)
    μ = B * w
    doy ~ MvNormal(μ, σ)
end

qspl = quap(spline(d2.doy))

# %%
w_str = ["w[$i]" for i in 1:length(basis)]
post = DataFrame(rand(qspl.distr, 1000)', [w_str; "σ"])

smu = B * Array(post[!, w_str])'
smu_m, smu_lower, smu_upper = meanlowerupper(smu)

scatter(d2.year, d.doy, alpha = 0.3)
plot!(d2.year, smu_m, ribbon = (smu_m .- smu_lower, smu_upper .- smu_m))

# %%
"""
Not sure what he means by "The first basis functions could substitute for the intercept".
If I'm not mistaken I need to add the intercept to all of the basis functions since the
first one doesn't reach to the end?
"""
