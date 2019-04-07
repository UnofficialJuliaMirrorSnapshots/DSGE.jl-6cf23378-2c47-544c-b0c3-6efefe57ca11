using DSGE, DataFrames, JLD
using Base.Test

path = dirname(@__FILE__)

# Set up arguments
m = AnSchorfheide(testing = true)
m <= Setting(:date_forecast_start, quartertodate("2015-Q4"))

df, system, z0, P0 = jldopen("$path/../reference/forecast_args.jld", "r") do file
    read(file, "df"), read(file, "system"), read(file, "z0"), read(file, "P0")
end

# Read expected output
exp_kal = jldopen("$path/../reference/filter_out.jld", "r") do file
    read(file, "exp_kal")
end

# Without providing z0 and P0
@testset "Check Kalman filter outputs without initializing state/state-covariance" begin
    kal = DSGE.filter(m, df, system)
    for out in fieldnames(kal)
        expect = exp_kal[out]
        actual = kal[out]

        if ndims(expect) == 0
            @test expect ≈ actual
        else
            @test @test_matrix_approx_eq(expect, actual)
        end
    end
end

# Providing z0 and P0
@testset "Check Kalman filter outputs initializing state/state-covariance" begin
    kal = DSGE.filter(m, df, system, z0, P0)
    for out in fieldnames(kal)
        expect = exp_kal[out]
        actual = kal[out]

        if ndims(expect) == 0
            @test expect ≈ actual
        else
            @test @test_matrix_approx_eq(expect, actual)
        end
    end
end


nothing
