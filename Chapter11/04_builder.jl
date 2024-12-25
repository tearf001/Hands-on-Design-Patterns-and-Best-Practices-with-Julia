module BuilderExample

# Car parts
struct Engine
    value 
end

struct Wheels 
    value 
end

struct Chassis 
    value 
end

# Easy syntax for Union{T, Nothing}
const Maybe{T} = Union{T,Nothing}

# Car object
mutable struct Car 
    engine::Maybe{Engine}
    wheels::Maybe{Wheels}
    chassis::Maybe{Chassis}
end

Car() = Car(nothing, nothing, nothing)

function add(wheels::Wheels)
    return function (c::Car)
        c.wheels = wheels
        return c
    end
end

function add(engine::Engine)
    return function (c::Car)
        c.engine = engine
        return c
    end
end

function add(chassis::Chassis)
    return function (c::Car)
        c.chassis = chassis
        return c
    end
end

function test1()
    car = Car() |>
        add(Engine("4-cylinder 1600cc Engine")) |>
        add(Wheels("4x 20-inch wide wheels")) |>
        add(Chassis("Roadster Chassis"))
    println(car)
end

function test2()
    car = Car()
    car.engine = Engine("4-cylinder 1600cc Engine")
    car.wheels = Wheels("4x 20-inch wide wheels")
    car.chassis = Chassis("Roadster Chassis")
    println(car)
end

struct FullyCurried end

function set(symbol::Symbol, val::Any, c::Car)
    setfield!(c, symbol, val)
    return c
end

function set(c::Car, symbol::Symbol, val::Any)
    setfield!(c, symbol, val)
    return c
end

partial(f, args...) = x -> f(args..., x)
rpartial(f, args...) = (x...) -> f(x..., args...)

function test3()
    car = Car() |>
        partial(set, :engine, Engine("4-缸1800cc引擎")) |>
        partial(set, :wheels, Wheels("4x 20-inch wide 固特异轮胎")) |>
        partial(set, :chassis, Chassis("Roadster Chassis底盘"))
    println(car)
end

function test4()
    car = Car() |>
        rpartial(set, :engine, Engine("4-缸1800cc引擎")) |>
        rpartial(set, :wheels, Wheels("4x 20-inch wide 固特异轮胎")) |>
        rpartial(set, :chassis, Chassis("Roadster Chassis底盘"))
    println(car)
end

macro curried(fdef)
    f = fdef.args[1].args[1]  # 函数名
    fargs = fdef.args[1].args[2:end]  # 函数参数，包括位置参数和关键字参数
    
    pos_args = [] # 位置参数
    kw_args = [] # 关键字参数
    for arg in fargs
        if isa(arg, Expr) && arg.head == :parameters
           for kwarg in arg.args
               push!(kw_args,kwarg)
           end
        else
            push!(pos_args, arg)
        end
    end

    arity = length(pos_args) #位置参数的数量
    body = fdef.args[2]  # 函数体
    err_str = "Too many args for func $f. Expected $arity positional args."

    quote
        begin
            function $f(args...; kwargs...)
                if length(args) < $arity
                    # 返回一个可以接收剩余参数的偏函数
                    (x...; kw...) -> $f((args..., x...)...; merge(kwargs, kw)...)
                elseif length(args) == $arity
                  # 位置参数已满，调用真正的函数
                  $f(FullyCurried(), args...; kwargs...)
                else
                    throw($err_str)
                end
            end

            # 真正执行的函数
            function $f(::FullyCurried, $(pos_args...); $(kw_args...))
               $body
            end
        end
    end |> esc
end

@curried function builder(symbol::Symbol, val::Any, c::Car)
    setfield!(c, symbol, val)
    return c
end
# curried version 在这里有点大才小用
function test_with_curried()
    car = Car() |> 
    builder(:engine, Engine("4-缸1800cc引擎"))   |> 
    builder(:wheels, Wheels("4x 20-inch wide 固特异轮胎"))     |>
    builder(:chassis, Chassis("Roadster Chassis底盘"))
    println(car)
end

function test_with_curried2()
    car = Car() |> 
        builder(:engine)(Engine("4-缸1800cc引擎")) |> 
        builder(:wheels)(Wheels("4x 20-inch wide 固特异轮胎")) |>
        builder(:chassis)(Chassis("Roadster Chassis底盘"))
    println(car)
end

end #module

using .BuilderExample
println("------ BuilderExample ----------------")
println("------ TEST1 ADD callback ----------------")
BuilderExample.test1()
println("------ TEST2 procedure ----------------")
BuilderExample.test2()
println("------ TEST3 partial ----------------")
BuilderExample.test3()
println("------ TEST4 rpartial ----------------")
BuilderExample.test4()
println("------ TEST5 curried ----------------")
BuilderExample.test_with_curried()
println("------ TEST6 curried ()()----------------")
BuilderExample.test_with_curried2()

