using DrWatson
@quickactivate "StatReth"

# %%
ENV["GKS_ENCODING"] = "utf-8" # Allows the use of unicode characters in Plots.jl
using Plots
using Turing
using CSV
using StatsPlots


# %%
df = CSV.read(datadir("exp_raw/Howell_1.csv"))

# Use only adults and center the weight observations
df2 = filter(row -> row.age >= 18, df)
mean_weight = mean(df2.weight)
df2.weight_c = df2.weight .- mean_weight
first(df2, 5)

# Extract variables for Turing model

x = df2.weight_c
y = df2.height

# Define the regression model

@model line(x, y) = begin
    #priors
    height0 ~ Normal(178.0, 100.0)
    steigung ~ Normal(0.0, 10.0)
    s ~ Uniform(0, 50)

    #model
    mu = height0 .+ steigung .* x
    y .~ Normal.(mu, s)
    return mu, y
end

# Draw the samples
model = line(x, y)

chns = sample(model, NUTS(0.65), 1000)

describe(chns) |> display

plot(chns)


# %%
varinfo = Turing.VarInfo(prior)
spl = Turing.SampleFromPrior()

@code_warntype model.f(varinfo, spl, Turing.DefaultContext(), model)



prior = line(collect(30.0:70.0), missing)


# %%
plot(legend = false)

for i in 1:10
    # pmu, py = prior()
    # plot!(30.0:70.0, pmu, c = 1)
    # plot!(30.0:70.0, py, c = 3)

    mmu, my = model()
    # plot!(x, mmu, c = 2)
    scatter!(x, my, c = 4)
end
scatter!(x, y)
