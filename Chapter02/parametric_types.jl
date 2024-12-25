# Parametric type examples

abstract type Asset end
abstract type Investment <: Asset end
abstract type Equity <: Investment end

struct Stock <: Equity
    symbol::String
    name::String
end

struct StockHolding{T <: Real} 
    stock::Stock
    quantity::T
end

#= REPL

julia> stock = Stock("AAPL", "Apple, Inc.");

julia> holding = StockHolding(stock, 100)
StockHolding{Int64}(Stock("AAPL", "Apple, Inc."), 100)

julia> holding = StockHolding(stock, 100.00)
StockHolding{Float64}(Stock("AAPL", "Apple, Inc."), 100.0)

julia> holding = StockHolding(stock, 100 // 3)
StockHolding{Rational}(Stock("AAPL", "Apple, Inc."), 100//3)
=#

#------------------------------------------------------------------------------

struct MarketStockHolding{T <: Real, P <: AbstractFloat} 
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end

#= REPL
julia> holding = MarketStockHolding(stock, 100, 180.00, 18000.00)
MarketStockHolding{Int64,Float64}(Stock("AAPL", "Apple, Inc."), 100, 180.0, 18000.0)

julia> holding = MarketStockHolding(stock, 100, 180.00, 18000)
ERROR: MethodError: no method matching MarketStockHolding(::Stock, ::Int64, ::Float64, ::Int64)
=#

#------------------------------------------------------------------------------

abstract type Holding{P} end
# 这里不能抽象出 包含price 和 marketvalue 的 基类型
mutable struct MarketStockHolding2{T, P} <: Holding{P}
    stock::Stock
    quantity::T
    price::P
    marketvalue::P
end

mutable struct CashHolding{P} <: Holding{P}
    currency::String
    amount::P
    marketvalue::P
end

#= REPL
julia> stock = Stock("AAPL", "Apple, Inc.");

julia> certificate_in_the_safe = MarketStockHolding2(stock, 100, 180.00, 18000.00)
MarketStockHolding2{Int64,Float64}(Stock("AAPL", "Apple, Inc."), 100, 180.0, 18000.0)

julia> MarketStockHolding2{Int64,Float64} <: Holding{Float64}
true

julia> certificate_in_the_safe isa Holding{Float64}
true

julia> Holding{Float64} <: Holding
true

julia> Holding{Int} <: Holding
true
=#