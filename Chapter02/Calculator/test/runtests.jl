using Calculator
using Test

@testset "Calculator.jl" begin
    # Write your own tests here.
    @test Calculator.rate(10, 100) == 10.0
    @test Calculator.interest(100, 0.12) == 100 * (1 + 0.12)
end
