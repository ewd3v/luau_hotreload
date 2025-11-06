--!strict
if _G.RUNTIME ~= "lune" then
	error(`Can't run tests on {_G.RUNTIME}, use Lune.`)
end

local luau = require("@lune/luau")
local task = require("@lune/task")

local Graft = require("./src")

local sourcecode = [[
local task = require("@lune/task")
local Graft, a, b = ...
local ret = { a, b }
local function test()
	table.insert(ret, "hi!")
end
test()
task.wait(1)
test()
return Graft.IsGrafted(), ret
]]

local sourcecode2 = [[
local task = require("@lune/task")
local Graft, a, b = ...
local ret = { a, b }
local function test()
	table.insert(ret, "goodbye!")
	table.insert(ret, "last test")
end
test()
task.wait(1)
test()
return Graft.IsGrafted(), ret
]]

local graft = Graft.new({
	GetBytecode = function(): buffer
		print("compiling bytecode...")
		return buffer.fromstring(luau.compile(sourcecode))
	end,
})

task.defer(function()
	sourcecode = sourcecode2
	graft:Patch()
end)

local isGrafted, ret = graft:Run(Graft, "test1", "test2")
assert(isGrafted == true, ".IsGrafted() should return true in hot reloaded environments")
assert(graft.IsGrafted() == false, ".IsGrafted() should return false outside hot reloaded environments")

assert(#ret == 5, "bad return amount")
assert(ret[1] == "test1", "bad return")
assert(ret[2] == "test2", "bad return")
assert(ret[3] == "hi!", "bad return")
assert(ret[4] == "goodbye!", "bad return")
assert(ret[5] == "last test", "bad return")
