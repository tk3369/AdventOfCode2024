function input(filename)
    grid = permutedims(stack(readlines(filename)))
    pos = findfirst(==('^'), grid)
    grid[pos] = '.'
    return grid, pos
end

grid, pos = input("day6.txt")

CI = CartesianIndex

# Returns true when it's possible to move forward
# Boundary check is done separately
can_move(pos, step, grid) = grid[pos+step] == '.'

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
    CI = CartesianIndex
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
julia> @btime part1(grid, pos)
  559.792 μs (33900 allocations: 1.39 MiB)
4973

julia> @btime part2(grid, pos)
  9.775 s (479492538 allocations: 22.81 GiB)
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
julia> @btime part2($grid, $pos)
  2.750 s (472530 allocations: 8.54 GiB)
1482
=#

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
