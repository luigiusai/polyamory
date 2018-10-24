local ffi = require('ffi')

local BASE = love.filesystem.getSource()
if love.filesystem.isFused() then
	-- for windows
	BASE = love.filesystem.getSourceBaseDirectory()
	love.filesystem.mount(BASE, '/', true)
end

local RTPATH = BASE .. '/runtime'

local function targetConfDefaults()
	return { audio = {}, window = {}, modules = {}, screen = {} }
end

-- mounts <target>.love into our filesystem
local function mountGame(path)
	local C = ffi.os == 'Windows' and ffi.load('love') or ffi.C
	-- hacking around love limitations
	ffi.cdef('int PHYSFS_mount(const char *newDir, const char *mountPoint, int appendToPath);')
	return C.PHYSFS_mount(path, 'target', 0) ~= 0
end

-- transforms a LÖVE version number into a future-proof format that can be chronologically sorted
local function canonizeVerNum(v)
	local major, minor, revision = v:match('^(%d+)%.(%d+)%.(%d+)$') -- < 11
	if not major then
		-- 11.0+
		major, minor = v:match('^(%d+)%.(%d+)$')
	end

	if major then
		return string.format('%03d%03d%03d', major, minor, revision or 0)
	end
end

-- makes a list of available LÖVE runtimes in the polyamory directory
-- returns a table with canonized version numbers as keys and absolute paths to the LÖVE directories as values
local function getRuntimes()
	local fileList, runtimes = love.filesystem.getDirectoryItems('runtime'), {}

	for i = 1, #fileList do
		local file = fileList[i]
		local info = love.filesystem.getInfo('runtime/' .. file)
		if info and info.type == 'directory' and file:sub(1, 1) ~= '.' then
			local canonized = canonizeVerNum(file)
			if canonized then
				runtimes[canonized] = { version = file, path = RTPATH .. '/' .. file .. '/love.exe' }
				print('found love', file, canonized)
			end
		end
	end

	local versions = {}
	for k, v in pairs(runtimes) do
		versions[#versions + 1] = k
	end
	table.sort(versions) -- chronologically, might be useful one day

	return runtimes, versions
end

-- tries to extract a target version number from the game's conf.lua file
local function extractVersion(targetPath)
	local okay, targetConf = pcall(love.filesystem.load, 'target/conf.lua')
	if not okay then return end

	-- create a fully populated environment for target game ...
	local env = {}
	for k, v in pairs(_G) do env[k] = v end
	-- ...just remove our own conf function...
	env.love.conf = nil
	-- ...then run the loaded code and hope for the best
	local okay, target = pcall(function() setfenv(targetConf, env)() end)

	if not okay then
		-- code tried something clever. check if we have a love.conf() anyway
		if type(env.love.conf) ~= 'function' then
			return -- nope
		end
	end

	-- love.conf is present, lets call it
	local config = targetConfDefaults()
	pcall(env.love.conf, config)

	if type(config.version) ~= 'string' then return end -- no version found, allow manual selection

	return config.version -- hopefully a correct version string
end

local runtimes, versions = getRuntimes()

local function verifyVersion(targetPath)
	local verStr = extractVersion(targetPath)
	if not verStr then return false, 'no version', '' end

	local version = canonizeVerNum(verStr)
	if not version then return false, 'invalid version', verStr end
	if not runtimes[version] then return false, 'no runtime', verStr end

	return true, version
end

local function execute(what)
	if love.system.getOS() == 'Windows' then
		return os.execute(('start %s'):format(what))
	end
	return os.execute(('%s &'):format(what))
end

local function loadGame(targetPath, runtime)
	if runtime then
		return true, execute(('%s %s'):format(runtimes[runtime].path, targetPath))
	end

	if not targetPath then return false, 'no game' end
	if not mountGame(targetPath, 'target') then return false, 'not found', targetPath end

	local okay, err, details = verifyVersion(targetPath)
	if not okay then
		return okay, err, details, runtimes
	end

	return true, execute(('%s %s'):format(runtimes[err].path, targetPath))
end

return loadGame
