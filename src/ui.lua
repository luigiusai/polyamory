local graphics, window = love.graphics, love.window
local left, top = 10, 10
local font, defaultFont, lineheight = nil, nil, 12
local mouse = { x = 0, y = 0 }
local lines = {}

local function printText(...)
	local line = {...}
	for i = 1, #line do
		line[i] = tostring(line[i]) or ''
	end
	lines[#lines + 1] = { text = table.concat(line, ' ') }
end

local function printMenu(action, text, annotation)
	printText(text)
	lines[#lines].action = action
	lines[#lines].annotation = annotation
end

function love.draw()
	graphics.clear(0.2, 0.4, 0.8)
	local x, y, lh = left, top, lineheight
	for i = 0, #lines - 1 do
		line = lines[i + 1]
		if line.action then
			graphics.setColor(0, 0, 0, line.active and .5 or .2)
			graphics.rectangle('fill', 160, top + i * lh - 2, 320, lh - 2)
		end
		if line.active then
			graphics.setColor(1, .8, 0)
		else
			graphics.setColor(1, 1, 1)
		end

		local tx, ty = math.floor(320 - font:getWidth(line.text) * .5), math.floor(y + lh * .05)
		graphics.print(line.text, tx, ty)
		if line.annotation then
			graphics.setFont(defaultFont)
			graphics.setColor(0, 1, 0, 1)
			local ax, ay = tx + font:getWidth(line.text) + 10, math.floor(ty + lh - defaultFont:getHeight() * 1.5)
			graphics.print(line.annotation, ax, ay)
			graphics.setFont(font)
			graphics.setColor(1, 1, 1)
		end

		y = y + lh
	end
end

local function getLineNum(y)
	return math.max(1, math.floor((y - top) / lineheight) + 1)
end

function love.mousemoved(x, y)
	local last, line = getLineNum(mouse.y), getLineNum(y)
	mouse.x, mouse.y = x, y
	if last == line then return end

	if last <= #lines and lines[last].active then
		lines[last].active = false
	end

	if line <= #lines and lines[line].action then
		lines[line].active = true
	end
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

local function versionMenu(entries, targetPath, recommendedVersion)
	versions = {}
	for k, _ in pairs(entries) do versions[#versions + 1] = k end
	table.sort(versions)

	for i = 1, #versions do
		local action = function()
			run(targetPath, versions[i])
		end
		local annotation
		if recommendedVersion == entries[versions[i]].version then
			annotation = '(recommended)'
		end
		printMenu(action, entries[versions[i]].version, annotation)
	end
end

return function(targetPath, err, details, runtimes, recommendedVersion)
	lines = {}
	window.setMode(640, 300) -- TODO: fit to required size
	window.setTitle('polyamory')
	defaultFont = defaultFont or graphics.getFont()
	font = font or graphics.setNewFont('rif.ttf', 18)
	lineheight = math.floor(font:getHeight() * 1.2)

	if err == 'no game' then
		printText('No game. Drop one here.')
	elseif err == 'not found' then
		printText('File not found:')
		printText(details)
	elseif err == 'no version' then
		printText('This game has no associated LÖVE version')
		versionMenu(runtimes, targetPath, recommendedVersion)
	elseif err == 'invalid version' then
		printText('This game has an invalid version identifier (' .. details .. ')')
		versionMenu(runtimes, targetPath, recommendedVersion)
	else
		printText('Something bad happened :(')
		printText(err)
		printText(details)
	end
end
