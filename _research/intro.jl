# %%
using DrWatson
@quickactivate "StatReth"


# %%
ENV["GKS_ENCODING"] = "utf-8" # Allows the use of unicode characters in Plots.jl
using Plots
using StatsPlots
using Turing
using Bijectors
# using Random
using DynamicPPL: getlogp, settrans!, getval, reconstruct, vectorize, setval!


# Define a strange model.
@model gdemo(x) = begin
    s ~ InverseGamma(2, 3)
    m ~ Normal(0, sqrt(s))
    bumps = sin(m) + cos(m)
    m = m + 5*bumps
    for i in eachindex(x)
      x[i] ~ Normal(m, sqrt(s))
    end
    return s, m
end

# Define our data points.
x = [1.5, 2.0, 13.0, 2.1, 0.0]

# Set up the model call, sample from the prior.
model = gdemo(x)
vi = Turing.VarInfo(model)

# Convert the variance parameter to the real line before sampling.
# Note: We only have to do this here because we are being very hands-on.
# Turing will handle all of this for you during normal sampling.
dist = InverseGamma(2,3)
svn = vi.metadata.s.vns[1]
mvn = vi.metadata.m.vns[1]
setval!(vi, vectorize(dist, Bijectors.link(dist, reconstruct(dist, getval(vi, svn)))), svn)
settrans!(vi, true, svn)

# Evaluate surface at coordinates.
function evaluate(m1, m2)
    spl = Turing.SampleFromPrior()
    vi[svn] = [m1]
    vi[mvn] = [m2]
    model(vi, spl)
    getlogp(vi)
end

function plot_sampler(chain; label="")
    # Extract values from chain.
    val = get(chain, [:s, :m, :lp])
    ss = link.(Ref(InverseGamma(2, 3)), val.s)
    ms = val.m
    lps = val.lp

    # How many surface points to sample.
    granularity = 100

    # Range start/stop points.
    spread = 0.5
    σ_start = minimum(ss) - spread * std(ss);
    σ_stop = maximum(ss) + spread * std(ss);
    μ_start = minimum(ms) - spread * std(ms);
    μ_stop = maximum(ms) + spread * std(ms);
    σ_rng = range(σ_start, stop=σ_stop, length=granularity)
    μ_rng = range(μ_start, stop=μ_stop, length=granularity)

    # Make surface plot.
    p = surface(σ_rng, μ_rng, evaluate,
          camera=(30, 65),
        #   ticks=nothing,
          colorbar=false,
          color=:inferno,
          title=label)


    return p
end


c = sample(model, HMC(0.01, 10), 1000)
plot_sampler(c)
