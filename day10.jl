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

using Luxor
using Colors
using Random

function draw(grid)
    colors = range(colorant"lightgreen", stop=colorant"darkgreen", length=10)
    height, width = size(grid)
    tiler = Tiler(500, 500, height, width)
    linear_grid = reshape(permutedims(grid), height * width)
    for (pos, n) in tiler
        sethue(colors[linear_grid[n]+1])
        box(pos, tiler.tilewidth, tiler.tileheight, action=:fill)
    end
    return tiler
end

function animate_puzzle(grid, board, trailheads)
    w, h = 500, 500
    board = CartesianIndices(grid)
    trails = shuffle([hike!(grid, board, t)[1] for t in trailheads])
    total_frames = sum(length(t) for t in trails)
    colors = distinguishable_colors(length(trails))
    head_frames = Dict([sum(length, trails[1:n]) - length(trails[n]) + 1 => colors[n] for n in 1:length(trails)])
    steps = Iterators.flatten(trails) |> collect
    @info "There are $total_frames frames in total"

    function tile_center(tiler, c, board)
        # tile number
        n = (c[1] - 1) * size(board, 1) + c[2]
        dx = tiler.tilewidth ÷ 2
        dy = tiler.tileheight ÷ 2
        top_left = tiler[n][1]
        return Point(top_left.x, top_left.y)
    end

    function frame_impl(scene, frame_number, steps, head_frames)
        tiler = draw(grid)
        for i in 1:frame_number
            c = steps[i]
            if haskey(head_frames, i)
                sethue(head_frames[i])
            end
            circle(tile_center(tiler, c, board), 3, action=:fill)
        end
    end

    movie = Movie(w, h, "day10", 1:total_frames)
    frame = (scene, frame_number) -> frame_impl(scene, frame_number, steps, head_frames)
    animate(movie, [Scene(movie, frame, 1:total_frames)],
        createmovie=true, pathname="day10.mp4")
end

function hike!(grid, board, head, steps=[])
    push!(steps, head)
    this = grid[head]
    if this == 9  # reached highest point
        return steps, true
    end
    dir = (CI(-1, 0), CI(1, 0), CI(0, -1), CI(0, 1))
    possibles = head .+ dir
    found_any = false
    for n ∈ (d for d in possibles if d ∈ board && grid[d] == this + 1)
        _, found = hike!(grid, board, n, steps)
        found || pop!(steps)
        found_any |= found
    end
    return steps, found_any
end

# Upload: https://youtu.be/km1PJGLwcIA
