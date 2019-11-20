"""
`init_subspec!(m::Model1002)`

Initializes a model subspecification by overwriting parameters from
the original model object with new parameter objects. This function is
called from within the model constructor.
"""
function init_subspec!(m::Model1002)
    if subspec(m) == "ss2"
        return
    elseif subspec(m) == "ss8"
        return ss8!(m)
    elseif subspec(m) == "ss9"
        return ss9!(m)
    elseif subspec(m) == "ss10"
        return ss10!(m)
    elseif subspec(m) == "ss11"
        # Normalize s.t. sum of variances of anticipated shocks equals the
        # variance of the contemporaneous shock
        # See measurement equation
        return ss10!(m)
    elseif subspec(m) == "ss12"
        return ss12!(m)
    elseif subspec(m) == "ss13"
        return ss13!(m)
    elseif subspec(m) == "ss14"
        return ss14!(m)
    elseif subspec(m) == "ss15"
        return ss15!(m)
    elseif subspec(m) == "ss16"
        return ss16!(m)
    elseif subspec(m) == "ss17"
        return ss17!(m)
    elseif subspec(m) == "ss18"
        return ss18!(m)
    elseif subspec(m) == "ss19"
        return ss19!(m)
    else
        error("This subspec is not defined.")
    end
end

"""
```
ss8!(m::Model1002)
```

Initializes subspec 8 of `Model1002`. In this subspecification, γ_gdi
and δ_gdi are fixed at 1 and 0 respectively.
"""
function ss8!(m::Model1002)
    m <= parameter(:γ_gdi, 1., (-10., 10.), (-10., -10.), Untransformed(), Normal(1., 2.), fixed = true,
                   tex_label = "\\gamma_{gdi}")

    m <= parameter(:δ_gdi, 0., (-10., 10.), (-10., -10.), Untransformed(), Normal(0.00, 2.), fixed = true,
                   tex_label = "\\delta_{gdi}")
end

