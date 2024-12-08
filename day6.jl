function input(filename)
    grid = permutedims(stack(readlines(filename)))
    pos = findfirst(==('^'), grid)
    grid[pos] = '.'
    return grid, pos
end

grid, pos = input("day6.txt")

const CI = CartesianIndex

# Returns true when it's possible to move forward
# Boundary check is done separately
can_move(pos, step, grid) = grid[pos+step] === '.'

# Returns true when moving forward will get off-board
on_edge(pos, step, board) = pos + step ∉ board

# Keep moving forward until getting off-board (success)
# or turn right when it's directly in front of an obstacle.
# Maintian a set of positions so we can count how many
# were visited.
function part1(grid, pos)
    board = CartesianIndices(grid)
    dir = 1 # up = 1, right = 2, down = 3, left = 4
    steps = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
    visited = Set([pos])
    while true
        if on_edge(pos, steps[dir], board)
            break
        end
        if can_move(pos, steps[dir], grid)
            pos += steps[dir]
            push!(visited, pos)
        else
            dir = dir % 4 + 1
        end
    end
    return length(visited)
end

# We know it's stuck whenever it comes back to a previously
# visited position at the same direction. So we must track
# (pos,dir) tuple now unlike part 1.
function stuck(grid, pos, obstacle)
    board = CartesianIndices(grid)
    dir = 1 # up = 1, right = 2, down = 3, left = 4
    steps = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
    grid = copy(grid) # make a copy to inject an obstacle
    grid[obstacle] = 'O'
    visited = Set([(pos, dir)])
    while true
        if on_edge(pos, steps[dir], board)
            break
        end
        if can_move(pos, steps[dir], grid)
            pos += steps[dir]
            (pos, dir) ∈ visited && return true
            push!(visited, (pos, dir))
        else
            dir = dir % 4 + 1
        end
    end
    return false
end

function part2(grid, pos)
    board = CartesianIndices(grid)
    sum(stuck(grid, pos, c) for c in board if grid[c] == '.')
end

#=
julia> @btime part1($grid, $pos)
  101.959 μs (27 allocations: 363.36 KiB)
4973

julia> @btime part2($grid, $pos)
  2.671 s (472530 allocations: 8.54 GiB)
1482
=#

# Optimization: only need to consider obstacle positions that are
# in the original path.

# Same as part1 but returns visited positions
function get_original_visited(grid, pos)
    board = CartesianIndices(grid)
    dir = 1 # up = 1, right = 2, down = 3, left = 4
    steps = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
    visited = Set([pos])
    while true
        if on_edge(pos, steps[dir], board)
            break
        end
        if can_move(pos, steps[dir], grid)
            pos += steps[dir]
            push!(visited, pos)
        else
            dir = dir % 4 + 1
        end
    end
    return visited
end

function part2_fast(grid, pos)
    sum(stuck(grid, pos, c) for c in get_original_visited(grid, pos))
end

#=
julia> @btime part2_fast($grid, $pos)
  609.383 ms (139467 allocations: 2.18 GiB)
1482
=#

# Fastest version (some ideas from Peter Lustig)

on_edge(target, board) = target ∉ board
can_move(target, grid) = grid[target] == '.'

function can_move_with_obstacle(target, grid, obstacle)
    return grid[target] == '.' && target != obstacle
end

# make_container(grid) = Set{Tuple{Tuple{Int,Int},Int}}()
# is_in(container, pos, dir) = (pos.I, dir) ∈ container
# do_push!(container, pos, dir) = push!(container, (pos.I, dir))

# Abstraction for storing visited cells
make_container(grid) = falses(size(grid, 1), size(grid, 2), 4)
is_in(container, pos, dir) = container[pos[1], pos[2], dir] == true
do_push!(container, pos, dir) = container[pos[1], pos[2], dir] = true

function stuck2(grid, pos, obstacle)
    board = CartesianIndices(grid)
    dir = 1 # up = 1, right = 2, down = 3, left = 4
    steps = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
    visited = make_container(grid)
    do_push!(visited, pos, dir)
    while true
        target = pos + steps[dir]
        target ∉ board && break
        if can_move_with_obstacle(target, grid, obstacle)
            pos = target
            is_in(visited, pos, dir) && return true
            do_push!(visited, pos, dir)
        else
            dir = dir % 4 + 1
        end
    end
    return false
end

function part2_fastest(grid, pos)
    obstacles = [o for o in get_original_visited(grid, pos)]
    results = falses(length(obstacles))
    Threads.@threads for i in 1:length(obstacles)
        results[i] = stuck2(grid, pos, obstacles[i])
    end
    return sum(results)
end

#=
julia> @btime part2_fastest($grid, $pos)
  12.217 ms (19947 allocations: 41.64 MiB)
1482
=#

# ====== work in progress animation ======

# using Luxor

# function animate(grid, pos)
#     sz = 50
#     height, width = size(grid)

#     function draw_board()
#         origin(Point(-sz * width ÷ 2, -sz * height ÷ 2)) # reset origin to top left
#         background("white")
#         sethue("black")
#         for h in 0:height-1
#             for w in 0:width-1
#                 if grid[h+1, w+1] != '.'
#                     box(Point(w * sz, h * sz), Point((w + 1) * sz, (h + 1) * sz); action=:stroke)
#                 end
#             end
#         end
#     end

#     function draw_frame(scene::Scene, framenumber::Int64)
#         draw_board()
#         # board = CartesianIndices(grid)
#         # dir = 1 # up = 1, right = 2, down = 3, left = 4
#         # steps = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
#         # while true
#         #     if on_edge(pos, steps[dir], board)
#         #         break
#         #     end
#         #     if can_move(pos, steps[dir], grid)
#         #         pos += steps[dir]
#         #     else
#         #         dir = dir % 4 + 1
#         #     end
#         # end
#         # return length(visited)
#     end

#     movie = Movie(width * sz, height * sz, "mymovie")
#     Luxor.animate(movie, [Scene(movie, draw_frame, 1:1)],
#         creategif=true, pathname="day6.gif",
#         framerate=15)
# end
