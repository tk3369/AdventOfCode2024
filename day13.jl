#=
I started with HiGHS solver but it produced wrong answer for part 2.
Out of curiorsity, I tried SCIP solver next and it's good! Lesson
learned -- never trust a single solver (yet!)
=#

function input(filename, correction=0)
    rules = split(read(filename, String), "\n\n")
    split_rule(r) = split(r, "\n")
    delta(button) = parse.(Int, match(r".*X\+(\d+), Y\+(\d+)", button).captures)
    target(prize) = parse.(Int, match(r".*X=(\d+), Y=(\d+)", prize).captures) .+ correction
    parse_rule(parts) = (delta(parts[1]), delta(parts[2]), target(parts[3]))
    return [parse_rule(split_rule(rule)) for rule in rules]
end

using JuMP
using SCIP

function solve(rule)
    (xa, ya) = rule[1]
    (xb, yb) = rule[2]
    (xsum, ysum) = rule[3]
    model = Model(SCIP.Optimizer)
    set_silent(model)
    @variable(model, a >= 0; integer=true)
    @variable(model, b >= 0; integer=true)
    @constraint(model, a * xa + b * xb == xsum)
    @constraint(model, a * ya + b * yb == ysum)
    @objective(model, Min, 3a + b)
    optimize!(model)
    return is_solved_and_feasible(model) ? Int(objective_value(model)) : 0
end

solve_problem(rules) = sum(solve(rule) for rule in rules)

p1_rules = input("day13.txt")
solve_problem(p1_rules)

p2_rules = input("day13.txt", 10000000000000)
solve_problem(p2_rules)

#=
julia> solve_problem(p1_rules)
29877

julia> solve_problem(p2_rules)
99423413811305
=#

