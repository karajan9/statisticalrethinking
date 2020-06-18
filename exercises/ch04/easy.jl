using DrWatson
@quickactivate "StatReth"

# %%
using CSV
using Distributions
using DataFrames
using Turing
using Plots
using StatsPlots

include(srcdir("quap.jl"))

# %% 4E1
"""
The first line: yᵢ ~ Normal(μ, σ).
"""

# %% 4E2
"""
There are two parameters, μ and σ.
"""

# %% 4E3
"""
P(A|B) = P(B|A) * P(A) / P(B)
"""

# %% 4E4

# %% 4M1
N = 1000
σ = rand(Exponential(1), N)
μ = rand(Normal(0, 10), N)
y = rand.(Normal.(μ, σ))

# %% 4M2
@model function M1()
    μ ~ Normal(0, 10)
    σ ~ Exponential(1)
    y ~ Normal(μ, σ)
end

y2 = sample(M1(), Prior(), N) |> DataFrame

# %%
density(y)
density!(y2.y)


# %% 4M3
"""
y ~ Normal(μ, σ)
μᵢ = a + bxᵢ
a ~ Normal(0, 10)
b ~ Uniform(0, 1)
σ ~ Exponential(1)
"""

# %% 4M4
"""
Right of the bat, I don't like this exercise, I feel like I don't get it, maybe my english
leaves me hanging?
'Student' could mean everything from elementary school students (who will probably grow a
lot each year) to college student (who probably won't grow much, if at all).
Anyway.

height ~ Normal(μ, σ)
μᵢ = a + bxᵢ
a ~ Normal(140, 30)  # depending on what student we are talking about there is a huge range
b ~ Normal(0, 10)    # eh, kids grow a few cm each year
σ ~ truncated(Normal(0, 30), 0, ∞)   # again, depending on the sample the spread can be big
"""

# %% 4M5
"""
You remind me that this was the case in the data or that this is true in general? I didn't
grow like half the years I was a student.

b ~ truncated(Normal(0, 10), 0, ∞)   # now with 100% more truncation
"""

# %% 4M6
"""
Ah, so now you have the age? Why don't we use that to predict height? That's going to be so
much more effective. Did you mean year as in school year? If so, it really isn't clear from
the wording.
Variance 64cm (not sure, shouln't that be cm²?) == StdDev 8cm

σ ~ truncated(Normal(0, 5), 0, 8)  # might make sense for one year of young students,
                                   # for adults this is too narrow

But this depends on the fact that we have a mean per age (not year) or that the range of
ages it pretty small.
"""


# %% 4M7

# %% 4M8

# %% 4H1
d = DataFrame(CSV.File(datadir("exp_raw/Howell_1.csv")))
sort!(d, :weight)

density(d.weight)
scatter(d.weight, d.height)

function zscore(data, s = data)
    μ = mean(data)
    σ = std(data)
    z = (s .- μ) ./ σ
    unz(d) = d .* σ .+ μ
    return z, unz
end

d.weight_s, unz_weight = zscore(d.weight)
# scatter(d.weight_s, d.height)


using BSplines

num_knots = 5
knot_list = quantile(d.weight_s, range(0, 1, length = num_knots))

Bspline = BSplineBasis(3, knot_list)
B = basismatrix(Bspline, d.weight_s)

# plot(legend = false, xlabel = "year", ylabel = "basis value")
# for y in eachcol(B)
#     plot!(d.weight_s, y)
# end
# plot!()


@model function height(weight_s, height, B = B)
    α ~ Normal(150, 20)
    β ~ Normal(20, 20)
    w ~ filldist(Normal(0, 10), size(B, 2))
    σ ~ Exponential(1)
    μ = α .+ β .* weight_s .+ B * w  # mean + linear + wiggles
    height ~ MvNormal(μ, σ)
end

m = height(d.weight_s, d.height)

prior = sample(m, Prior(), 1000) |> DataFrame
w_str = "w[" .* string.(1:size(B, 2)) .* "]"
mu = prior.α' .+ prior.β' .* d.weight_s .+ B * Array(prior[!, w_str])'

mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)

scatter(d.weight_s, d.height, alpha = 0.3, legend = false)
plot!(d.weight_s, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))



q = quap(height(d.weight_s, d.height), NelderMead())
post = DataFrame(rand(q.distr, 1000)', ["α"; w_str; "σ"])

post = sample(height(d.weight_s, d.height), NUTS(), 1000)
post = DataFrame(post)

mu = post.α' .+ post.β' .* d.weight_s .+ B * Array(post[!, w_str])'

mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)

scatter(d.weight_s, d.height, alpha = 0.3, legend = false)
plot!(d.weight_s, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))




# %% 4.70, 4.71
weight_seq = range(-2.2, 2, length = 30)
post = DataFrame(rand(m4_6.distr, 1_000)', ["a", "b1", "b2", "b3", "σ"])
mu = f_cube.(weight_seq, post.a', post.b1', post.b2', post.b3')
sim = rand.(Normal.(mu, post.σ'))

mu_m = mean.(eachrow(mu))
mu_lower = quantile.(eachrow(mu), 0.055)
mu_upper = quantile.(eachrow(mu), 0.945)
sim_m = mean.(eachrow(sim))
sim_lower = quantile.(eachrow(sim), 0.055)
sim_upper = quantile.(eachrow(sim), 0.945)

weight_seq_rescaled = weight_seq .* std(d.weight) .+ mean(d.weight)
scatter(d.weight, d.height, ms = 3, alpha = 0.7, legend = false)
plot!(weight_seq_rescaled, mu_m, ribbon = (mu_m .- mu_lower, mu_upper .- mu_m))
plot!(weight_seq_rescaled, sim_lower, fillrange = sim_upper, alpha = 0.3, linealpha = 0.0, c = 2)



using BSplines

Bspline = BSplineBasis(4, knot_list)
B = basismatrix(Bspline, d2.year)

plot(legend = false, xlabel = "year", ylabel = "basis value")
for y in eachcol(B)
    plot!(d2.year, y)
end
plot!()

# %% 4.76
@model function spline(D, B = B)
    α ~ Normal(100, 10)
    w ~ filldist(Normal(0, 10), size(B, 2))
    σ ~ Exponential(1)
    μ = α .+ B * w
    D ~ MvNormal(μ, σ)
    return μ
end

m4_6 = quap(spline(d2.doy))



# %% 4H2

# %% 4H3

# %% 4H4

# %% 4H5

# %% 4H6

# %% 4H7

# %% 4H8
