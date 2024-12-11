function input(filename)
    readlines(filename)
end

function transform(x)
    if x == 0
        return 1
    elseif ndigits(x) % 2 == 0
        divisor = 10^(ndigits(x) ÷ 2)
        left = x ÷ divisor
        right = x % divisor
        return (left, right)
    else
        return 2024 * x
    end
end

blink(xs) = Iterators.flatten(transform(x) for x in xs) |> collect

part1(xs, n) = n == 0 ? xs : part1(blink(xs), n - 1)

#=
Part 1 implementation is too memory intensive since it keeps track
of all stones.

Part 2 is the same problem with a scalability issue (75 levels).
So we cannot use the same logic from part 1.

I had imagined that many numbers can be repeated so we can
compress them into a Dict of (x => cnt) where n is the number
being tracked and cnt is the number of stones with that number.
=#
function part2(xs, n)
    stones = Dict(x => 1 for x in xs)
    for i in 1:n
        # Warning: must `collect` here since the Dict is mutated
        for (x, cnt) in collect(stones)
            v = transform(x)
            if v isa Number
                add_stone!(stones, v, cnt)
            else
                v1, v2 = v
                add_stone!(stones, v1, cnt)
                add_stone!(stones, v2, cnt)
            end
            remove_stone!(stones, x, cnt)
        end
    end
    return stones |> values |> sum
end

function add_stone!(dct, x, cnt)
    if haskey(dct, x)
        dct[x] += cnt
    else
        dct[x] = cnt
    end
end

function remove_stone!(dct, x, cnt)
    if haskey(dct, x)
        if dct[x] > cnt
            dct[x] -= cnt
        else
            delete!(dct, x)
        end
    else
        @error "Stone $x not found"
    end
end

#=
julia> @btime part1([475449, 2599064, 213, 0, 2, 65, 5755, 51149],25) |> length
  7.948 ms (338 allocations: 10.61 MiB)
193269

julia> @btime part2([475449, 2599064, 213, 0, 2, 65, 5755, 51149],75)
  10.283 ms (247 allocations: 2.44 MiB)
228449040027793
=#

# Optimization notes
# - Avoid dynamic dispatch by inlining the transform function logic
#
# Ideas
# - Tried Dictionaries.jl -> worse
# - Tried IdDict -> worse
function part2_fast(xs, n)
    stones = Dict(x => 1 for x in xs)
    for i in 1:n
        for (x, cnt) in collect(stones)
            if x == 0
                add_stone!(stones, 1, cnt)
            elseif ndigits(x) % 2 == 0
                divisor = 10^(ndigits(x) ÷ 2)
                v1 = x ÷ divisor
                v2 = x % divisor
                add_stone!(stones, v1, cnt)
                add_stone!(stones, v2, cnt)
            else
                add_stone!(stones, 2024 * x, cnt)
            end
            remove_stone!(stones, x, cnt)
        end
    end
    return stones |> values |> sum
end

#=
julia> @btime part2_fast([475449, 2599064, 213, 0, 2, 65, 5755, 51149],75)
  9.930 ms (247 allocations: 2.44 MiB)
228449040027793
=#
