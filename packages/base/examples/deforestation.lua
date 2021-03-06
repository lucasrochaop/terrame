-- @example Amazonia deforestation models. It uses a top-down approach
-- with three strategies to compute deforestation potential.
-- The first strategy compute the deforestation potential based on
-- the deforestation of neighbor cells. The second one uses the result
-- of a statistical regression using distance to urban areas, connection
-- to markets, and coverage of protected areas as parameters.
-- The last strategies mixes the other two. It adds the average deforestation
-- of the neighborhood to the statistical regression.
-- @arg FINAL_TIME The final simulation time. The simulation starts in 2005.
-- @arg ALLOCATION The yearly deforestation demand in km2.
-- @arg LIMIT The maximum area per year that might not be deforested, given
-- the total ALLOCATION.
-- @image deforestation.bmp

CELL_AREA = 10000
FINAL_TIME = 2040
ALLOCATION = 30000
LIMIT = 30

amazonia = CellularSpace{
	file = filePath("amazonia.shp")
}

forEachCell(amazonia, function(cell)
		cell.defor = cell.defor_10
		cell.area_indigena = cell.areadigena
		cell.dist_portos = cell.distportos
		cell.dist_rodovias = cell.distdovias
end)

amazonia:createNeighborhood()

map = Map{
	target = amazonia,
	select = "defor",
	slices = 10,
	min = 0,
	max = 1,
	color = {"green", "red"}
}

function calculatePotNeighborhood(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		local countNeigh = 0

		if cell.defor < 1.0 then
			forEachNeighbor(cell, function(_, neigh)
				-- The potential of change for each cell is
				-- the average of neighbors deforestation.
				-- fully deforested cells have zero potential
				cell.pot = cell.pot + neigh.defor
				countNeigh = countNeigh + 1
			end)

			if cell.pot > 0 then
				-- increment the total potential
				cell.pot = cell.pot / countNeigh
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

function calculatePotRegression(cs)
	local total_pot = 0

	-- The potential for change is the residue of a
	-- linear regression between the cell's
	-- current and expected deforestation
	forEachCell(cs, function(cell)
		cell.pot = 0

		if cell.defor < 1.0 then
			expected =  - 0.150 * math.log(cell.dist_rodovias)
			            - 0.048 * cell.area_indigena
			            - 0.060 * math.log(cell.dist_portos)
			            + 2.7

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

function calculatePotMixed(cs)
	local total_pot = 0

	forEachCell(cs, function(cell)
		cell.pot = 0
		cell.ave_neigh = 0

		-- Calculate the average deforestation
		countNeigh = 0
		forEachNeighbor(cell, function(_, neigh)
			-- The potential of change for each cell is
			-- the average of neighbors' deforestation.
			if cell.defor < 1.0 then
				cell.ave_neigh = cell.ave_neigh + neigh.defor
				countNeigh = countNeigh + 1
			end
		end)
	
		-- find the average deforestation
		if cell.defor < 1.0 then
			cell.ave_neigh = cell.ave_neigh / countNeigh
		end

		-- Potential for change
		if cell.defor < 1.0 then
			expected =    1.056 * cell.ave_neigh
						- 0.035 * math.log(cell.dist_rodovias)
						+ 0.018 * math.log(cell.dist_portos)
						- 0.051 * cell.area_indigena
						+ 0.059

			if expected > cell.defor then
				cell.pot = expected - cell.defor
				total_pot = total_pot + cell.pot
			end
		end
	end)
	return total_pot
end

function deforest(cs, total_pot)
	-- ajust the demand for each cell so that
	-- the maximum demand for change is 100%
	-- adjust the demand so that excess demand is
	-- allocated to the remaining cells
	-- there is an error limit (30 km2 or 0.1%)
	local total_demand = ALLOCATION
	while total_demand > LIMIT do
		forEachCell(cs, function(cell)
			newarea = (cell.pot / total_pot) * total_demand
			cell.defor = cell.defor + newarea / CELL_AREA
			if cell.defor >= 1 then
				total_pot = total_pot - cell.pot
				cell.pot = 0
				excess = (cell.defor - 1) * CELL_AREA
				cell.defor = 1
			else
				excess = 0
			end
			-- adjust the total demand
			total_demand = total_demand - (newarea - excess)
		end)
	end
end

calculatePot = {calculatePotNeighborhood, calculatePotRegression, calculatePotMixed}
currentPot = calculatePot[1]

function hasPotential(cell1)
	return cell1.pot > 0
end

function greaterPotential(cell1, cell2)
	return cell1.pot > cell2.pot
end

traj = Trajectory{
	target = amazonia,
	select = hasPotential,
	greater = greaterPotential,
	build = false
}

t = Timer{
	Event{start = 2005, action = function()
		local total_pot = currentPot(amazonia)
		traj:rebuild()
		deforest(traj, total_pot)
	end},
	Event{start = 2004, action = map}
}

t:run(FINAL_TIME)
