function input()
    return [parse.(Int, split(line)) for line in readlines("day2.txt")]
end

function is_safe(levels)
    A = diff(levels)
    return (all(>(0), A) || all(<(0), A)) && all(abs(x) in 1:3 for x in A)
end

function is_safe_by_removing_one_level(levels)
    combinations = [
        [levels[i] for i in 1:length(levels) if i != skipped]
        for skipped in 1:length(levels)
    ]
    return any(is_safe, combinations)
end

# part1
sum(is_safe, input())

# part2
sum(is_safe_by_removing_one_level, input())
