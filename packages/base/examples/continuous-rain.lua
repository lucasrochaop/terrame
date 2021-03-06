-- @example A simple continuous rain model. It uses three differential
-- equations to simulate rain, soil water, and drainage dynamics.
-- @arg C The amount of rain per unit of time. The default value is 2.
-- @arg K The flow coefficient. The default value is 0.4.
-- @arg dt The step used in the numerical integration. The default value is 0.01.

C = 2
K = 0.4
dt = 0.01

-- GLOBAL VARIABLES
q = 0
input = 0
output = 0

-- RULES
t = Timer{
	Event{start = 0, action = function(event)
		-- rain
		input = integrate{
			equation = function() return C end,
			initial = 0,
			a = 0,
			b = 1,
			step = dt
		}

		-- soil water
		q = integrate{
			equation = function() return input - output end,
			initial = q,
			a = 0,
			b = 1,
			step = dt
		}

		-- drainage
		output = integrate{
			equation = function() return K * q end,
			initial = 0,
			a = 0,
			b = 1,
			step = dt
		}

		-- report
		print(event:getTime().."\t"..input.."\t"..output.."\t"..q)
	end}
}

t:run(75)

