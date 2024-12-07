function input(filename)
    lines = [split(line, ": ") for line in readlines(filename)]
    return [(parse(Int, line[1]), parse.(Int, split(line[2], " "))) for line in lines]
end

data = input("day7.txt")

function find_ops(ops, equation)
    ans, operands = equation
    seq = Iterators.product(fill(ops, length(operands) - 1)...)
    @inbounds for application in seq
        val = operands[1]
        for i in 2:length(operands)
            val = application[i-1](val, operands[i])
        end
        val == ans && return ans
    end
    return 0
end

concat(x, y) = x * 10^ndigits(y) + y

part1(data) = sum(find_ops([+, *], equation) for equation in data)
part2(data) = sum(find_ops([+, *, concat], equation) for equation in data)

#=
julia> @btime part1($data)
  628.914 ms (5471906 allocations: 102.28 MiB)
2314935962622

julia> @btime part2($data)
  43.804 s (347850057 allocations: 6.33 GiB)
401477450831495
=#

# Using a binary system, we cann model the operator (+,*) as either 0
# or 1 in a binary number. So, there's no need to generate permutations
# of operators because it's already naturally represented.
function find_ops_binary(equation)
    ans, operands = equation
    len = length(operands) - 1
    @inbounds for scenario in 0:2^len-1  # e.g. 00, 01, 10, 11
        val = operands[1]
        for i in 0:len-1 # how many operators?
            bit = 1 & (scenario >> i) # find the nth bit
            if bit == 0
                val += operands[i+2]
            else
                val *= operands[i+2]
            end
        end
        val == ans && return ans
    end
    return 0
end

# Part 2 optimization is the same idea, just using a ternary numbering
# system.

function ternary_digit(n, pos)
    for i in 1:pos
        n = n ÷ 3
    end
    return n % 3
end

function find_ops_ternary(equation)
    ans, operands = equation
    len = length(operands) - 1
    @inbounds for scenario in 0:3^len-1
        val = operands[1]
        for i in 0:len-1 # how many operators?
            digit = ternary_digit(scenario, i)
            if digit == 0
                val += operands[i+2]
            elseif digit == 1
                val *= operands[i+2]
            else
                val = concat(val, operands[i+2])
            end
        end
        val == ans && return ans
    end
    return 0
end

part1_fast(data) = sum(find_ops_binary(equation) for equation in data)
part2_fast(data) = sum(find_ops_ternary(equation) for equation in data)

#=
julia> @btime part1_fast($data)
  1.267 ms (0 allocations: 0 bytes)
2314935962622

julia> @btime part2_fast($data)
  717.083 ms (0 allocations: 0 bytes)
401477450831495
=#
