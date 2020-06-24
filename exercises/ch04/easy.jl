using DrWatson
@quickactivate "StatReth"

# %%
using CSV
using DataFrames
using Turing
using Plots
using StatsPlots

include(srcdir("quap.jl"))
include(srcdir("tools.jl"))

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
Bayes Theorem: P(A|B) = P(B|A) * P(A) / P(B)
P(μ,σ | y) = P(y | μ,σ) * P(μ,σ) / P(y)
           = pdf(Normal(μ, σ), yᵢ) * pdf(Normal(0, 10), μ) * pdf(Exponential(1)), μ) / P(y)
"""

# %% 4E4
"""
The line μᵢ = α + βxᵢ
"""

# %% 4E5
"""
There are three parameters, α, β, and σ.
"""
