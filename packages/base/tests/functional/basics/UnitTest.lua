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
--          Rodrigo Reis Pereira
-------------------------------------------------------------------------------------------

return{
	UnitTest = function(unitTest)
		local u = UnitTest{sleep = 0.1, source = "Test"}

		unitTest:assertType(u, "UnitTest")
		unitTest:assertEquals(u.success, 0)
		unitTest:assertEquals(u.fail, 0)
		unitTest:assertEquals(u.test, 0)
		unitTest:assertEquals(u.last_error, "")
		unitTest:assertEquals(u.count_last, 0)
		unitTest:assertEquals(u.sleep, 0.1)
		unitTest:assertEquals(u.source, "test")
	end,
	assert = function(unitTest)
		local u = UnitTest{}

		u:assert(true)

		unitTest:assertEquals(u.success, 1)
	end,
	assertEquals = function(unitTest)
		local u = UnitTest{}
		u:assertEquals(true, true)

		unitTest:assertEquals(math.huge, math.huge)
		unitTest:assertEquals(u.success, 1)
		unitTest:assertEquals(u.test, 1)

		unitTest:assertEquals(1, 1.1, 0.15)
		unitTest:assertEquals("abc", "abd", 1)
	end,
	assertError = function(unitTest)
		local u = UnitTest{}

		local error_func = function() CellularSpace{xdim = "a"} end
		u:assertError(error_func, "Incompatible types. Argument 'xdim' expected number, got string.")

		error_func = function() CellularSpace{xdim = "a"} end
		u:assertError(error_func, "Incompatible types. Argument 'xdim' expected number, got   string.", 3)

		unitTest:assertEquals(u.success, 2)
		unitTest:assertEquals(u.test, 2)
	end,
	assertFile = function(unitTest)
		local c = Cell{value = 2}
		LogFile{target = c, file = "abc.csv"}

		local success = unitTest.success
		local test = unitTest.test
		local fail = unitTest.fail

		c:notify()

		unitTest:assertFile("abc.csv")

		local oldPrint = unitTest.printError
		unitTest.printError = function() end
		unitTest:assertFile("abc.csv") -- file does not exist
		unitTest:assertFile(packageInfo().data) -- not possible to use directory

		unitTest.printError = oldPrint

		unitTest:assertEquals(success + 1, unitTest.success)
		unitTest:assertEquals(test + 3 + 1, unitTest.test) -- plus one because of the previous line
		unitTest:assertEquals(fail + 2, unitTest.fail)

		unitTest.fail = unitTest.fail - 2
		unitTest.success = unitTest.success + 2
	end,
	assertNil = function(unitTest)
		local u = UnitTest{}
		u:assertNil()

		unitTest:assertEquals(u.success, 1)
	end,
	assertNotNil = function(unitTest)
		local u = UnitTest{}
		u:assertNotNil(true)

		unitTest:assertEquals(u.success, 1)
	end,
	assertType = function(unitTest)
		local u = UnitTest{}

		u:assertType(2, "number")

		unitTest:assertEquals(u.success, 1)
	end,
	printError = function(unitTest)
		unitTest:assert(true)
	end
}

