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
(1)
μ(A = 1) = α + β_A
μ(B = 1) = α + β_B
μ(C = 1) = α
μ(D = 1) = α + β_D

(2)
μ(A = 1) = α + β_A
μ(B = 1) = α + β_B
μ(C = 1) = α + β_C
μ(D = 1) = α + β_D

(3)
μ(A = 1) = α
μ(B = 1) = α + β_B
μ(C = 1) = α + β_C
μ(D = 1) = α + β_D

(4)
μ(A = 1) = α_A
μ(B = 1) = α_B
μ(C = 1) = α_C
μ(D = 1) = α_D

(5)
μ(A = 1) = α_A * (1 - 0 - 0 - 0)
μ(B = 1) = α_B
μ(C = 1) = α_C
μ(D = 1) = α_D

(2) is the odd one out because it has 5 parameters instead of the 4 of all the other models. I'm not sure if there going to be differences in uncertainty between (1)/(3) and (4)/(5).
"""
