module SumGame

using SumTypes
# using CairoMakie
# using ColorSchemes
# using DataFramesMeta

include("$(@__DIR__)/utils.jl")


# --- Types ---

"""Animal resprents the type of creature on the spinner and board."""
@sum_type Animal begin
    Cow
    Tractor
    Sheep
    Dog
    Pig
    Fox
end

"""
Square represents the three different kinds of squares, including regular and bonus squares that contain data indicating the `Animal` in the square.
"""
@sum_type Square begin
    Empty
    Regular(::Animal)
    Bonus(::Animal)
end


# --- Game ---

"""
    ismatch(space,spin)

True or false depending on if the `spin` (an `Anmial`) matches the data within the `square` (`Animal` if not an `Empty` `Square`).
"""
function ismatch(square, spin)
    @cases square begin
        Empty => false
        [Regular, Bonus](a) => spin == a
    end
end

"""
    move(board,cur_position,spin)

Represents the result of a single turn of the game.
Returns a named pair (tuple) of the number of spaces moved and chicks collected for that turn.
"""
function move(board, cur_position, spin)
    next_square = findnext(space -> ismatch(space, spin), board, max(cur_position, 1))

    if isnothing(next_square)
        # nothing found that matches, so we must be at the end of the board
        l = length(board) - cur_position + 1
        (spaces=l, chicks=l)
    else
        n_spaces = next_square - cur_position
        @cases board[next_square] begin
            Empty => (spaces=n_spaces, chicks=n_spaces)
            Bonus => (spaces=n_spaces, chicks=n_spaces + 1)
            Regular => (spaces=n_spaces, chicks=n_spaces)
        end
    end
end

"""
    playgame(board,total_chicks=40)

Simulate a game of Count Your Chickens and return how many chicks are outside of the coop at the end. The players win if there are no chicks outside of the coop.
"""
function playgame(board, total_chicks=40)
    position = 0
    chicks_in_coop = 0
    while position < length(board)
        spin = rand((Cow, Tractor, Sheep, Dog, Pig, Fox))
        if spin == Fox
            if chicks_in_coop > 1
                chicks_in_coop -= 1
            end
        else
            result = move(board, position, spin)
            # limit the chicks in coop to available chicks remaining
            moved_chicks = min(total_chicks - chicks_in_coop, result.chicks)
            chicks_in_coop += moved_chicks
            position += result.spaces
        end
    end
    return total_chicks - chicks_in_coop

end


# --- REPL ---

@comment begin

    typeof(Pig), Pig isa Animal

    typeof(Bonus(Dog)), Bonus(Dog) isa Square

    ismatch(Bonus(Pig), Pig)

    board = [Empty, Regular(Sheep), Regular(Pig), Bonus(Tractor), Regular(Cow),
        Regular(Dog), Regular(Pig), Bonus(Cow), Regular(Dog), Regular(Sheep),
        Regular(Tractor), Empty, Regular(Cow), Regular(Pig), Empty,
        Empty, Empty, Regular(Tractor), Empty, Regular(Tractor),
        Regular(Dog), Bonus(Sheep), Regular(Cow), Regular(Dog), Regular(Pig),
        Regular(Tractor), Empty, Regular(Sheep), Regular(Cow), Empty,
        Empty, Regular(Tractor), Regular(Pig), Regular(Sheep), Bonus(Dog),
        Empty, Regular(Sheep), Regular(Cow), Bonus(Pig),]

    move(board, 0, Cow)

    playgame(board, 40)

end

end
