# ----------------------------------------------------------------
# Fast processing using same memory space
# ----------------------------------------------------------------

# What's the size again?
#=
julia> size(valuation)
(10000, 3, 100000)
=#

using Statistics: std

# Find standard deviation of each attribute for each security
function std_by_security(valuation)
    (nstates, nattr, n) = size(valuation)
    result = zeros(n, nattr)
    for i in 1:n
        for j in 1:nattr
            result[i, j] = std(valuation[:, j, i])
        end
    end
    return result
end

# does it work properly?

result = std_by_security(valuation);
result[1:5, :]
#=
julia> result = std_by_security(valuation);

julia> result[1:5, :]
5×3 Array{Float64,2}:
 0.286829  0.287704  0.285188
 0.286607  0.288997  0.28929
 0.290648  0.287691  0.288957
 0.288234  0.291172  0.290039
 0.290519  0.289879  0.288602
=#

# performance check: ~5s
using BenchmarkTools
BenchmarkTools.@btime,@time
@benchmark std_by_security($valuation) seconds=30
#=
julia> @benchmark std_by_security($valuation) seconds=30
BenchmarkTools.Trial:
  memory estimate:  22.38 GiB
  allocs estimate:  600002
  --------------
  minimum time:     4.983 s (5.22% GC)
  median time:      5.002 s (5.35% GC)
  mean time:        5.021 s (5.34% GC)
  maximum time:     5.125 s (5.74% GC)
  --------------
  samples:          6
  evals/sample:     1
-------------------------新版---------------------  
BenchmarkTools.Trial: 7 samples with 1 evaluation.
 Range (min … max):  4.462 s …    4.818 s  ┊ GC (min … max): 12.84% … 13.21%
 Time  (median):     4.596 s               ┊ GC (median):    13.28%
 Time  (mean ± σ):   4.616 s ± 115.322 ms  ┊ GC (mean ± σ):  13.24% ±  0.51%

  █            █ █     █      █        █                   █  
  █▁▁▁▁▁▁▁▁▁▁█▁█▁▁▁▁█▁▁▁▁▁█▁▁▁▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█ ▁
  4.46 s         Histogram: frequency by time         4.82 s <
 Memory estimate: 22.37 GiB, allocs estimate: 900003.
=#

# Let's try the distributed way.

# Ensure all processes have loaded necessary packages
@everywhere using Statistics: std

# Distribution version
function std_by_security2(valuation)
    (nstates, nattr, n) = size(valuation)
    result = SharedArray{Float64}(n, nattr)
    @sync @distributed for i in 1:n
        for j in 1:nattr
            result[i, j] = std(valuation[:, j, i])
        end
    end
    return result
end

@benchmark std_by_security2($valuation) seconds=30
#=
julia> result = std_by_security2(valuation);

julia> result[1:5, :]
5×3 Array{Float64,2}:
 0.286829  0.287704  0.285188
 0.286607  0.288997  0.28929
 0.290648  0.287691  0.288957
 0.288234  0.291172  0.290039
 0.290519  0.289879  0.288602

julia> @benchmark std_by_security2($valuation) seconds=30
BenchmarkTools.Trial:
  memory estimate:  228.67 KiB
  allocs estimate:  4812
  --------------
  minimum time:     880.181 ms (0.00% GC)
  median time:      908.827 ms (0.00% GC)
  mean time:        910.734 ms (0.00% GC)
  maximum time:     940.846 ms (0.00% GC)
  --------------
  samples:          33
  evals/sample:     1
  -------------------新版-------------
  BenchmarkTools.Trial: 11 samples with 1 evaluation.
 Range (min … max):  2.885 s …   3.119 s  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     2.947 s              ┊ GC (median):    0.00%
 Time  (mean ± σ):   2.964 s ± 64.141 ms  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▁        █ 
  █▁▁▁▁▁▁▁█▁█▁▁▁██▁█▁▁█▁▁▁▁█▁▁▁▁▁▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█ ▁
  2.88 s         Histogram: frequency by time                3.12 s <
=#

# how much faster?
#=
julia> 4983 / 880
5.6625
=#

rand(2)
using Memoize: memoize
@memoize
using Distributed: @sync
repeat
propertynames;similar;
eachindex;
@isdefined
function heatmap!(s::Simulation{N},new_heatmap::AbstractArray{Float64,N}) where {N}
	length(unique(size(new_heatmap)))==1 ||	error("dimensions must have same size")
	s.heatmap=new_heatmap
	s.stats=(mean =mean(new_heatmap),std=std(new_heatmap))
	return nothing
end
eachindex;objectid;ntuple