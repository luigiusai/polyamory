io.stdout:setvbuf('no')
local loader = require('loader')

function runGame(targetPath, runtime)
	local okay, result, details, runtimes, recommended = loader(targetPath, runtime)
	if not okay then
		require('ui')(targetPath, result, details, runtimes, recommended)
	else
		love.event.quit()
	end
end

if love.filesystem.isFused() then
	runGame(arg[1])
else
	runGame(arg[2])
end
