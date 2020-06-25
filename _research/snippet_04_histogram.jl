using DrWatson
@quickactivate "StatReth"

# %%
using StatisticalRethinking
using CSV
# using DataFrames
using StatsBase
using Distributions
using Plots
using StatsPlots

# %% 4.7, 4.11
d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
precis(d)

d2 = filter(row -> row.age >= 18, d)
d2 = d[d.age .>= 18, :]

# %%
d.height
d.weight

f = fit(Histogram, d.weight, nbins = 12)

histogram(d.weight)

# %%
f = fit(Histogram, d.weight, nbins = 12)
# f = fit(Histogram, d.weight, range(0, 75, length = 13))
plot(f)
hline!(range(0, maximum(f.weights), length = 9))
savefig(plotsdir("histogram"))

# %%


f.weights





const BARS = collect("▁▂▃▄▅▆▇█")

function unicode_histogram(data)
  f = fit(Histogram, data, nbins = 12)  # nbins: more like a guideline than a rule, really
  # scale weights between 1 and 8 (length(BARS)) to fit the indices in BARS
  # eps is needed so indices are in the interval [0, 8) instead of [0, 8] which could
  # result in indices 0:8 which breaks things
  scaled = f.weights .* (length(BARS) / maximum(f.weights) - eps())
  indices = floor.(Int, scaled) .+ 1
  return join((BARS[i] for i in indices))
end

for col in eachcol(d)
    println(unicode_histogram(col))
end


fit(histogram)


# %%
 # ▁▂▃▄▅▆▇█



 Example usage:
 ```
 d = CSV.read(datadir("exp_raw/Howell_1.csv"), copycols = true)
 for col in eachcol(d)
     println(unicode_histogram(col))
 end
 ```
 gives
 ```
 ▁▁▁▂▂▂▂▂▂██▆▁
 ▁▃▄▄▃▂▃▆██▅▃▁
 █▆▆▆▆▃▃▁▁
 █▁▁▁▁▁▁▁▁▁█
 ```

 I'm not sure how to incorporate this with `precis` since it would probably turn the array type in to a `Union`. Unicode and font coverage is also necessary but that seems to be pretty good in the Julia community (heavy Unicode symbol usage, strings are UTF-8...).
