-- @example Implementation of Conway's Game of Life.
-- It is a classical Cellular Automata model that simulates
-- changes in a society using very simple rules. Each cell
-- represents an individual that can have two states: alive or dead.
-- Using its own state and the state of its neighbors, each individual
-- decides its next state. The model has four rules. First, 
-- an alive cell with fewer than two alive neighbors dies by loneliness.
-- Second, an alive cell with two or three alive neighbors stays alive.
-- Third, an alive cell with more than three alive neighbors dies
-- by over-population. Fourth, a dead cell with three alive neighbors
-- becomes alive by reproduction. \
-- This implementation creates the initial distribution of alive
-- cells randomly. \
-- For more information, see https://en.wikipedia.org/wiki/Conway's_Game_of_Life.
-- @arg PROBABILITY The probability of a Cell to be alive in the
-- beginning of the simulation. The default value is 0.15.
-- @arg TURNS The number of simulation steps. The default value is 20.
-- @image game-of-life.bmp

PROBABILITY = 0.15
TURNS = 20

r = Random{seed = 12345}

cell = Cell{
	init = function(cell)
		local v = r:number()
		if v <= PROBABILITY then
			cell.state = "alive"
		else
			cell.state = "dead"
		end
	end,
	countAlive = function(cell)
		local count = 0
		forEachNeighbor(cell, function(cell, neigh)
			if neigh.past.state == "alive" then
				count = count + 1
			end
		end)
		return count
	end,
	execute = function(cell)
		local n = cell:countAlive()
		if cell.state == "alive" and (n > 3 or n < 2) then
			cell.state = "dead"
		elseif cell.state == "dead" and n == 3 then
			cell.state = "alive"
		else
			cell.state = cell.past.state
		end 
	end
}

cs = CellularSpace{
	xdim = 50,
	instance = cell
}	   

cs:createNeighborhood()

m = Map{
	target = cs,
	select = "state",
	color = {"black", "lightGray"},
	value = {"alive", "dead"}
}

timer = Timer{
	Event{action = function()
		cs:synchronize()
		cs:execute()
		cs:notify()
	end}
}

timer:run(TURNS)

