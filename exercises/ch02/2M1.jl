using DrWatson
@quickactivate "StatReth"

# %%
using Plots
using Distributions

# %%
len = 100
p = range(0, 1, length = len)

# %%
prior = ones(len)
prior ./= sum(prior)

likelihood(w, l) = @. pdf(Binomial(w + l, p), w)

function posterior(prior, likelih)
    post = prior .* likelih
    return post ./ sum(post)
end

posterior_a = posterior(prior, likelihood(3, 0))  # www
posterior_b = posterior(prior, likelihood(3, 1))  # wwwl
posterior_c = posterior(prior, likelihood(5, 2))  # lwwlwww

# %%
plot(xlabel = "p", ylabel = "probability", dpi = 200, legend = :topleft)
plot!(p, posterior_a, label = "a")
plot!(p, posterior_b, label = "b")
plot!(p, posterior_c, label = "c")


# %%
prior = ones(len)
prior[p .< 0.5] .= 0.0
prior ./= sum(prior)

posterior_a = posterior(prior, likelihood(3, 0))  # www
posterior_b = posterior(prior, likelihood(3, 1))  # wwwl
posterior_c = posterior(prior, likelihood(5, 2))  # lwwlwww

# %%
plot(xlabel = "p", ylabel = "probability", dpi = 200, legend = :topleft)
plot!(p, posterior_a, label = "a")
plot!(p, posterior_b, label = "b")
plot!(p, posterior_c, label = "c")
