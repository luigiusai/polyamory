local graphics, window, noise = love.graphics, love.window, love.math.noise
local left, top = 10, 10
local width, height = 640, 224
local font, defaultFont, lineheight = nil, nil, 12
local mouse = { x = 0, y = 0 }
local lines = {}
local cmdArgs

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

function drawBg()
	local cw, ch = 32, 32
	for y = 0, math.ceil(height / ch) do
		for x = 0, math.ceil(width / cw) do
			local t = love.timer.getTime() * .1
			local n = noise(x + t, y + t)
			local b = .5 + n * n * .5
			graphics.setColor(b * .2, b * .3, b * .4)
			graphics.rectangle('fill', x * cw, y * ch, cw, ch)
		end
		graphics.setColor(0, 0, 0)
		graphics.line(.5, y * ch - .5, width, y * ch - .5)
	end
	for x = 0, math.ceil(width / cw) do
		graphics.line(x * cw - .5, .5, x * cw - .5, height)
	end
	graphics.setColor(1, 1, 1)
end

function love.draw()
	--graphics.clear(0.2, 0.4, 0.8)
	drawBg()
	local x, y, lh = left, top, lineheight
	for i = 0, #lines - 1 do
		line = lines[i + 1]
		if line.action and line.active then
			graphics.setColor(0, .2, .5, .8)
			graphics.rectangle('fill', 160, top + i * lh - 2, 320, lh - 2)
		end
		if line.active then
			graphics.setColor(1, .7, .2)
		else
			graphics.setColor(1, 1, 1)
		end

		local tx, ty = math.floor(320 - font:getWidth(line.text) * .5), math.floor(y + lh * .05)
		graphics.print(line.text, tx, ty)
		if line.annotation then
			graphics.setFont(defaultFont)
			graphics.setColor(.2, 1, 1, 1)
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
	runGame(targetPath, cmdArgs, runtime)
end

function love.filedropped(file)
	cmdArgs = file:getFilename()
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

return function(targetPath, cmdLine, err, details, runtimes, recommendedVersion)
	lines = {}
	cmdArgs = cmdLine
	window.setMode(width, height) -- TODO: fit to required size
	window.setTitle('polyamory')
	defaultFont = defaultFont or graphics.getFont()
	font = font or graphics.setNewFont('neuropol.ttf', 24)
	lineheight = math.floor(font:getHeight() * 1.2)

	if err == 'no game' then
		printText('No game. Drop one here.')
	elseif err == 'mount error' then
		printText('File not found or corrupt archive:')
		printText(details)
	elseif err == 'no version' then
		printText('No version information found')
		printText('Select version:')
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
