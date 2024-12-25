Core._expr

DataType
big"123"

macro my_str(ex) # 返回 `非表达式`
    return uppercase(ex) # 或者 :(uppercase($ex))
end

macro my_macro(ex) # return `non-Expr`
    return uppercase(ex) # or :(uppercase($ex))
    #=
        CodeInfo(
        1 ─      nothing
        │   %2 = Main.uppercase(ex)
        └──      return %2
        )
    =#
end

macro my_macro2(ex) # return Expr
    return :(uppercase($ex))
    #=
        CodeInfo(
        1 ─      nothing
        │   %2 = Core._expr(:call, :uppercase, ex)
        └──      return %2
        )
    =#
end

macro normal(n)
    @show n
    n
end

my"fuck"

@generated function doubled(x)
    if x<: AbstractFloat
        return :(println("doubled(x) with ", x))
    else
        return :(2 * x)
    end
end


# 如何实现
@ff sin(x) = sin(sin(x))


macro ff(ex)
    @assert ex.head == :call
    @assert length(ex.args) == 2
    ex_new = copy(ex)
    ex_new.args[2] = ex
    return ex_new
end

macro ff_mutate(ex)
    @assert ex.head == :call
    @assert length(ex.args) == 2
    old = copy(ex)
    ex.args[2] = old
    return ex
end