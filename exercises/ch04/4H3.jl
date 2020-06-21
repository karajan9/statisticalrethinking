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

@model function height_log(weight, height)
    # β: A person with 100kg will be maybe 180cm. log10(100) = 2. Missing factor: 90
    β ~ Normal(90, 20)
    σ ~ Exponential(5)
    μ = f_log(weight, β)
    height ~ MvNormal(μ, σ)
end

f_log(weight, β) = β .* log10.(weight)

q = quap(height_log(d.weight, d.height))
post = DataFrame(rand(q.distr, 1000)', ["β", "σ"])

mu = f_log(d.weight, post.β')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

scatter(d.weight, d.height, alpha = 0.3, legend = false)
plot!(d.weight, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))

# %%
# Some predictions from the inferred values.
estimmean, estimlower, estimupper = estimparam(post)
estimmean[1] * log10(2)
"""
I've left out an intercept again because it doesn't make any sense. If you want to have the
best fit you should definitely put it in though.
β: A person double your weight is expected to be on average 28 cm taller.
"""

# %%
sim = rand.(Normal.(mu, post.σ'))
sim_m, sim_lower, sim_upper = meanlowerupper(sim)

scatter(d.weight, d.height, alpha = 0.3, legend = false)
plot!(d.weight, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(d.weight, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %%
"""
Uhhh, the model looks pretty screwed towards the beginning there...
"""
