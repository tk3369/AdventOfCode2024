function input(filename)
    # p=0,4 v=3,-3
    parse_line(line) = parse.(Int, match(r"p=(\d+),(\d+) v=([-\d]+),([-\d]+)", line).captures)
    return [make_robot(parse_line(line)) for line in readlines(filename)]
end

make_robot(A) = (x=A[1], y=A[2], vx=A[3], vy=A[4])

# p=2,4 v=2,-3 in a grid of 11x7 grid
# since it wraps around, we can add the delta and take remainder.
# In this example, for the y position after 5 seconds:
# 4 + (-3) * 5 = -11, then mod(-11, 7) = 3
# Likewise for x position:
# 2 + 2 * 5 = 12, then mod(12, 11) = 1

# Quadrants are defined as:
# 1 = top-left
# 2 = bottom-left
# 3 = top-right
# 4 = bottom-right
# -1 = mid way either horizontally or vertically
function quadrant(robot, w, h)
    mid_x = w ÷ 2
    mid_y = h ÷ 2
    (robot.x == mid_x || robot.y == mid_y) && return -1 # ignore
    if robot.x < mid_x
        return robot.y < mid_y ? 1 : 2
    else
        return robot.y < mid_y ? 3 : 4
    end
end

function move(robot, w, h, sec)
    return (
        x=mod(robot.x + sec * robot.vx, w),
        y=mod(robot.y + sec * robot.vy, h),
        robot.vx,
        robot.vy,
    )
end

robots = input("day14.txt")

function part1(robots, w, h)
    result = [move(r, w, h, 100) for r in robots]
    cnt = zeros(Int, 4)
    for r in result
        q = quadrant(r, w, h)
        if q >= 0
            cnt[q] += 1
        end
    end
    return cnt, prod(cnt)
end

function make_grid(robots, w, h)
    grid = zeros(Int, h, w)
    for r in robots
        grid[r.y+1, r.x+1] += 1  # ignore overlaps
    end
    return grid
end

flip_upside_down(A) = A[end:-1:1, :]

#=
After examining almost 1,000 images, I noticed a pattern that seems to be
repeating every 101 seconds.
433
534
635
736
837
938

To save time, I tried generating only those specific frames.
julia> part2_plot(robots, 101, 103, 433:101:10000)

And, I found the at 6493 seconds!
=#
using Plots

function part2_plot(robots, w, h, range)
    for i in range
        future_robots = [move(r, w, h, i) for r in robots]
        savefig(heatmap(flip_upside_down(make_grid(future_robots, w, h))),
            "day14_images/$i.png")
    end
end

#=
julia> part1(robots, 101, 103)
([117, 127, 123, 125], 228457125)
=#

# Prior arts

# I had thought about detecting the shape of a tree by checking
# number of spaces on both left & right sides. If it's like a
# Christmas tree then I should see a decreasing number of spaces
# as I traverse from top to botom. However, the end result was
# that I could not find any iteration that gave me sucn shape.

function part2_find_tree(robots, w, h, iterations)
    io = open("day14_out.txt", "w")
    for i in 1:iterations
        robots = [move(r, w, h, 1) for r in robots]
        if robots_arranged_like_triangle(robots, w, h)
            @info i
            println(io, "-"^120 * "\nIteration $i:")
            visualize(io, robots, w, h)
        end
    end
    close(io)
end

function visualize(io, robots, w, h)
    grid = [' ' for _ in 1:h, _ in 1:w]
    for r in robots
        grid[r.y+1, r.x+1] = 'o'
    end
    for y in 1:h
        for x in 1:w
            print(io, grid[y, x])
        end
        println(io)
    end
end

function output(robots, w, h)
    io = open("day14_out.txt", "w")
    for i in 1:100
        robots = [move(r, w, h, 1) for r in robots]
        println(io, "-"^120 * "\nIteration $i:")
        visualize(io, robots, w, h)
    end
    close(io)
end

spaces_left(grid, y, default) = something(findfirst(>(0), grid[y, :]), default)
spaces_right(grid, y, default) = something(findfirst(>(0), reverse(grid[y, :])), default)

function robots_arranged_like_triangle(robots, w, h)
    grid = make_grid(robots, w, h)
    return looks_like_triangle(grid, w, h)
end

function looks_like_triangle(grid, w, h)
    last_left = h
    last_right = h
    for y in 1:h÷3
        this_left = spaces_left(grid, y, w)
        this_right = spaces_right(grid, y, w)
        if this_left > last_left || this_right > last_right
            #@info y last_left last_right this_left this_right
            return false
        end
        last_left = this_left
        last_right = this_right
    end
    return true
end
