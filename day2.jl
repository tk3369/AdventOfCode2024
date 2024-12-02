function input()
    return [parse.(Int, split(line)) for line in readlines("day2.txt")]
end

function is_safe(levels)
    A = diff(levels)
    return (all(>(0), A) || all(<(0), A)) && all(abs(x) in 1:3 for x in A)
end

function is_safe_by_removing_one_level(levels)
    combinations = [
        [levels[i] for i in 1:length(levels) if i != skipped]
        for skipped in 1:length(levels)
    ]
    return is_safe(levels) || any(is_safe, combinations)
end

data = input()

part1(data) = sum(is_safe, data)

part2(data) = sum(is_safe_by_removing_one_level, data)

#= Benchmark results:

julia> @benchmark part1($data)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  25.750 μs …  15.895 ms  ┊ GC (min … max):  0.00% … 99.61%
 Time  (median):     29.833 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   35.578 μs ± 246.633 μs  ┊ GC (mean ± σ):  14.57% ±  2.22%

    ▇█▃       ▃
  ▁▄███▄▂▂▂▂▃▅█▇▅▄▅▇▇▇█▇▆▅▆▅▄▄▄▅▄▃▃▃▃▃▂▂▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▁▁▁▁▁▁ ▃
  25.8 μs         Histogram: frequency by time         39.2 μs <

 Memory estimate: 101.44 KiB, allocs estimate: 2000.

julia> @benchmark part2($data)
BenchmarkTools.Trial: 5723 samples with 1 evaluation.
 Range (min … max):  676.292 μs …  24.542 ms  ┊ GC (min … max):  0.00% … 96.59%
 Time  (median):     703.459 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   870.484 μs ± 848.278 μs  ┊ GC (mean ± σ):  12.05% ± 13.65%

  █▄▂▂                                                          ▁
  ██████▆▆▆▄▅▄▅▃▄▄▁▁▄▃▄▄▅▁▁▁▄▄▁▄▅▄▅▁▄▄▁▄▄▃▃▅▄▃▁▄▄▅▅▇▇▆▅▅▅▃▃▄▇▇▇ █
  676 μs        Histogram: log(frequency) by time       4.16 ms <

 Memory estimate: 1.62 MiB, allocs estimate: 32681.

 =#

function is_safe_fast(levels)
    increasing = levels[2] > levels[1]
    return increasing ?
           all(levels[i] < levels[i+1] && levels[i+1] - levels[i] ∈ 1:3 for i in 1:(length(levels)-1)) :
           all(levels[i] > levels[i+1] && levels[i] - levels[i+1] ∈ 1:3 for i in 1:(length(levels)-1))
end

struct SkipArray
    array::Vector{Int}
    skip_index::Int
end

Base.length(A::SkipArray) = length(A.array) - 1
Base.getindex(A::SkipArray, idx::Int) = idx >= A.skip_index ? A.array[idx+1] : A.array[idx]

function is_safe_by_removing_one_level_fast(levels)
    is_safe_fast(levels) && return true
    return any(is_safe_fast, (SkipArray(levels, i) for i in 1:length(levels)))
end

part1_fast(data) = sum(is_safe_fast, data)

part2_fast(data) = sum(is_safe_by_removing_one_level_fast, data)

#= Fast benchmark results
julia> @benchmark part1_fast($data)
BenchmarkTools.Trial: 10000 samples with 5 evaluations.
 Range (min … max):  5.958 μs …  13.233 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     6.125 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   6.141 μs ± 170.997 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

           ▁   █▂▁▁▁▇▁▁ ▃
  ▂▂▂▂▄▃▄▅▅█▇▇███████████▅▅▄▄▅▃▃▃▃▂▂▂▂▂▂▂▂▂▂▂▁▂▂▁▁▂▁▂▂▁▁▁▁▁▁▂ ▃
  5.96 μs         Histogram: frequency by time        6.56 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.

julia> @benchmark part2_fast($data)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  60.708 μs … 106.875 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     61.959 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   62.000 μs ±   1.435 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

   ▁▂▄▅▂        ▂█▆          ▂▂
  ▄█████▇▅▄▃▂▂▂▅███▇▄▃▃▂▂▂▂▄▆██▅▃▃▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂▂▂ ▃
  60.7 μs         Histogram: frequency by time         65.8 μs <

 Memory estimate: 0 bytes, allocs estimate: 0.
=#
