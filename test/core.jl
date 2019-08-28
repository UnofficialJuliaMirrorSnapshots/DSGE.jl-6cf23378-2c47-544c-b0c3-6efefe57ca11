using DSGE, ModelConstructors
using Distributions, Test, LinearAlgebra

m = AnSchorfheide()
# not moved below here
# prior
priordensity = exp(DSGE.prior(m))
@testset "Ensure prior density is a density" begin
    @test 0 <= priordensity <= 1
end


# Pseudo-measurement equation matrices in Systems
system = compute_system(m)
system[:ZZ_pseudo]
system[:DD_pseudo]

nothing


# Below have all been moved to ModelConstructors.jl
# Test Parameter type

# UnscaledParameter, fixed=false
#=α =  parameter(:α, 0.1596, (1e-5, 0.999), (1e-5, 0.999), ModelConstructors.SquareRoot(), Normal(0.30, 0.05), fixed=false)
@testset "Test non-fixed UnscaledParameter" begin
    @test isa(α, UnscaledParameter)
    @test α.key == :α
    @test isa(α.prior.value, Normal)
    @test α.prior.value.μ == 0.3
    @test α.description == "No description available."
    @test α.tex_label == ""
    @test isa(α.transform, ModelConstructors.SquareRoot)
end

# UnscaledParameter, fixed = true
α_fixed =  parameter(:α_fixed, 0.1596, (1e-5, 0.999), (1e-5, 0.999), ModelConstructors.Untransformed(), Normal(0.30, 0.05), fixed=true)
@testset "Test fixed UnscaledParameter" begin
    @test α_fixed.transform_parameterization == (0.1596,0.1596)
    @test isa(α_fixed.transform, ModelConstructors.Untransformed)
end

# UnscaledParameter, fixed = true, transform should be overwritten given fixed
α_fixed =  parameter(:α_fixed, 0.1596, (1e-5, 0.999), (1e-5, 0.999), ModelConstructors.SquareRoot(), Normal(0.30, 0.05), fixed=true)
@testset "Test fixed UnscaledParameter, ensuring transform is overwritten" begin
    @test isa(α_fixed.transform, ModelConstructors.Untransformed)
end

# Fixed UnscaledParameter, minimal constructor
δ = parameter(:δ, 0.025)
@testset "Test fixed UnscaledParameter minimal constructor" begin
    @test δ.fixed
    @test δ.transform_parameterization == (0.025, 0.025)
    @test δ.valuebounds == (0.025, 0.025)
end

# Scaled parameter
β = parameter(:β, 0.1402, (1e-5, 10.), (1e-5, 10.), ModelConstructors.Exponential(), GammaAlt(0.25, 0.1), fixed=false,  scaling = x -> (1 + x/100)\1, description="β: Discount rate.", tex_label="\\beta ")
@testset "Test ScaledParameter constructor" begin
    @test isa(β, ScaledParameter)
    @test isa(β.prior.value, Gamma)
    @test isa(β.transform, ModelConstructors.Exponential)
end

# Invalid transform
@testset "Ensure error thrown on invalid transform" begin
    @test_throws UndefVarError α_bad = parameter(:α, 0.1596, (1e-5, 0.999), (1e-5, 0.999),
                                                  InvalidTransform(), Normal(0.30, 0.05), fixed=false)
end


# Arithmetic with parameters
@testset "Check arithmetic with parameters" begin
    @test promote_type(AbstractParameter{Float64}, Float16) == Float64
    @test promote_type(AbstractParameter{Float64}, Int8) == Float64
    ## @test promote_rule(AbstractParameter{Float64}, Float16) == Float64
    ## @test promote_rule(AbstractParameter{Float64}, Int8) == Float64
    @test δ + δ == 0.05
    @test δ^2 == 0.025^2
    @test -δ == -0.025
    @test log(δ) == log(0.025)
end

# transform_to_real_line and transform_to_model_space
cx = 2 * (α - 1/2)
@testset "Check parameter transformations for optimization" begin
    @test abs(transform_to_real_line(α) - cx / sqrt(1 - cx^2)) < .001
    @test transform_to_real_line(δ) == 0.025
end

m = AnSchorfheide()
let lastparam = parameter(:p, 0.0)
    for θ in m.parameters
        isa(θ, Parameter) && (lastparam = θ)
    end
    @testset "Check AnSchorfheide last parameter" begin
        @test isa(lastparam, Parameter)
        @test lastparam.value == 0.20*2.237937
    end
end
# transform_to_real_line and transform_to_model_space, acting on the entire parameter vector. they should be inverses!
pvec = m.parameters
vals = transform_to_real_line(pvec)
transform_to_model_space!(m, vals)
@testset "Check parameter transformations for optimization part 2" begin
    @test pvec == m.parameters
end

# all fixed parameters should be unchanged by both transform_to_real_line and transform_to_model_space
@testset "Check fixed parameters are unchanged by optimization transformations" begin
    for θ in m.parameters
        if θ.fixed
            @test θ.value == transform_to_real_line(θ)
            @test θ.value == transform_to_model_space(θ, θ.value)
        end
    end
end


# settings
# settings - boolean, string, and number. adding to model. overwriting. filestrings. testing/not testing.
n_mh_blocks = Setting(:n_mh_blocks, 22) # short constructor
reoptimize = Setting(:reoptimize, false)
vint = Setting(:data_vintage, "REF", true, "vint", "Date of data") # full constructor

@testset "Check settings corresponding to parameters" begin
    @test promote_rule(Setting{Float64}, Float16) == Float64
    @test promote_rule(Setting{Bool}, Bool) == Bool
    @test promote_rule(Setting{String}, String) == String
    @test convert(Int64, n_mh_blocks) == 22
    @test convert(String, vint) == "REF"

    @test get_setting(m, :n_mh_blocks) == m.settings[:n_mh_blocks].value
    m.testing = true
    @test get_setting(m, :n_mh_blocks) == m.test_settings[:n_mh_blocks].value
    @test ModelConstructors.filestring(m) == "_test"

    m.testing = false
    m <= Setting(:n_mh_blocks, 5, true, "mhbk", "Number of blocks for Metropolis-Hastings")
    @test m.settings[:n_mh_blocks].value == 5
    @test occursin(r"^\s*_mhbk=5_vint=(\d{6})", ModelConstructors.filestring(m))
    ModelConstructors.filestring(m, "key=val")
    ModelConstructors.filestring(m, ["key=val", "foo=bar"])
    m.testing = true

    # Overwriting settings
    a = gensym() # unlikely to clash
    b = gensym()
    m <= Setting(a, 0, true, "abcd", "a")
    m <= Setting(a, 1)
    @test m.test_settings[a].value == 1
    @test m.test_settings[a].print == true
    @test m.test_settings[a].code == "abcd"
    @test m.test_settings[a].description == "a"
    m <= Setting(b, 2, false, "", "b")
    m <= Setting(b, 3, true, "abcd", "b1")
    @test m.test_settings[b].value == 3
    @test m.test_settings[b].print == true
    @test m.test_settings[b].code == "abcd"
    @test m.test_settings[b].description == "b1"
end

# model paths. all this should work without errors
m.testing = true
addl_strings = ["foo=bar", "hat=head", "city=newyork"]
@testset "Check proper model paths" begin
    for fn in [:rawpath, :workpath, :tablespath, :figurespath]
        @eval $(fn)(m, "test")
        @eval $(fn)(m, "test", "temp")
        @eval $(fn)(m, "test", "temp", addl_strings)
    end
end=#
