io.stdout:setvbuf('line')
local loader = require('loader')

function runGame(targetPath, runtime)
	local okay, result, details, runtimes = loader(targetPath, runtime)
	if not okay then
		require('ui')(targetPath, result, details, runtimes)
	else
		love.event.quit()
	end
end

runGame(arg[2])
