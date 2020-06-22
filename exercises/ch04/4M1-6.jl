using DrWatson
@quickactivate "StatReth"

# %%
using DataFrames
using Turing
using Plots
using StatsPlots


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