"""
```
ss9!(m::Model1002)
```

Initializes subspec 9 of `Model1002`. This subspecification is ss8 + Iskander's
changes + the bounds for beta-distributed parameters have been changed from
(1e-5, 0.99) to (0.0, 1.0).
"""
function ss9!(m::Model1002)

    ss8!(m)

    m <= parameter(:ζ_p, 0.8940, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.1), fixed = false,
                   description = "ζ_p: The Calvo parameter. In every period, intermediate goods producers optimize prices with probability (1-ζ_p). With probability ζ_p, prices are adjusted according to a weighted average of the previous period's inflation (π_t1) and steady-state inflation (π_star).",
                   tex_label = "\\zeta_p")

    m <= parameter(:ι_p, 0.1865, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.15), fixed = false,
                   description = "ι_p: The weight attributed to last period's inflation in price indexation. (1-ι_p) is the weight attributed to steady-state inflation.",
                   tex_label = "\\iota_p")

    m <= parameter(:h, 0.5347, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.7, 0.1), fixed = false,
                   description = "h: Consumption habit persistence.",
                   tex_label = "h")

    m <= parameter(:ppsi, 0.6862, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.15), fixed = false,
                   description = "ppsi: Utilization costs.",
                   tex_label = "\\psi")

    m <= parameter(:ζ_w, 0.9291, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.1), fixed = false,
                   description = "ζ_w: (1-ζ_w) is the probability with which households can freely choose wages in each period. With probability ζ_w, wages increase at a geometrically weighted average of the steady state rate of wage increases and last period's productivity times last period's inflation.",
                   tex_label = "\\zeta_w")

    m <= parameter(:ι_w, 0.2992, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.15), fixed = false,
                   description = "ι_w: The weight attributed to last period's wage in wage indexation. (1-ι_w) is the weight attributed to steady-state wages.",
                   tex_label = "\\iota_w")

    m <= parameter(:ρ, 0.7126, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.75, 0.10), fixed = false,
                   description = "ρ: The degree of inertia in the monetary policy rule.",
                   tex_label = "\\rho_R")

    # Financial frictions parameters
    m <= parameter(:Fω, 0.0300, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.03, 0.01), fixed = true,
                   scaling = x -> 1 - (1-x)^0.25,
                   description = "F(ω): The cumulative distribution function of ω (idiosyncratic iid shock that increases or decreases entrepreneurs' capital).",
                   tex_label = "F(\\bar{\\omega})")

    m <= parameter(:ζ_spb, 0.0559, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.05, 0.005), fixed = false,
                   description = "ζ_spb: The elasticity of the expected exess return on capital (or 'spread') with respect to leverage.",
                   tex_label = "\\zeta_{sp,b}")

    m <= parameter(:γ_star, 0.9900, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.99, 0.002),
                   fixed = true,
                   description = "γ_star: Fraction of entrepreneurs who survive and continue operating for another period.",
                   tex_label = "\\gamma_*")

    m <= parameter(:ρ_g, 0.9863, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_g: AR(1) coefficient in the government spending process.",
                   tex_label = "\\rho_g")

    m <= parameter(:ρ_b, 0.9410, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_b: AR(1) coefficient in the intertemporal preference shifter process.",
                   tex_label = "\\rho_b")

    m <= parameter(:ρ_μ, 0.8735, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_μ: AR(1) coefficient in capital adjustment cost process.",
                   tex_label = "\\rho_{\\mu}")

    m <= parameter(:ρ_ztil, 0.9446, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_ztil: AR(1) coefficient in the technology process.",
                   tex_label = "\\rho_ztil")

    m <= parameter(:ρ_λ_f, 0.8827, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_λ_f: AR(1) coefficient in the price mark-up shock process.",
                   tex_label = "\\rho_{\\lambda_f}")

    m <= parameter(:ρ_λ_w, 0.3884, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_λ_w: AR(1) coefficient in the wage mark-up shock process.",
                   tex_label = "\\rho_{\\lambda_w}")

    m <= parameter(:ρ_rm, 0.2135, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_rm: AR(1) coefficient in the monetary policy shock process.",
                   tex_label = "\\rho_{r^m}")

    m <= parameter(:ρ_σ_w, 0.9898, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.75, 0.15), fixed = false,
                   description = "ρ_σ_w: The standard deviation of entrepreneurs' capital productivity follows an exogenous process with mean ρ_σ_w. Innovations to the process are called _spread shocks_.",
                   tex_label = "\\rho_{\\sigma_\\omega}")

    m <= parameter(:ρ_μ_e, 0.7500, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.75, 0.15), fixed = true,
                   description = "ρ_μ_e: AR(1) coefficient in the exogenous bankruptcy cost process.",
                   tex_label = "\\rho_{\\mu_e}")

    m <= parameter(:ρ_γ, 0.7500, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.75, 0.15), fixed = true,
                   description = "ρ_γ: AR(1) coefficient in the process describing the fraction of entrepreneurs surviving period t.",
                   tex_label = "\\rho_{\\gamma}")

    m <= parameter(:ρ_π_star, 0.9900, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = true,
                   description = "ρ_π_star: AR(1) coefficient in the time-varying inflation target process.",
                   tex_label = "\\rho_{\\pi_*}")

    m <= parameter(:ρ_lr, 0.6936, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   tex_label = "\\rho_{10y}")

    m <= parameter(:ρ_z_p, 0.8910, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   description = "ρ_z_p: AR(1) coefficient in the process describing the permanent component of productivity.",
                   tex_label = "\\rho_{z^p}")

    m <= parameter(:ρ_tfp, 0.1953, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   tex_label = "\\rho_{tfp}")

    m <= parameter(:ρ_gdpdef, 0.5379, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   tex_label = "\\rho_{gdpdef}")

    m <= parameter(:ρ_corepce, 0.2320, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.5, 0.2), fixed = false,
                   tex_label = "\\rho_{pce}")

    m <= parameter(:η_gz, 0.8400, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.50, 0.20), fixed = false,
                   description = "η_gz: Correlate g and z shocks.",
                   tex_label = "\\eta_{gz}")

    m <= parameter(:η_λ_f, 0.7892, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.50, 0.20), fixed = false,
                   tex_label = "\\eta_{\\lambda_f}")

    m <= parameter(:η_λ_w, 0.4226, (0.0, 1.0), (0.0, 1.0), SquareRoot(), BetaAlt(0.50, 0.20), fixed = false,
                   description = "η_λ_w: AR(2) coefficient on wage markup shock process.",
                   tex_label = "\\eta_{\\lambda_w}")

    m <= parameter(:Iendoα, 0.0000, (0.0, 1.0), (0.0, 0.0), Untransformed(), BetaAlt(0.50, 0.20), fixed = true,
                   description = "Iendoα: Indicates whether to use the model's endogenous α in the capacity utilization adjustment of total factor productivity.",
                   tex_label = "I\\{\\alpha^{model}\\}")
