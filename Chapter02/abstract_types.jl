# Abstract type hierarchy
abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

function subtypetree(rootType:: Type, level = 1, indent=4)
    level == 1 && println(rootType)
    for s in subtypes(rootType)
        println(repeat(" ", level * indent) * string(s))
        subtypetree(s, level + 1, indent)
    end
end
# simple functions on abstract types
describe(a::Asset) = "Something valuable"
describe(e::Investment) = "Financial investment"
describe(e::Property) = "Physical property"

# function that just raise an error
"""
    location(p::Property) 

Returns the location of the property as a tuple of (latitude, longitude).
"""
location(p::Property) = error("Location is not defined in the concrete type")
# an empty function
"""
    location(p::Property) 

Returns the location of the property as a tuple of (latitude, longitude).
"""
function location(p::Property) end

# interaction function that works at the abstract type level
function walking_disance(p1::Property, p2::Property)
    loc1 = location(p1)
    loc2 = location(p2)
    return abs(loc1.x - loc2.x) + abs(loc1.y - loc2.y)
end

struct Stock <: Equity
     symbol:: Symbol
     name:: String
end

struct AShare <: Stock # invalid subtyping: can only subtype abstract types.
end

mystocks = [Stock(:a, "A inc"), Stock(:b, "B corp.")]

struct StockHolding 
    stocks::Vector{Stock}
    reason::String
end


mutable struct StockExhange
    stocks:: Vector{Stock}
    reason:: String
end

abstract type Art end

struct Painting <: Art
    artist::String
    title::String
end

struct E1 <: Equity
end
