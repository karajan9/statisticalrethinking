using DrWatson
@quickactivate "StatReth"

# %%
# Bayes: Pr(Earth|Land) = Pr(Land|Earth) * Pr(Earth) / Pr(Land)

p_land_earth = 1 - 0.7
p_land_mars = 1.0
p_earth = 0.5
p_land = p_land_earth * p_earth + p_land_mars * (1 - p_earth)

p_earth_land = p_land_earth * p_earth / p_land