end

"""
```
ss10!(m::Model1002)
```

Initializes subspec 10 of `Model1002`. This subspecification is the same as ss9,
except `betabar` is defined with `m[:σ_c]` instead of `σ_ω_star`.
"""
function ss10!(m::Model1002)
    ss9!(m)
end

"""
```
ss12!(m::Model1002)
```

Initializes subspec 12 of `Model1002`. This subspecification is the same as ss10,
but exogenous processes are added as pseudo-observables.
"""
function ss12!(m::Model1002)
    ss10!(m)
end

"""
```
ss13!(m::Model1002)
```

Initializes subspec 13 of `Model1002`. This subspecification is the same as ss10,
but tracks Sinf_t, the contribution of expected future marginal cost, as a pseudo-obs.
"""
function ss13!(m::Model1002)
    ss10!(m)
end

"""
```
ss14!(m::Model1002)
```

Initializes subspec 14 of `Model1002`. This subspecification is the same as ss13,
but with stationarity in the levels (rather than growth) of the measurement
error in the TFP process.
"""
function ss14!(m::Model1002)
    ss13!(m)
end

"""
```
ss15!(m::Model1002)
```

Initializes subspec 15 of `Model1002`. This subspecification is the same as ss14,
but with the TFP observables series now being Fernald's TFP adjusted to utilization.
"""
function ss15!(m::Model1002)
    ss14!(m)
end

"""
```
ss16!(m::Model1002)
```

Initializes subspec 16 of `Model1002`. This subspecification is the same as ss15,
but with the measurement equation using log labor share instead of wage growth.
"""
function ss16!(m::Model1002)
    ss15!(m)
end

"""
```
ss17!(m::Model1002)
```

Initializes subspec 17 of `Model1002`. This subspecification is the same as ss13,
but with the measurement equation using log labor share instead of wage growth.
"""
function ss17!(m::Model1002)
    ss13!(m)
end

"""
```
ss18!(m::Model1002)
```

Initializes subspec 18 of `Model1002`. This subspecification is the same as ss14,
but with ρ_tfp = 0 (fixed) and a near-zero prior on σ_tfp
"""
function ss18!(m::Model1002)
    ss14!(m)
    m <= parameter(:ρ_tfp, 0., (1e-5, 0.999), (1e-5, 0.999), ModelConstructors.SquareRoot(),
                   BetaAlt(0.5, 0.2), fixed = true, tex_label = "\\rho_{tfp}")
    m <= parameter(:σ_tfp, 0.01, (1e-8, 5.), (1e-8, 5.), ModelConstructors.Exponential(),
                   RootInverseGamma(2, sqrt(0.0001)), fixed=false,
                   tex_label="\\sigma_{tfp}")
end

"""
```
ss19!(m::Model1002)
```

Initializes subspec 19 of `Model1002`. This subspecification is the same as ss14,
but with a near zero prior on ρ_tfp and σ_tfp
"""
function ss19!(m::Model1002)
    ss14!(m)
    m <= parameter(:ρ_tfp, 0.01, (1e-5, 0.999999), (1e-5, 0.999999), ModelConstructors.SquareRoot(),
                   BetaAlt(0.01, 0.02), fixed = false, tex_label = "\\rho_{tfp}")
    m <= parameter(:σ_tfp, 0.01, (1e-8, 5.), (1e-8, 5.), ModelConstructors.Exponential(),
                   RootInverseGamma(2, sqrt(0.0001)), fixed=false,
                   tex_label="\\sigma_{tfp}")
end
