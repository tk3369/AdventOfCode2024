const CI = CartesianIndex

function input(filename)
    grid = permutedims(stack(readlines(filename)))
    board = CartesianIndices(grid)
    return grid, board
end

function find_islands(grid, board)
    islands = []
    visited = falses(size(grid))
    while true
        c = findfirst(==(false), visited)
        isnothing(c) && break
        _, _, island = fence!(grid, board, c, visited)
        push!(islands, island)
    end
    return islands
end

# visited - global memory
# island - local memory
function fence!(grid, board, pos, visited, island=Set{CartesianIndex}())
    dir = (CI(0, -1), CI(0, 1), CI(-1, 0), CI(1, 0))
    area = 0
    perimeter = 0
    plant = grid[pos]
    visited[pos] = true
    push!(island, pos)
    area += 1
    for d in dir
        neighbor_pos = pos + d
        if neighbor_pos ∉ island # do not revisit plots in the same island
            if neighbor_pos ∈ board
                neighbor_plant = grid[neighbor_pos]
                if neighbor_plant != plant
                    perimeter += 1
                else # recurse when same plant
                    v1, v2 = fence!(grid, board, neighbor_pos, visited, island)
                    area += v1
                    perimeter += v2
                end
            else # outside the edge so it must be fenced
                perimeter += 1
            end
        end
    end
    return area, perimeter, island
end

function part1(grid, board)
    total = 0
    visited = falses(size(grid))
    while true
        c = findfirst(==(false), visited)
        isnothing(c) && break
        color = grid[c]
        area, perimeter, island = fence!(grid, board, c, visited)
        total += area * perimeter
        #@info area, perimeter, c, color, total
    end
    return total
end

#=
julia> grid, board = input("day12.txt")
(['L' 'L' … 'D' 'D'; 'L' 'L' … 'D' 'D'; … ; 'R' 'R' … 'U' 'U'; 'R' 'R' … 'U' 'U'], CartesianIndices((140, 140)))



=#
