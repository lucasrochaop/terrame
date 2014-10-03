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
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this library and its documentation.
--
-- Authors: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
--          Pedro R. Andrade (pedro.andrade@inpe.br)
-------------------------------------------------------------------------------------------

return{
	Event = function(unitTest)
		local error_func = function()
			event = Event{time = "time", period = 2, priority = -1, action = function(event) end}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'time' expected number, got string.")

		error_func = function()
			event = Event{period = "1", priority = 1, action = function(event) end}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'period' expected number, got string.")

		error_func = function()
			event = Event{period = -1, priority = 1, action = function(event) end}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'period' expected positive number (except zero), got -1.")

		error_func = function()
			event = Event{period = 2, priority = "aaa", action = function(event) end}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'priority' expected number, got string.")

		error_func = function()
			event = Event{period = 0, priority = 1, action = function() end}
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter 'period' expected positive number (except zero), got 0.")

		error_func = function()
			event = Event{period = 2, priority = 1, action = -5.5}
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter 'action' expected one of the types from the set [Agent, Automaton, Cell, CellularSpace, function, Group, Society, Timer, Trajectory], got number.")

		error_func = function()
			event = Event{message = function() end}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'message' is deprecated, use 'action' instead.")

		error_func = function()
			event = Event{myaction = function() end}
		end
		unitTest:assert_error(error_func, "Error: Parameter 'myaction' is unnecessary.")
	end,
	config = function(unitTest)
		local event = Event{action = function(event) end}
		local error_func = function()
			event:config(1, -2, 1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#2' expected positive number, got -2.")

		event = Event{action = function(event) end}
		error_func = function()
			event:config(1, 0, 1)
		end
		unitTest:assert_error(error_func, "Error: Incompatible values. Parameter '#2' expected positive number, got 0.")

		event = Event{action = function(event) end}
		error_func = function()
			event:config(1, "5")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#2' expected number, got string.")

		event = Event{action = function(event) end}
		error_func = function()
			event:config(1, 1, "aa")
		end
		unitTest:assert_error(error_func, "Error: Incompatible types. Parameter '#3' expected number, got string.")
	end
}

