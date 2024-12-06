# Advent of Code 2024

Just some coding fun (still Julia 🤭)

# Benchmarks

Goal: execute under 1 ms.

| Day | Part 1 | Part 2 | Performance | Optimization notes                                 |
| --- | ------ | ------ | ----------- | -------------------------------------------------- |
| 1   | 208 ns | 139 μs | optimized   | avoid broadcasting that allocates array            |
| 2   | 6 μs   | 61 μs  | optimized   | avoid creating arrays that just skip an element    |
| 3   | 169 μs | 128 μs |             |                                                    |
| 4   | 908 μs | 369 μs | optimized   | avoid creating temporary strings just for matching |
| 5   | 1 μs   | 12 μs  | optimized   | use custom O(1) rule lookup with bit array         |
| 6   | 560 μs | 9.8s   |             | embarrassingly slow part2 :-p                      |
