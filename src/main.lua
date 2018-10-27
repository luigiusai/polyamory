io.stdout:setvbuf('no')
local loader = require('loader')

function parseArg()
	local args, loveFile = {}
	local start = love.filesystem.isFused() and 1 or 2
	for i = start, #arg do
		if not loveFile and arg[i]:sub(1, 1) ~= '-' then
			loveFile = arg[i]
			args[#args + 1] = ('"%s"'):format(loveFile)
		else
			args[#args + 1] = arg[i]
		end
	end

	return loveFile, table.concat(args, ' ')
end

function runGame(targetPath, cmdLine, runtime)
	local okay, result, details, runtimes, recommended = loader(targetPath, cmdLine, runtime)
	if not okay then
		require('ui')(targetPath, cmdLine, result, details, runtimes, recommended)
	else
		love.event.quit()
	end
end

runGame(parseArg())
