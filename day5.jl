function input(filename)
    rules, updates = split(chomp(read(filename, String)), "\n\n")
    rules = [Tuple(parse.(Int, split(pages, "|"))) for pages in split(rules, "\n")]
    updates = [parse.(Int, split(update, ",")) for update in split(updates, "\n")]
    return rules, updates
end

rules, updates = input("day5.txt")

middle(update) = update[length(update)÷2+1]
lt(x, y, rules) = (x, y) ∈ rules
make_right(rules, update) = sort(update, lt=(x, y) -> lt(x, y, rules))
part1(rules, updates) = sum(middle(u) for u in updates if issorted(u, lt=(x, y) -> lt(x, y, rules)))
part2(rules, updates) = sum(middle(make_right(rules, u)) for u in updates if !issorted(u, lt=(x, y) -> lt(x, y, rules)))

#=
julia> @btime part1($rules, $updates)
  496.916 μs (0 allocations: 0 bytes)
4462

julia> @btime part2($rules, $updates)
  4.168 ms (406 allocations: 36.22 KiB)
6767
=#

# Old implementation

valid_after(x, rules) = [r[2] for r in rules if r[1] == x]

combos(u) = length(u) == 0 ? [] : vcat([(u[1], x) for x in u[2:end]], combos(u[2:end]))

valid_combo(c, rules) = c[2] ∈ valid_after(c[1], rules)

function old_part1(rules, updates)
    valid_updates = updates[[all(valid_combo(c, rules) for c in combos(u)) for u in updates]]
    return sum(middle(u) for u in valid_updates)
end

function old_part2(rules, updates)
    valid_bits = [all(valid_combo(c, rules) for c in combos(u)) for u in updates]
    bad_bits = [!i for i in valid_bits]
    invalid_updates = updates[bad_bits]
    return sum(middle(make_right(rules, u)) for u in invalid_updates)
end

using Combinatorics: permutations

function old_make_right(rules, update)
    for u in permutations(update)
        all(valid_combo(c, rules) for c in combos(u)) && return u
    end
    @error "not found :-("
end

