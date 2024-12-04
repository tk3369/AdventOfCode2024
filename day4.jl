function input(filename)
    permutedims(reduce(hcat, [[c for c in line] for line in readlines(filename)]))
end

# Given a position on the board, walk `len` steps using the offsets
# in the convention of (row-increment, col-increment)
function walk(row, col, len, offsets)
    return ((row + offsets[1] * i, col + offsets[2] * i) for i in 0:len-1)
end

# Compose a word given the coordinates. A coordinate is ignored when instruction
# is out of bound,
function get_word(data, coordinates)
    nrows = size(data, 1)
    ncols = size(data, 2)
    return join(data[c[1], c[2]] for c in coordinates if c[1] in 1:nrows && c[2] in 1:ncols)
end

# Explore 8 directions and count how many times the word is matched.
function count_words(data, row, col, txt)
    len = length(txt)
    offsets = ((0, 1), (1, 0), (1, 1), (0, -1), (1, -1), (-1, 0), (-1, -1), (-1, 1))
    return count(txt == get_word(data, walk(row, col, len, offset)) for offset in offsets)
end

part1(data) = sum(count_words(data, row, col, "XMAS") for row in 1:size(data, 1) for col in 1:size(data, 2))

# Compose a "word" given 5 coordinates (top left, top right,
# middle, bottom left, bottom right). Since the word can be expressed
# in any direction, there are 4 "words" to match against.
function count_mas(data, row, col)
    nrows = size(data, 1)
    ncols = size(data, 2)
    offsets = [(-1, -1), (-1, 1), (0, 0), (1, -1), (1, 1)]
    coordinates = [(row, col) .+ c for c in offsets]
    s = join(data[c[1], c[2]] for c in coordinates if c[1] in 1:nrows && c[2] in 1:ncols)
    return s in ("MSAMS", "SSAMM", "SMASM", "MMASS")
end

part2(data) = sum(count_mas(data, row, col) for row in 1:size(data, 1) for col in 1:size(data, 2))

#=
julia> @btime part1($data)
  13.383 ms (627203 allocations: 31.10 MiB)
2524

julia> @btime part2($data)
  2.657 ms (156800 allocations: 8.67 MiB)
1873
=#

function part1_fast(data)
    function match_word(data, coordinates, txt)
        nrows = size(data, 1)
        ncols = size(data, 2)
        for (i, c) in enumerate(coordinates)
            if c[1] ∉ 1:nrows || c[2] ∉ 1:ncols || data[c[1], c[2]] != txt[i]
                return false
            end
        end
        return true
    end
    function count_words_fast(data, row, col, txt)
        len = length(txt)
        offsets = ((0, 1), (1, 0), (1, 1), (0, -1), (1, -1), (-1, 0), (-1, -1), (-1, 1))
        return sum(match_word(data, walk(row, col, len, offset), txt) for offset in offsets)
    end
    sum(count_words_fast(data, row, col, "XMAS") for row in 1:size(data, 1) for col in 1:size(data, 2))
end

function part2_fast(data)
    function count_mas_fast(data, row, col)
        nrows = size(data, 1)
        ncols = size(data, 2)
        offsets = ((-1, -1), (-1, 1), (0, 0), (1, -1), (1, 1))
        coordinates = ((row, col) .+ c for c in offsets)
        matches = ("MSAMS", "SSAMM", "SMASM", "MMASS")
        for match in matches
            mismatched = false
            for (i, c) in enumerate(coordinates)
                if c[1] ∉ 1:nrows || c[2] ∉ 1:ncols || data[c[1], c[2]] != match[i]
                    mismatched = true
                    break
                end
            end
            !mismatched && return true
        end
        return false
    end
    return sum(count_mas_fast(data, row, col) for row in 1:size(data, 1) for col in 1:size(data, 2))
end

#= Optimized
julia> @btime part1_fast($data)
  980.000 μs (0 allocations: 0 bytes)
2524

julia> @btime part2_fast($data)
  368.709 μs (0 allocations: 0 bytes)
1873
=#
