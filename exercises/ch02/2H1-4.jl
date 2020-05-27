using DrWatson
@quickactivate "StatReth"

# %%
"""2H1
Pr(twins|speciesA) = 0.1
Pr(twins|speciesB) = 0.2
Pr(speciesA) = Pr(speciesB) = 0.5
Pr(twins) = Pr(twins|speciesA) * Pr(speciesA) + Pr(twins|speciesB) * Pr(speciesB)
          = 0.1 * 0.5 + 0.2 * 0.5 = 0.15

Now births twins.

Bayes:
Pr(species|twins) = Pr(twins|species) * Pr(species) / Pr(twins)
Pr(panda = speciesA|twins) = 0.1 * 0.5 / 0.15 = 1/3
Pr(panda = speciesB|twins) = 0.2 * 0.5 / 0.15 = 2/3


Pr(twin|panda) = Pr(twins|speciesA) * Pr(panda = speciesA) +
                 Pr(twins|speciesB) * Pr(panda = speciesB)
               = 0.1 * 1/3 + 0.2 * 2/3 = 0.167

"""
# %%
"""2H2
Pr(twins|speciesA) = 0.1
Pr(twins|speciesB) = 0.2
Pr(speciesA) = Pr(speciesB) = 0.5
Pr(twins) = Pr(twins|speciesA) * Pr(speciesA) + Pr(twins|speciesB) * Pr(speciesB)
          = 0.1 * 0.5 + 0.2 * 0.5 = 0.15

Now births twins.

Bayes:
Pr(species|twins) = Pr(twins|species) * Pr(species) / Pr(twins)
Pr(panda = speciesA|twins) = 0.1 * 0.5 / 0.15 = 1/3
"""
# %%
"""2H3
Pr(twins|speciesA) = 0.1  |  Pr(singleinfant|speciesA) = 0.9
Pr(twins|speciesB) = 0.2  |  Pr(singleinfant|speciesB) = 0.8

Now:
Pr(speciesA) = 1/3
Pr(speciesB) = 2/3
Pr(twin|panda) = 0.167

Pr(singleinfant) = Pr(singleinfant|speciesA) * Pr(speciesA) +
                   Pr(singleinfant|speciesB) * Pr(speciesB)
                 = 0.9 * 1/3 + 0.8 * 2/3 = 0.833

Now births single infant.

Bayes:
Pr(species|singleinfant) = Pr(singleinfant|species) * Pr(species) / Pr(singleinfant)
Pr(panda = speciesA|singleinfant) = 0.9 * 1/3 / 0.833 = 0.36
"""
# %%
"""2H4
I understood the test like this:

                          panda is:
                    speciesA    speciesB
test    speciesA      0.8         0.35
says:   speciesB      0.2         0.65

Now the test comes back as speciesA.

We would like to know Pr(panda = speciesA | test = speciesA).

Bayes:
Pr(test = A | panda = A) = 0.8
Pr(panda = A) = Pr(panda = B) = 0.5
Pr(test = A) = 0.8 * 0.5 + 0.35 * 0.5 = 0.575
Pr(test = B) = 0.2 * 0.5 + 0.65 * 0.5 = 0.425

Pr(panda = A | test = A)
            = Pr(test = A | panda = A) * Pr(panda = A) / Pr(test = A)
            = 0.8 * 0.5 / 0.575 = 0.696
Pr(panda = B | test = A)
            = Pr(test = A | panda = B) * Pr(panda = B) / Pr(test = A)
            = 0.35 * 0.5 / 0.425 = 0.304

This will be our new prior:
=> Pr(speciesA) = 0.696
=> Pr(speciesB) = 0.304


Now births twins:
We want to know: Pr(speciesA|twins)

Pr(twins|speciesA) = 0.1  |  Pr(singleinfant|speciesA) = 0.9
Pr(twins|speciesB) = 0.2  |  Pr(singleinfant|speciesB) = 0.8

Bayes:
Pr(speciesA|twins) = Pr(twins|speciesA) * Pr(speciesA) / Pr(twins)
Pr(twins|speciesA) = 0.1
Pr(speciesA) = 0.696
Pr(twins) = 0.1 * 0.696 + 0.2 * 0.304 = 0.130
=> Pr(speciesA|twins) = 0.1 * 0.696 / 0.130 = 0.535
=> Pr(speciesB|twins) = 0.2 * 0.304 / 0.130 = 0.468
(including some rounding errors)

New priors:
=> Pr(speciesA) = 0.535
=> Pr(speciesB) = 0.468


Now births twins:
We want to know: Pr(speciesA|singleinfant)

Bayes:
Pr(speciesA|singleinfant) = Pr(singleinfant|speciesA) * Pr(speciesA) / Pr(singleinfant)
Pr(singleinfant|speciesA) = 0.9
Pr(speciesA) = 0.535
Pr(singleinfant) = 0.9 * 0.535 + 0.8 * 0.468 = 0.856
=> Pr(speciesA|twins) = 0.9 * 0.535 / 0.856 = 0.563
=> Pr(speciesB|twins) = 0.8 * 0.468 / 0.856 = 0.437

"""


# %%
using Statistics
using BenchmarkTools

function genetest(p)
    if p == true  # panda is A
        return rand() < 0.8
    else          # panda is B
        return rand() > 0.65
    end
end

function twinbirth(p)
    if p == true  # panda is A
        return rand() < 0.1
    else          # panda is B
        return rand() < 0.2
    end
end

function singleinfant(p)
    if p == true  # panda is A
        return rand() < 0.9
    else          # panda is B
        return rand() < 0.8
    end
end


f(p) = mean(p[@. genetest(p) & twinbirth(p) & singleinfant(p)])

function g(p)
    countA = count(p) do p
        genetest(p) && twinbirth(p) && singleinfant(p) && p
    end
    countB = count(p) do p
        genetest(p) && twinbirth(p) && singleinfant(p) && !p
    end
    countA / (countA + countB)
end

function h(pandasA)
    countA = 0
    countB = 0
    for p in pandasA
        if genetest(p) && twinbirth(p) && singleinfant(p)
            if p
                countA += 1
            else
                countB += 1
            end
        end
    end
    countA / (countA + countB)
end


n = 10000000
pandasA = rand(Bool, n)

f(pandasA)
g(pandasA)
h(pandasA)
