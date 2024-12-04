# This script was abandoned because it was over-engineered with flipping logic
# and unresolved overlaps.

function input(filename)
    readlines(filename)
end

data = input()

function extract(data, row, col, len, dir)
    width = length(data[1])
    height = length(data)
    if dir == :horizontal # e.g. width=8, len=4, so col=5 is the last one
        return col + len - 1 > width ? nothing : data[row][col:col+len-1]
    elseif dir == :vertical
        return row + len - 1 > height ? nothing : join(data[r][col] for r in row:row+len-1)
    elseif dir == :diagonal
        return (row + len - 1 > height || col + len - 1 > width) ? nothing :
               join(data[row+i][col+i] for i in 0:(len-1))
    end
end

function scan(data, inc=[:horizontal, :vertical, :diagonal])
    txt = "XMAS"
    total = 0
    for row in 1:length(data)
        for col in 1:length(data[1])
            s = extract(data, row, col, length(txt), :horizontal)
            total += s !== nothing && s == txt && :horizontal ∈ inc
            s = extract(data, row, col, length(txt), :vertical)
            total += s !== nothing && s == txt && :vertical ∈ inc
            s = extract(data, row, col, length(txt), :diagonal)
            total += s !== nothing && s == txt && :diagonal ∈ inc
        end
    end
    return total
end

flip1(data) = [reverse(s) for s in data]
flip2(data) = reverse(data) # horizontal overlap
flip3(data) = flip2(flip1(data))

part1(data) = scan(data)
