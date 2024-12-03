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
