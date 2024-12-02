function input()
    pairs = [parse.(Int, split(line)) for line in readlines("day1.txt")]
    x = sort([row[1] for row in pairs])
    y = sort([row[2] for row in pairs])
    return x, y
end

x, y = input()

part1(x, y) = sum(abs, x .- y)

part2(x, y) = sum(value * count(==(value), y) for value in x)

#= benchmark results:
julia> @benchmark part1($x, $y)
BenchmarkTools.Trial: 10000 samples with 258 evaluations.
 Range (min … max):  296.349 ns … 36.911 μs  ┊ GC (min … max):  0.00% … 97.54%
 Time  (median):     834.946 ns              ┊ GC (median):     0.00%
 Time  (mean ± σ):     1.175 μs ±  1.534 μs  ┊ GC (mean ± σ):  33.36% ± 22.12%

  ▅▁▂▃█▆▃                                                ▁▁▁▁  ▁
  ████████▇▅▄▁▁▁▁▁▁▁▃▁▁▃▁▁▁▁▁▁▁▃▁▁▃▃▁▃▃▄▄▃▅▆▇▇▇▇▆▄▆▆▆▇████████ █
  296 ns        Histogram: log(frequency) by time      7.14 μs <

 Memory estimate: 7.94 KiB, allocs estimate: 3.

julia> @benchmark part2($x, $y)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  84.833 μs … 144.041 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     86.542 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   86.400 μs ±   2.172 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▆▆▂            ▅█▄▁       ▁              ▂                   ▁
  ████▆▄▃▂▂▄▄▃▃▃▄█████▇█▅▆▅▆██▄▆▆▆█▇▇▅▇▆▆▅▆██▇▅▆▅▅▄▃▄▂▄▃▄▂▆▄▆▅ █
  84.8 μs       Histogram: log(frequency) by time      91.2 μs <

 Memory estimate: 32 bytes, allocs estimate: 2.
=#

part1_fast(x, y) = sum(abs(x[i] - y[i]) for i in 1:length(x))

part2_fast(x, y) = sum(value * count(==(value), y) for value in x)


#= Fast benchmark results

julia> @benchmark part1_fast($x, $y)
BenchmarkTools.Trial: 10000 samples with 565 evaluations.
 Range (min … max):  208.480 ns …   7.946 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     209.441 ns               ┊ GC (median):    0.00%
 Time  (mean ± σ):   233.808 ns ± 137.782 ns  ┊ GC (mean ± σ):  0.00% ± 0.00%

  █▃▂▁▆▄▂▁▁                                                     ▁
  ███████████▇▇▇▇▆▆▆▆▆▆▅▆▆▆▅▆▅▅▅▅▃▃▄▅▅▅▄▄▄▅▅▄▃▄▅▅▄▄▅▅▁▃▁▆▄▄▄▄▁▅ █
  208 ns        Histogram: log(frequency) by time        571 ns <

 Memory estimate: 0 bytes, allocs estimate: 0.

 julia> @benchmark part2_fast($x, $y)
BenchmarkTools.Trial: 10000 samples with 1 evaluation.
 Range (min … max):  139.000 μs … 177.709 μs  ┊ GC (min … max): 0.00% … 0.00%
 Time  (median):     139.125 μs               ┊ GC (median):    0.00%
 Time  (mean ± σ):   139.531 μs ±   1.803 μs  ┊ GC (mean ± σ):  0.00% ± 0.00%

  ▅█
  ██▃▂▂▂▂▂▂▂▂▂▂▂▂▁▂▂▂▂▂▂▂▂▃▃▂▂▂▁▂▂▂▂▂▁▂▂▂▂▂▂▂▂▂▂▂▂▂▁▁▂▂▂▂▂▂▂▁▂▂ ▂
  139 μs           Histogram: frequency by time          146 μs <

 Memory estimate: 16 bytes, allocs estimate: 1.

=#
