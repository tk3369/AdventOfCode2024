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

part2(data) = sum(is_safe_by_removing_one_level, input())

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
BenchmarkTools.Trial: 5995 samples with 1 evaluation.
 Range (min … max):  697.708 μs …  29.670 ms  ┊ GC (min … max):  0.00% … 96.96%
 Time  (median):     722.042 μs               ┊ GC (median):     0.00%
 Time  (mean ± σ):   832.755 μs ± 689.178 μs  ┊ GC (mean ± σ):  12.11% ± 14.16%

  █▄▂▁                                                          ▁
  ████▇▆▃▃▃▁▁▁▁▃▁▁▃▁▁▁▄▁▄▃▁▁▃▁▁▁▁▁▁▃▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▅█▇▇▅▁▄▄▅▇█ █
  698 μs        Histogram: log(frequency) by time       3.64 ms <

 Memory estimate: 2.06 MiB, allocs estimate: 38705.

 =#
