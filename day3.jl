function input()
    readlines("day3.txt")
end

function multiply(s)
    m = match(r"mul\(([0-9]+),([0-9]+)\)", s)
    return parse(Int, m.captures[1]) * parse(Int, m.captures[2])
end

clean(line) = [x.match for x in eachmatch(r"mul\([0-9]+,[0-9]+\)", line)]

part1(data) = sum(sum(multiply.(clean(line))) for line in data)

# part 2

clean2(line) = [x.match for x in eachmatch(r"mul\([0-9]+,[0-9]+\)|do\(\)|don't\(\)", line)]

function part2(data)
    total = 0
    enabled = true
    for line in data
        for instruction in clean2(line)
            if enabled && startswith(instruction, "mul")
                total += multiply(instruction)
            elseif instruction == "do()"
                enabled = true
            elseif instruction == "don't()"
                enabled = false
            end
        end
    end
    return total
end

#=
julia> @btime part1($data);
  168.917 μs (6828 allocations: 314.06 KiB)

julia> @btime part2($data);
  128.291 μs (4682 allocations: 222.53 KiB)
=#

using Luxor
using Luxor: Movie, Scene, Point, text, sethue, move, background

function draw(data)
    sz = 400
    ops = reduce(vcat, clean2(line) for line in data)
    len = length(ops)
    mymovie = Movie(sz, sz, "mymovie")
    xs = [rand([-1, 1]) * rand(1:sz) for _ in 1:len]
    ys = [rand([-1, 1]) * rand(1:sz) for _ in 1:len]
    fs = [rand(18:40) for _ in 1:len]
    cs = [rand(["blue", "red", "green", "purple", "yellow", "pink"]) for _ in 1:len]

    function frame(scene::Scene, framenumber::Int64)
        background("white")
        fontface("Georgia")
        fontsize(30)
        text("Advent of Code Day 3", Point(0, -sz / 2 + 30); halign=:center)
        fontface("Helvetica")
        for i in 1:framenumber
            if framenumber <= len
                sethue(cs[i])
                fontsize(fs[i])
                text(ops[i], Point(xs[i], ys[i]))
            else # final frames
                fontsize(20)
                sethue("blue")
                text("Corrupted Memory :-(", O; halign=:center, valign=:middle)
            end
        end
    end

    animate(mymovie, [Scene(mymovie, frame, 1:(len+45*3))],
        creategif=true, pathname="day3.gif",
        framerate=45)
end
