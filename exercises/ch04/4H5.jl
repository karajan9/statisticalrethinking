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
dropmissing!(d, [:temp, :doy])

# scatter(d.temp, d.doy, alpha = 0.3)

# %%
# First, a pure linear model.
flin(temp, α, β) = α .+ β .* temp

@model function cherry_linear(temp, doy)
    # β: With a higher temperature I expect the doy to be earlier. Maybe 1 month per 10°C?
    α ~ Normal(100, 10)
    β ~ Normal(-3, 2)
    σ ~ Exponential(1)
    μ = flin(temp, α, β)
    doy ~ MvNormal(μ, σ)
end

m = cherry_linear(d.temp, d.doy)

# %%
# Sample from the prior. Looks pretty reasonable.
prior = sample(m, Prior(), 100) |> DataFrame

scatter(d.year,  d.doy, alpha = 0.3)
for r in eachrow(prior)
    p = flin(d.temp, r.α, r.β)
    plot!(d.year, p, alpha = 0.2)
end
plot!(legend = false, ylims = (0, 200))

# %%
# Fit and show the fit.
q = quap(m)
post = DataFrame(rand(q.distr, 1000)', ["α", "β", "σ"])

mu = flin(d.temp, post.α', post.β')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)
sim = rand.(Normal.(mu, post.σ'))
sim_m, sim_lower, sim_upper = meanlowerupper(sim)

scatter(d.year, d.doy, alpha = 0.3, legend = false)
plot!(d.year, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(d.year, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %%
# Second, a linear model enhanced with extra wiggle.
using BSplines: BSplineBasis, basismatrix

num_knots = 15
knot_list = quantile(d.year, range(0, 1, length = num_knots))

basis = BSplineBasis(4, knot_list)
B = basismatrix(basis, d.year)

# %%
# Fit the model.
@model function spline(temp, doy, B = B)
    α ~ Normal(100, 10)
    β ~ Normal(-3, 2)
    w ~ filldist(Normal(0, 10), size(B, 2))
    σ ~ Exponential(1)
    μ = flin(temp, α, β) .+ B * w
    doy ~ MvNormal(μ, σ)
end

sample(spline(d.temp, d.doy), NUTS(), 1000)

qspl = quap(spline(d.temp, d.doy))

w_str = ["w[$i]" for i in 1:length(basis)]
post = DataFrame(rand(qspl.distr, 1000)', ["α"; "β"; w_str; "σ"])

smu = fspl(d.temp, post.α', post.β', Array(post[!, w_str])', B)
smu_m, smu_lower, smu_upper = meanlowerupper(smu)

# %%
# Display both solutions together.
scatter(d.year, d.doy, alpha = 0.3, label = "data")
plot!(d.year, smu_m, ribbon = (smu_m .- smu_lower, smu_upper .- smu_m), label = "linear")
plot!(d.year, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m), label = "linear+spline")
