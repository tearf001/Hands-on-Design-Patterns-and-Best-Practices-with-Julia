module LSys

export @lsys, @生态模拟
export LModel, LState
export add_rule!, next
export test_model, test_state, test_next, test_dsl, test_rabit, test_next_rabit, test_next_rabits
export RABITS_ECOLOGY, RABITS_MODEL

struct LModel
    axiom
    rules:: Dict
end

LModel(axiom) = LModel(axiom, Dict())

function add_rule!(m::LModel, left::T, right::T) where {T<: AbstractString}
    # println("m $m, left: $left($(typeof(left))), right: $right($(typeof(right)))")
    m.rules[left] = split(right, ',')
    m
end

function add_rule!(m::LModel, left::T, right::Vector{Symbol}) where {T<: AbstractString}
    # println("m $m, left: $left($(typeof(left))), right: $right($(typeof(right)))")
    m.rules[left] = right
    m
end

struct LState
    model::LModel
    gen:: Int
    result::Vector{Any}
end

LState(m:: LModel) = LState(m, 1, [m.axiom])

function next(s::LState)
    new_result = []
    # if !Base.haslength(s.result)
    #     println("s. has no length, ", s.result)
    # end
    for r in s.result
        nr = get(s.model.rules, r, r)
        nrarr = (nr isa Tuple || nr isa Array) ? nr : [nr]
        append!(new_result, map(String, nrarr))
    end
    LState(s.model, s.gen + 1, new_result)
end

"Repeated next call"
next(state::LState, n) = n > 0 ? next(next(state), n-1) : state

######### # DSL implementation #########
import MacroTools
"""
The @lsys macro is used to construct a L-System model object [LModel](@ref).
The domain specific language requires a single axiom and a set of rewriting rules.
For example:

```
model = @lsys begin
    axiom : A
    rule  : A → (A, B) # 局限性， 必须使用()和AST的解析相关. 且必须为Symbol
    rule  : B → A
end

model = @lsys begin
    axiom : 🐇
    rule  : 🐇 → (🐇,🐰) # 局限性， 必须使用()和AST的解析相关. 且必须为Symbol
    rule  : 🐰 → 🐇
end

model = @生态模拟 begin
    公理 : 🐇
    规则 : 🐇 → (🐇, 🐰)
    规则 : 🐰 → 🐇
end
```
"""
macro lsys(ex)
    "TODO"
    MacroTools.postwalk(walk, ex)
end

macro 生态模拟(ex)
    MacroTools.postwalk(walkcn, ex)
end
# Walk the AST tree and match expressions.
function walk(ex)
    "TODO"    
    match_axiom = MacroTools.@capture(ex, axiom : sym_)
    if match_axiom
        sym_str = String(sym)
        return :( model = LModel($sym_str) )
    end
    
    match_rule = MacroTools.@capture(ex, rule : original_ → replacement_)
    if match_rule
        # println("expr: ", ex)
        original_str = String(original)
        # @show original_str
        if replacement isa Symbol
            replacement_str = String(replacement)
            # @show replacement_str
            return :(
                add_rule!(model, $original_str, $replacement_str)
            )
        else            
            # println("TODO with replacement: ", replacement, ":", typeof(replacement))
            rcap = MacroTools.@capture(replacement, (Args_))
            if rcap
                # println(Args, typeof(Args), Args |> dump)
                #=Expr
                head: Symbol tuple
                args: Array{Any}((2,))
                    1: Symbol A
                    2: Symbol B
                =#
                ex_ret = :(
                    add_rule!(model, $original_str, $(map(Symbol, Args.args)))
                )
                # println(ex_ret |> dump, ex_ret)
                return ex_ret
            end
        end
    end
    return ex
end

function walkcn(ex)
    match_axiom = MacroTools.@capture(ex, 公理 : sym_)
    if match_axiom
        sym_str = String(sym)
        return :( model = LModel($sym_str) )
    end
    
    match_rule = MacroTools.@capture(ex, 规则 : original_ → replacement_)
    if match_rule
        original_str = String(original)
        if replacement isa Symbol
            replacement_str = String(replacement)
            return :(
                add_rule!(model, $original_str, $replacement_str)
            )
        else
            rcap = MacroTools.@capture(replacement, (Args_))
            if rcap
                ex_ret = :(
                    add_rule!(model, $original_str, $(map(Symbol, Args.args)))
                )
                return ex_ret
            end
        end
    end
    return ex
end

######### show functions ######### 
Base.show(io::IO, m::LModel) = begin
    println(io, "LModel: ", m.axiom)
    println(io, "   axiom: ", m.axiom)
    for k in keys(m.rules)
        println(io, "   rule: ", k, " -> ", join(m.rules[k], ", "))
    end
end

result_exp(state::LState) = join(state.result, ", ")

Base.show(io::IO, s::LState) = print(io, "LState(", s.gen, "): ", result_exp(s))

######### Test model ###########
function test_model()
    m = LModel("A")
    add_rule!(m, "A", "A,B")
    add_rule!(m, "B", "A")
    m
end
function test_rabit()
    m = LModel("🐇")
    add_rule!(m, "🐇", "🐇,🐰")
    add_rule!(m, "🐰", "🐇")
    m
end
# Test state
function test_state()
    m = test_model()
    s = LState(m)
    s
end

# Test next
function test_next()
    s = Ref{LState}()
    s[] = test_state()
    println("inital_state: ", s[])
    
    () -> (s[] = next(s[]))
end

function test_next_rabit()
    s = Ref{LState}()
    rm = test_rabit()
    s[] = LState(rm)
    println("inital_state: ", s[])
    
    () -> (s[] = next(s[]))
end

RABITS_ECOLOGY = :(@生态模拟 begin
    公理 : 🐇
    规则 : 🐇 → (🐇, 🐰)
    规则 : 🐰 → 🐇
end)

Base.show(io::IO, ex::Expr)=println(io, MacroTools.postwalk(MacroTools.rmlines, ex))

RABITS_MODEL = eval(RABITS_ECOLOGY)

function test_next_rabits(model=RABITS_MODEL)
    s = Ref{LState}()
    s[] = LState(model)
    println("混沌之初: ", s[])    
    return () -> (s[] = next(s[]))
end


end # end module
