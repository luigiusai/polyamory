io.stdout:setvbuf('no')
local loader = require('loader')

function runGame(targetPath, runtime)
	local okay, result, details, runtimes = loader(targetPath, runtime)
	if not okay then
		require('ui')(targetPath, result, details, runtimes)
	else
		love.event.quit()
	end
end

if love.filesystem.isFused() then
	runGame(arg[1])
else
	runGame(arg[2])
end
