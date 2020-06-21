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
# This is from the chapter
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))
sort!(d, :weight)  # to make the plots look nice

z_weight, unz_weight = zscore_transform(d.weight)
d.weight_s = z_weight(d.weight)

f_parabola(weight_s, a, b1, b2) = a + b1 * weight_s + b2 * weight_s^2

@model function parabola(weight_s, height)
    a ~ Normal(178, 20)
    b1 ~ LogNormal(0, 1)
    b2 ~ Normal(0, 1)
    σ ~ Uniform(0, 50)
    μ = f_parabola.(weight_s, a, b1, b2)
    height ~ MvNormal(μ, σ)
end

mparab = parabola(d.weight_s, d.height)
prior = sample(mparab, Prior(), 1_000) |> DataFrame

# %%
plot(legend = false)
for c in eachrow(prior[1:100, :])
    p = f_parabola.(d.weight_s, c.a, c.b1, c.b2)
    plot!(d.weight_s, p, color = :black, alpha = 0.2)
end
plot!()

# %%
"""
Thinking about the cbrt explanation, b2 should be negative so I get a right turn here as
well. Since I don't want the extremum to be in the range of my data I need the maximum to
be at like 3 or 4 or something like that. Over the range of ~4 stddev I want the height to
change 100 cm or so.
f(x) = b₂ * x² + b₁ * x + a
f'(x) = 2b₂ * x + b₁

f(2) - f(-2) = 100
f'(3) = 0
b₂ < 0

f(2) - f(-2) = (b₂ * 4 + b₁ * 2 + a) - (b₂ * 4 + b₁ * -2 + a)
             = 4b₁ = 100
            =>  b₁ =  25
f'(3) = 2b₂ * 3 + b₁ = 0 => -b₁ = 6b₂
     => b₂ = -25 / 6 ≈ -4

I'll move a by hand until it seams reasonable.
"""

@model function parabola(weight_s, height)
    a ~ Normal(130, 20)
    b1 ~ Normal(25, 5)
    b2 ~ truncated(Normal(-4, 2), -Inf, 0)
    σ ~ Exponential(5)
    μ = f_parabola.(weight_s, a, b1, b2)
    height ~ MvNormal(μ, σ)
end

mparab = parabola(d.weight_s, d.height)
prior = sample(mparab, Prior(), 100) |> DataFrame

plot(legend = false)
for c in eachrow(prior)
    p = f_parabola.(d.weight_s, c.a, c.b1, c.b2)
    plot!(d.weight_s, p, color = :black, alpha = 0.2)
end
plot!(ylims = (0, 200))
