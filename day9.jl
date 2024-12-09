input(filename) = [parse(Int, c) for c in chomp(readline(filename))]

data = input("day9.txt")

#=
Brute force algorithm. Explode the compressed form to an array.
Free spaces are reprented as -1. Then, defrag operation simply
move elements around in the array.
=#

function explode(data)
    v = Int[]
    space = -1
    id = 0
    for i in 1:2:length(data)
        val = data[i]
        free = i < length(data) ? data[i+1] : 0
        for i in 1:val
            push!(v, id)
        end
        for i in 1:free
            push!(v, space)
        end
        id += 1
    end
    return v
end

# Start from beginning of the array and find the next gap.
# Then, take the data from the rightmost position (tracked
# by the `k` variable) and move it. If index `k` already
# surpassed index `i` then we know it's done.
function defrag(data)
    space = -1
    data = explode(data)
    k = length(data)
    for i in 1:length(data)
        data[i] >= 0 && continue  # skip used blocks
        while k >= 1
            data[k] >= 0 && break
            k -= 1
        end
        k <= i && return data[1:k]
        data[i] = data[k]
        data[k] = space # technically not needed but keeping it to avoid confusion
    end
end

function part1(data)
    A = defrag(data)
    return sum(A .* (0:length(A)-1))
end

#=
In order to defrag more efficiently, we can build some indices
to capture the blocks and gaps. They are stored as Int tuples
in a vector. Position is the index position into the resulting
array.
- Blocks: (id, position, size)
- Gaps: (position, size)
=#
function explode2(data)
    v = Int[]
    blocks = Tuple{Int,Int,Int}[]
    gaps = Tuple{Int,Int}[]
    space = -1
    id = 0
    p = 1
    for i in 1:2:length(data)
        val = data[i]
        free = i < length(data) ? data[i+1] : 0
        push!(blocks, (id, p, val))
        for i in 1:val
            push!(v, id)
            p += 1
        end
        free > 0 && push!(gaps, (p, free))
        for i in 1:free
            push!(v, space)
            p += 1
        end
        id += 1
    end
    return v, blocks, gaps
end

function part2(data)
    v, blocks, gaps = explode2(data)
    space = -1
    for i in length(blocks):-1:1
        id, p, sz = blocks[i]
        for j in 1:length(gaps) # find space to fit in, left to right
            q, gap_sz = gaps[j]
            if q < p && sz <= gap_sz # fit? also, never move back to the right!
                v[q:q+sz-1] .= id  # copy id over to the gap
                gaps[j] = (q + sz, gap_sz - sz) # advance the gap's pointer
                v[p:p+sz-1] .= space # release storage
                break
            end
        end
    end
    return sum((idx - 1) * id for (idx, id) in enumerate(v) if id > 0)
end

#=
julia> @btime part1($data)
  384.625 μs (24 allocations: 2.59 MiB)
6332189866718

julia> @btime part2($data)
  30.691 ms (48 allocations: 3.42 MiB)
6353648390778
=#
