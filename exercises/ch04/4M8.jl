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

# %% 4.76
# Redo the model from the text ...
using BSplines: BSplineBasis, basismatrix

num_knots = 15
knot_list = quantile(d2.year, range(0, 1, length = num_knots))

basis = BSplineBasis(4, knot_list)
B = basismatrix(basis, d2.year)

@model function spline(doy, B = B)
    α ~ Normal(100, 10)
    w ~ filldist(Normal(0, 10), size(B, 2))
    σ ~ Exponential(1)
    μ = α .+ B * w
    doy ~ MvNormal(μ, σ)
end

m4_7 = quap(spline(d2.doy))

# %%
# ... and look at the splines
w_str = ["w[$i]" for i in 1:length(basis)]
post = DataFrame(rand(m4_7.distr, 1000)', ["α"; w_str; "σ"])

w = mean.(eachcol(post[:, w_str]))

plot(legend = false, xlabel = "year", ylabel = "basis * weight")
for y in eachcol(B .* w')
    plot!(d2.year, y)
end
plot!()

mu = B * Array(post[!, w_str])'
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

plot!(d2.year, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m),
                    lw = 2, fa = 0.1, c = :black)

# %%
# Now do the entire thing with more knots. The model can stay the same, just need to replace
# B
num_knots = 30
knot_list = quantile(d2.year, range(0, 1, length = num_knots))

basis2 = BSplineBasis(4, knot_list)
B2 = basismatrix(basis2, d2.year)

m4_7_2 = quap(spline(d2.doy, B2))

# %%
# ... and look at the splines
w_str = ["w[$i]" for i in 1:length(basis2)]
post = DataFrame(rand(m4_7_2.distr, 1000)', ["α"; w_str; "σ"])

w = mean.(eachcol(post[:, w_str]))

plot(legend = false, xlabel = "year", ylabel = "basis * weight")
for y in eachcol(B2 .* w')
    plot!(d2.year, y)
end
plot!()

mu = B2 * Array(post[!, w_str])'
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

plot!(d2.year, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m),
                    lw = 2, fa = 0.1, c = :black)

# %%
"""
More knots make it possible for the spline to have more wiggles. Since that improves the
fit, it is taken advantage of and the spline gets wigglier. This is pretty similar to how
things go when trying to fit a polynomial while increasing its order. The fit gets better
for the cost of losing generality.
I'm not going to do the prior on the weights thing, I already did the same thing in 4H6.
The amplitude goes up or down, depending in what direction I change the prior.
"""
