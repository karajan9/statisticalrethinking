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
d2 = d[d.age .< 18, :]

z_weight, unz_weight = zscore_transform(d2.weight)
d2.weight_s = z_weight(d2.weight)

@model function height_linear(weight_s, height)
    α ~ Normal(100, 20)
    β ~ LogNormal(2, 1)
    σ ~ Exponential(5)
    μ = f_linear(weight_s, α, β)
    height ~ MvNormal(μ, σ)
end

f_linear(weight_s, α, β) = α .+ β .* weight_s

q = quap(height_linear(d2.weight_s, d2.height))
post = DataFrame(rand(q.distr, 1000)', ["α"; "β"; "σ"])

# %%
estimmean, estimlower, estimupper = estimparam(post)
"""
All values heavily rounded.
α = 108 ± 1 cm
β = 23 ± 1 cm/stddev(kg)
σ = 8.5 ± 0.5 cm
For β we need to convert this result into cm/kg
β = 23 / std(d2.weight) = 2.5

Average height of the children is 108 cm. On average they are 2.5 cm taller for every 1 kg
they are heavier. Children with the same weight have an expected standard deviation of their
height of 8.5 cm
"""

# %%
mu = f_linear(d2.weight_s, post.α', post.β')
mu_m, mu_lower, mu_upper = meanlowerupper(mu)

scatter(d2.weight, d2.height, alpha = 0.3, legend = false)
plot!(d2.weight, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))

pred = rand.(Normal.(mu, post.σ'))
_, pred_lower, pred_upper = meanlowerupper(pred)

plot!(d2.weight, pred_lower, fillrange = pred_upper, alpha = 0.3, linealpha = 0.0, c = 2)

# %%
"""
Well, I'm concerned about the fact that I'm using a linear model even though the data
doesn't seem to be particularly linear. I mean, it's predicting there's going to be a 60 cm
tall child that doesn't weigh anything. Negative weights seen to be a-ok, too.
I suspect/hope that doing something like sqrt/cbrt or the likes would be better.
"""
