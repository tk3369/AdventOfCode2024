const CI = CartesianIndex

function input(filename)
    grid = permutedims(stack(readlines(filename)))
    antennas = [c for c in unique(grid) if c !== '.']
    board = CartesianIndices(grid)
    antennas = [c => [p for p in board if grid[p] == c] for c in antennas]
    return grid, board, antennas
end

data = input("day8.txt")

# Original solution

function part1(data)
    grid, board, antennas = data
    antinodes = Set()
    for (c, pos) in antennas
        for combo in combinations(pos, 2)
            diff = combo[2] - combo[1]
            p1 = combo[1] - diff
            p2 = combo[2] + diff
            p1 ∈ board && push!(antinodes, p1)
            p2 ∈ board && push!(antinodes, p2)
        end
    end
    return length(antinodes)
end

function part2(data)
    grid, board, antennas = data
    antinodes = Set()
    for (c, pos) in antennas
        for combo in combinations(pos, 2)
            diff = combo[2] - combo[1]
            p1 = combo[1]
            while true
                p1 -= diff
                p1 ∉ board && break
                push!(antinodes, p1)
            end
            p2 = combo[2]
            while true
                p2 += diff
                p2 ∉ board && break
                push!(antinodes, p2)
            end
        end
        for p in pos
            push!(antinodes, p)
        end
    end
    return length(antinodes)
end

# Optimized

function go!(antinodes, grid, board, c, pos, op, distance, style)
    for k in 1:typemax(Int)
        p = op(pos, k * distance)
        p ∉ board && break
        push!(antinodes, p.I)
        style == :once && break
    end
end

function solve(data, style)
    grid, board, antennas = data
    antinodes = Set{Tuple{Int,Int}}() # no need to store CI (more allocations)
    for (c, positions) in antennas
        for (p1, p2) in combinations(positions, 2)
            distance = p2 - p1
            go!(antinodes, grid, board, c, p1, -, distance, style)
            go!(antinodes, grid, board, c, p2, +, distance, style)
        end
        if style == :forever
            for p in positions
                push!(antinodes, p.I)
            end
        end
    end
    return length(antinodes)
end

part1_fast(data) = solve(data, :once)
part2_fast(data) = solve(data, :forever)

#=
julia> @btime part1_clean($data)
  15.834 μs (1405 allocations: 60.55 KiB)
252

julia> @btime part2_clean($data)
  41.750 μs (3358 allocations: 148.06 KiB)
839
=#
