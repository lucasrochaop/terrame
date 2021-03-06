-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

return{
	getConfig = function(unitTest)
		local cf = getConfig()
		unitTest:assertNil(cf.qwertyuiop)

		local cd = currentDir()

		chDir(packageInfo().data)

		local cf2 = getConfig()
		unitTest:assertEquals(cf, cf2)

		chDir(cd)
	end,
	CSVparseLine = function(unitTest)
		local line = CSVparseLine("2,5,aa", ",")
		unitTest:assertEquals(line[1], "2")
		unitTest:assertEquals(line[2], "5")
		unitTest:assertEquals(line[3], "aa")
	end,
	CSVread = function(unitTest)
		local mfile = filePath("agents.csv", "base")

		local csv = CSVread(mfile)

		unitTest:assertEquals(4, #csv)
		unitTest:assertEquals(20, csv[1].age)
	end,
	CSVwrite = function(unitTest)
		local example = {
			{age = 1, wealth = 10, vision = 2, metabolism = 1, test = "Foo text"},
			{age = 3, wealth =  8, vision = 1, metabolism = 1, test = "Foo;text"},
			{age = 3, wealth = 15, vision = 2, metabolism = 1, test = "Foo,text"},
			{age = 4, wealth = 12, vision = 2, metabolism = 2, test = "Foo@text"},
			{age = 2, wealth = 10, vision = 3, metabolism = 1, test = "Foo%text"},
			{age = 2, wealth =  9, vision = 2, metabolism = 1, test = "Foo)text"},
			{age = 1, wealth = 11, vision = 2, metabolism = 1, test = "Foo#text"},
			{age = 3, wealth = 15, vision = 1, metabolism = 2, test = "Foo=text"},
			{age = 3, wealth = 13, vision = 1, metabolism = 1, test = "Foo.text"},
			{age = 1, wealth = 10, vision = 3, metabolism = 2, test = "Foo(text"}
		}

		local s = sessionInfo().separator
		local filename = tmpDir()..s.."csvwrite.csv"

		CSVwrite(example, filename)
		local data = CSVread(filename)
		unitTest:assertNotNil(data)
		unitTest:assertEquals(#example, #data)

		for i = 1, #example do
			for k in pairs(example[i]) do
				unitTest:assertEquals(example[i][k], data[i][k])
			end
		end
	end
}

