-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
--
-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.
--
-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or caonsequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Pedro R. Andrade
-------------------------------------------------------------------------------------------

return{
	CellularSpace = function(unitTest)
		local cs = CellularSpace{
			xdim = 10,
			value = function() return 3 end
		}

		local r = Random()

		forEachCell(cs, function(cell)
			cell.value = r:number()
		end)

		local c = Chart{target = cs, select = "value"}

		local m = Map{
			target = cs,
			select = "value",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		unitTest:assertType(m, "Map")

		cs:notify()
		unitTest:assertSnapshot(m, "map_slices.bmp")

		local e = Event{action = function() end}[1]

		cs:notify(e)
		cs:notify()

		local unit = Cell{
			count = 0
		}

		local world = CellularSpace{
			xdim = 10,
			value = 10,
			instance = unit
		}

		local c = Chart{target = world}

		unitTest:assertType(c, "Chart")

		world:notify(0)

		local t = Timer{
			Event{action = function(e)
				world.value = world.value + 99
				forEachCell(world, function(cell)
					cell.count = cell.count + 1
				end)
				world:notify(e)
			end}
		}

		local ts = TextScreen{target = world}
		LogFile{target = world}
		local vt = VisualTable{target = world}

		t:run(30)

		local mytable = CSVread("result.csv")
		unitTest:assertEquals(#mytable, 30)
		unitTest:assertFile("result.csv")

		world:notify()
    
		unitTest:assertSnapshot(vt, "cellularspace_visualtable.bmp", 0.059)

		unitTest:assertSnapshot(ts, "textscreen_cs_value.bmp", 0.01)

		unitTest:clear()

		local world = CellularSpace{
			xdim = 10
		}

		forEachCell(world, function(cell)
			if math.random() > 0.6 then
				cell.value = 1
			else
				cell.value = 0
			end
		end)

		Map{
			target = world,
			select  = "value",
			color  = {{0, 0, 0}, {255, 255, 255}},
			min = 0,
			max = 1,
			slices = 2,
		}

		Map{
			target = world,
			select  = "value",
			color  = {"blue", "red"},
			min = 0,
			max = 1,
			slices = 2,
		}

		Map{
			target = world,
			select  = "value",
			color  = {"blue", "red"},
			min = 0,
			slices = 10,
			max = 1
		}

		world:notify()
		world:notify()
	end,
	notify = function(unitTest)
		local r = Random()

		local c = Cell{
			mvalue = function()
				return r:number()
			end
		}

		local cs = CellularSpace{
			xdim = 5,
			instance = c
		}

		local m = Map{
			target = cs,
			select = "mvalue",
			min = 0,
			max = 1,
			slices = 10,
			color = "Blues"
		}

		cs:notify()
		cs:notify()
		unitTest:assert(true)
	end
}

