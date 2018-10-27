local ffi = require('ffi')

local SUPPORTED_VERSIONS = {
	'0.8.0',
	'0.9.0',
	'0.9.1',
	'0.9.2',
	'0.10.0',
	'0.10.1',
	'0.10.2',
	'11.0',
	'11.1',
}

-- release dates of known LÖVE versions
local VERSION_EPOCH = {
	1385161200, -- 0.8.0
	1386889200, -- 0.9.0
	1396303200, -- 0.9.1
	1423868400, -- 0.9.2
	1456786800, -- 0.10.0
	1456873200, -- 0.10.1
	1477868400, -- 0.10.2
	1522533600, -- 11.0
	1523743200, -- 11.1
}

local VERSION_MAP = {
	['8'] = '0.8.0',
	['9'] = '0.9.2',
	['10'] = '0.10.2',
	['11'] = '11.1',
}

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
local function extractVersion()
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

local function getRelevantVersion(verStr)
	local major, minor, revision = verStr:match('^(%d+)%.(%d+)%.(%d+)$') -- < 11
	if minor then return minor end
	if not major then
		-- 11.0+
		major, minor = verStr:match('^(%d+)%.(%d+)$')
	end
	return major
end

local runtimes, versions = getRuntimes()

local function verifyVersion()
	local verStr = extractVersion()
	if not verStr then return false, 'no version', '' end

	local version = canonizeVerNum(VERSION_MAP[getRelevantVersion(verStr)])
	if not version then return false, 'invalid version', verStr end
	if not runtimes[version] then return false, 'no runtime', verStr end

	return true, version
end

-- detects the LÖVE version from the date of top-level files and directories in the game
local function detectVersion()
	local fileList, newestTime = love.filesystem.getDirectoryItems('target'), 0
	for i = 1, #fileList do
		local info = love.filesystem.getInfo('target/' .. fileList[i])
		newestTime = math.max(newestTime, info.modtime)
	end

	if newestTime == 0 then return end

	for i = 1, #VERSION_EPOCH do
		if newestTime < VERSION_EPOCH[i] then
			return SUPPORTED_VERSIONS[math.max(1, i - 1)]
		end
	end

	return SUPPORTED_VERSIONS[#SUPPORTED_VERSIONS]
end

local function execute(what)
	if love.system.getOS() == 'Windows' then
		return os.execute(('start %s'):format(what))
	end
	return os.execute(('%s &'):format(what))
end

local function loadGame(targetPath, cmdLine, runtime)
	if runtime then
		print('run', runtimes[runtime].path, cmdLine)
		return true, execute(('%s %s'):format(runtimes[runtime].path, cmdLine))
	end

	if not targetPath then return false, 'no game' end
	if not mountGame(targetPath, 'target') then return false, 'mount error', targetPath end

	local okay, ver, details = verifyVersion()
	if not okay then
		local detected = detectVersion()
		print('detected version:', detected or 'none')
		return false, ver, details, runtimes, detected and VERSION_MAP[getRelevantVersion(detected)]
	end

	print('run', runtimes[ver].path, cmdLine)
	return true, execute(('%s %s'):format(runtimes[ver].path, cmdLine))
end

return loadGame
