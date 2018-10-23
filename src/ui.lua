local graphics, window, stdout = love.graphics, love.window, print
local errorCode = ''
local left, top = 10, 10
local lineheight = 12
local mouse = { x = 0, y = 0 }
local lines = {}

local function print(...)
	local line = {...}
	for i = 1, #line do
		line[i] = tostring(line[i])
	end
	lines[#lines + 1] = { text = table.concat(line, ' ') }
end

local function printMenu(action, ...)
	print(...)
	lines[#lines].action = action
end

function love.draw()
	graphics.clear(0.2, 0.4, 0.8)
	local x, y, lh = left, top, lineheight
	for i = 0, #lines - 1 do
		line = lines[i + 1]
		if line.action then
			graphics.setColor(0, 0, 0, 0.2)
			graphics.rectangle('fill', 160, top + i * lh - 2, 320, lh - 2)
		end
		if line.active then
			graphics.setColor(1, .8, 0)
		else
			graphics.setColor(1, 1, 1)
		end

		graphics.print(line.text, 320 - graphics.getFont():getWidth(line.text) * .5, y + lineheight * .05)
		y = y + lh
	end
end

local function getLineNum(y)
	return math.max(1, math.floor((y - top) / lineheight) + 1)
end

function love.mousemoved(x, y)
	local last, line = getLineNum(mouse.y), getLineNum(y)
	if last == line then return end

	if last <= #lines and lines[last].active then
		lines[last].active = false
	end

	if line <= #lines and lines[line].action then
		lines[line].active = true
	end

	mouse.x, mouse.y = x, y
end

function love.mousepressed(x, y)
	local line = getLineNum(y)
	if lines[line] and lines[line].action then
		lines[line].action()
	end
end

function love.keyreleased(key)
	if key == 'escape' then
		love.event.quit()
	end
end

local function run(targetPath, runtime)
	window.close()
	runGame(targetPath, runtime)
end

function love.filedropped(file)
	run(file:getFilename())
end

local function versionMenu(entries, targetPath)
	versions = {}
	for k, _ in pairs(entries) do versions[#versions + 1] = k end
	table.sort(versions)

	--print()
	for i = 1, #versions do
		local action = function()
			run(targetPath, versions[i])
		end
		printMenu(action, entries[versions[i]].version)
	end
end

return function(targetPath, err, details, runtimes)
	lines = {}
	window.setMode(640, 300) -- TODO: fit to required size
	window.setTitle('polyamory')
	graphics.setFont(graphics.newFont('rif.ttf', 18))
	lineheight = graphics.getFont():getHeight() * 1.2

	if err == 'no game' then
		print('No game. Drop one here.')
	elseif err == 'not found' then
		print('File not found:')
		print(details)
	elseif err == 'no version' then
		print('This game has no associated LÖVE version')
		versionMenu(runtimes, targetPath)
	elseif err == 'invalid version' then
		print('This game has an invalid version identifier (' .. details .. ')')
		versionMenu(runtimes, targetPath)
	else
		print('Something bad happened :(')
		print(err)
		print(details)
	end
end
