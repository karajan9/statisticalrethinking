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

# %% 5E1
"""
(1) Normal regression
(2) <- Multiple regression without intercept
(3) Normal regression of the difference
(4) <- "Regular" multiple regression
"""

# %% 5E2
"""
"""

# %% 5E3
"""
"""

# %% 5E4
"""
(4) and (5) are identical because Aᵢ = 1 - Bᵢ - Cᵢ - Dᵢ (we have A when we don't have any of the other). This holds only when you have the same number of lables as you have unique values.
"""
