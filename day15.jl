const EMPTY = '.'
const BOX = 'O'
const ROBOT = '@'
const WALL = '#'

function input(filename)
    grid_lines, inst = split(read(filename, String), "\n\n")
    grid = permutedims(stack(split(grid_lines, "\n")))
    grid = grid[2:end-1, 2:end-1]
    robot = findfirst(==(ROBOT), grid)
    inst = replace(inst, "\n" => "")
    CI = CartesianIndex
    dct = Dict('^' => CI(-1, 0), 'v' => CI(1, 0), '<' => CI(0, -1), '>' => CI(0, 1))
    inst = [dct[c] for c in inst]
    return grid, inst, robot
end


is_empty_space(grid, pos) = grid[pos] == EMPTY
is_box(grid, pos) = grid[pos] == BOX
is_wall(grid, pos) = grid[pos] == WALL
is_edge(board, pos) = pos ∉ board

# `dir` is a CartesianIndex in the direction of pushing ahead.
function push_ahead!(grid, pos, dir)
    board = CartesianIndices(grid)
    next_pos = pos + dir
    if is_edge(board, next_pos) || is_wall(grid, next_pos)
        # do nothing
    elseif is_empty_space(grid, next_pos)
        grid[next_pos] = ROBOT
        grid[pos] = EMPTY
        pos = next_pos
    else # must be a box here
        farthest_pos = next_pos + dir
        while !is_edge(board, farthest_pos) && !is_wall(grid, farthest_pos) &&
                  is_box(grid, farthest_pos)
            farthest_pos = farthest_pos + dir
        end
        if is_edge(board, farthest_pos) || is_wall(grid, farthest_pos)
            # cannot move, abandon
        else
            # must be empty space
            # so, we just push all boxes.
            grid[farthest_pos] = BOX
            grid[next_pos] = ROBOT
            grid[pos] = EMPTY
            pos = next_pos
        end
    end
    return pos
end

function print_grid(grid)
    for i in 1:size(grid, 1)
        println(join(grid[i, :]))
    end
end

gps(pos) = 100 * pos[1] + pos[2]

function part1(grid, inst, robot)
    # println("Initial state:")
    # print_grid(grid)
    pos = robot
    for dir ∈ inst
        pos = push_ahead!(grid, pos, dir)
        # println()
        # println(dir)
        # print_grid(grid)
    end
    return sum(gps(pos) for pos in CartesianIndices(grid) if is_box(grid, pos))
end

grid, inst, robot = input("day15.txt")
part1(copy(grid), inst, robot)

#=
julia> grid, inst, robot = input("day15.txt")
(['.' '.' … '.' '.'; 'O' '.' … '.' '.'; … ; '#' 'O' … '.' '.'; '#' '.' … '.' '#'], CartesianIndex{2}[CartesianIndex(0, -1), CartesianIndex(1, 0), CartesianIndex(1, 0), CartesianIndex(-1, 0), CartesianIndex(0, 1), CartesianIndex(0, -1), CartesianIndex(0, -1), CartesianIndex(1, 0), CartesianIndex(1, 0), CartesianIndex(0, 1)  …  CartesianIndex(0, 1), CartesianIndex(-1, 0), CartesianIndex(0, -1), CartesianIndex(0, -1), CartesianIndex(-1, 0), CartesianIndex(0, -1), CartesianIndex(1, 0), CartesianIndex(0, -1), CartesianIndex(0, 1), CartesianIndex(0, 1)], CartesianIndex(24, 24))

julia> part1(copy(grid), inst, robot)
1516281
=#

#= Part 2 - WIP

Maybe easier to redo the parsing function than widening the array?

widen(line) = replace(line, "#" => "##", "O" => "[]", "@" => "@.", "." => "..")
wide_grid = permutedims(stack([widen(line) for line in split(grid_lines, "\n")]))

function widen_grid(grid)
    h, w = size(grid)
    new_grid = similar(grid, (h, w * 2))
    for i in 1:h
        new_grid[i, 1:2:end-1] = grid[i, 1:end]
        new_grid[i, 2:2:end] = grid[i, 1:end]
    end
    robot = findfirst(==(ROBOT), new_grid)
    new_grid[robot[1], robot[2]+1] = EMPTY
    return new_grid, robot
end


function part2(grid, inst, robot)
    grid, robot = widen_grid(grid)
    println("Initial state:")
    print_grid(grid)
    pos = robot
    for dir ∈ inst
        pos = push_ahead!(grid, pos, dir)
        println()
        println(dir)
        print_grid(grid)
    end
end

=#
