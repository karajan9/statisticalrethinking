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
P(A|B) = P(B|A) * P(A) / P(B)
"""

# %% 4E4
