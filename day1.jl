function input()
    pairs = [parse.(Int, split(line)) for line in readlines("day1.txt")]
    x = sort([row[1] for row in pairs])
    y = sort([row[2] for row in pairs])
    return x, y
end

part1(x, y) = sum(abs, x .- y)

part2(x, y) = sum(value * count(==(value), y) for value in x)

