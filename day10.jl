const CI = CartesianIndex

function input(filename)
    grid = parse.(Int, permutedims(stack(readlines(filename))))
    board = CartesianIndices(grid)
    height, width = size(grid)
    trailheads = [c for c in board if grid[c] == 0]
    return grid, board, trailheads
end

grid, board, trailheads = input("day10.txt")

# Peaks map is a 2D bit array for marking reachable peaks
make_peaks(grid) = falses(size(grid))
mark!(peaks, c) = peaks[c] = true

# A mutable placeholder to updating counter
make_counter() = Ref{Int}(0)
increment!(counter) = counter[] += 1

function score!(grid, board, head, peaks=make_peaks(grid), counter=make_counter())
    this = grid[head]
    if this == 9  # reached highest point
        mark!(peaks, head)
        increment!(counter)
        return
    end
    dir = (CI(-1, 0), CI(1, 0), CI(0, -1), CI(0, 1))
    possibles = head .+ dir
    for n ∈ (d for d in possibles if d ∈ board && grid[d] == this + 1)
        score!(grid, board, n, peaks, counter)
    end
    return sum(peaks), counter[]
end

function part1(grid, board, trailheads)
    return sum(score!(grid, board, t)[1] for t in trailheads)
end

function part2(grid, board, trailheads)
    return sum(score!(grid, board, t)[2] for t in trailheads)
end

#=
julia> @btime part1($grid, $board, $trailheads)
  70.958 μs (804 allocations: 69.09 KiB)
510

julia> @btime part2($grid, $board, $trailheads)
  70.875 μs (804 allocations: 69.09 KiB)
1058
=#
