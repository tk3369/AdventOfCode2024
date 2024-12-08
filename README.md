# Advent of Code 2024

Just some coding fun (still Julia 🤭)

# Benchmarks

Goal: execute under 1 ms.

| Day | Part 1 | Part 2 | Performance       | Optimization notes                                        |
| --- | ------ | ------ | ----------------- | --------------------------------------------------------- |
| 1   | 208 ns | 139 μs | optimized         | avoid broadcasting that allocates array                   |
| 2   | 6 μs   | 61 μs  | optimized         | avoid creating arrays that just skip an element           |
| 3   | 169 μs | 128 μs |                   |                                                           |
| 4   | 908 μs | 369 μs | optimized         | avoid creating temporary strings just for matching        |
| 5   | 1 μs   | 12 μs  | optimized         | use custom O(1) rule lookup with bit array                |
| 6   | 101 μs | 610ms  | needs improvement | still pretty slow                                         |
| 7   | 1 ms   | 645 ms | needs improvement | binary/ternary system                                     |
| 8   | 11 μs  | 19 μs  | optimized         | fewer allocations to store Int tuples than CartesianIndex |

My machine:
```
julia> versioninfo()
Julia Version 1.11.2
Commit 5e9a32e7af2 (2024-12-01 20:02 UTC)
Build Info:
  Official https://julialang.org/ release
Platform Info:
  OS: macOS (arm64-apple-darwin24.0.0)
  CPU: 8 × Apple M1
  WORD_SIZE: 64
  LLVM: libLLVM-16.0.6 (ORCJIT, apple-m1)
Threads: 4 default, 0 interactive, 2 GC (on 4 virtual cores)
```
