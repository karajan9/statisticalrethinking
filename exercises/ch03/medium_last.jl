using DrWatson
@quickactivate "StatReth"

# %%
# Sampling from grid approximate posterior
using Plots
using StatsBase
using Distributions
using StatsPlots

# %%
n = 1_000
p_grid = range(0, 1, length = n)
col_
prior = ones(n)

# %%
"""
Fair warning!
I went completely overboard with this one, I got so bad I even started
taking notes in German. Please try to keep your sanity.
"""

# function pi_dist(samples)
#     l, u = quantile(samples, (0.005, 0.995))
#     return u - l
# end

function auswertung(n, k, p_grid, prior)
    likelihood = @. pdf(Binomial(n, p_grid), k)
    # posterior = likelihood .* prior
    # posterior ./= sum(posterior)
    # posterior
    likelihood ./ sum(likelihood)
end

function posterior_über_k(n, p, p_grid, prior)
    gesamt_p_für_p = zeros(length(p_grid))
    for k in 0:n
        p_dass_dieses_k_auftritt = pdf(Binomial(n, p), k)
        p_für_p = auswertung(n, k, p_grid, prior)
        gesamt_p_für_p .+= p_dass_dieses_k_auftritt .* p_für_p
    end
    gesamt_p_für_p
end

function pi_dist(n, p, p_grid, prior)
    post_über_k = posterior_über_k(n, p, p_grid, prior)
    weights = pweights(post_über_k)
    l, u = quantile(p_grid, weights, [0.005, 0.995])
    return u - l
    # ns = 10_000
    # samples = sample(p_grid, weights, ns)
    # samples
end

function über_p(n, p_grid, prior)
    maximum(p_grid) do p
        println(n, " ", p)
        posterior_samples(n, p, p_grid, prior)
        # pi_dist(predpos_samples)
    end
end

# %%
posterior_über_k(5000, 0.7, p_grid, prior) |> plot

let
    likelihood = @. pdf(Binomial(50, p_grid), 35)
    posterior = likelihood .* prior
    posterior ./= sum(posterior)

    plot!(posterior)
end

# %%
let
    predpos_samples = predictiv_posterior(50, 0.7, p_grid, prior)
    density(predpos_samples)

    pi_dist(predpos_samples)
end

über_p(5500, p_grid, prior)

# %%
ns = 100:100:3000
ns = 3100:100:5000
res = zeros(length(ns))
Threads.@threads for i in 1:length(ns)
    n = ns[i]
    res[i] = über_p(n, p_grid, prior)
end
plot(ns, res)


# %%
ns = 100:100:5000
res = [0.36436936936936937, 0.26126126126126126, 0.21421421421421427, 0.18719219219219219, 0.1661711711711712, 0.15415415415415412, 0.1411461461461454, 0.13213713713713715, 0.12612612612612617, 0.11811811811811818, 0.11311311311311306, 0.10710710710710714, 0.10410410410410414, 0.10010010010010012, 0.09709709709709713, 0.09310310310310232, 0.09109109109109109, 0.0880880880880881, 0.08609109109109109, 0.08308308308308315, 0.08208208208208201, 0.08008008008008005, 0.07907907907907907, 0.07707707707707712, 0.07507507507507505, 0.07407407407407407, 0.07207207207207211, 0.07107107107107108, 0.07007007007007005, 0.06906906906906907, 0.06536298120084288, 0.06435885201026825, 0.06335555117095265, 0.062440202049018456, 0.06153473199637327, 0.06067345230968496, 0.05986667635189841, 0.059026361745720124, 0.058315847683361066, 0.05757238632468448, 0.05684749802817202, 0.05620289679737939, 0.05553017612660588, 0.05487561453559159, 0.05430071679577558, 0.053702781658199195, 0.05307944329882003, 0.05256906573675041, 0.05204639141882944, 0.051503807272551605]
scatter(ns, res)
