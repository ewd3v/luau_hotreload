--!strict
local Interface = require("@self/interface")
local VM = require("@self/vm")

type Interface = Interface.Interface
type Module = VM.Module
type Settings = VM.Settings

--[=[
	@class Graft

	An object used to hold information relevant for hot reloading a certain Luau module / file / script.
]=]

local Graft = {} :: impl
Graft.__index = Graft

export type proto = {
	Source: string,
	Interface: Interface,
	Module: Module?,

	_waitingForModule: { thread },
	_patchThread: thread?,
	_main: ((...any) -> ...any)?,

	Settings: Settings,
}
export type impl = {
	__index: impl,

	new: (interface: Interface, source: string?) -> Graft,

	IsGrafted: () -> boolean,
	Patch: (self: Graft) -> (),
	Run: (self: Graft, ...any) -> ...any,
}

export type Graft = typeof(setmetatable({} :: proto, Graft))

local function getDefaultSettings(): Settings
	local settings = VM.luau_newsettings()

	local isGrafted = Graft.IsGrafted
	settings.callHooks = {
		callHook = function(func, ...)
			if func ~= isGrafted then
				return func, ...
			end

			return function()
				return true
			end
		end,
	}

	return settings
end

--[=[
	Creates a new [Graft] object with the provided [Interface].
]=]
function Graft.new(interface: Interface, source: string?): Graft
	local self = setmetatable({}, Graft)

	--[=[
		@within Graft
		@prop Source string

		The name / source of the Luau module thats being hot reloaded by this object.
	]=]
	self.Source = source or debug.info(2, "s")

	--[=[
		@within Graft
		@prop Interface Interface

		A reference to the [Interface] used to create this Graft object.
	]=]
	self.Interface = interface

	--[=[
		@within Graft
		@prop Module Module
	]=]
	self.Module = nil

	--[=[
		@within Graft
		@prop _waitingForBytecode { thread }
		@private

		A list of threads that are currently yielding and that should be resumed when [Graft.Module] is available.
	]=]
	self._waitingForModule = {}

	--[=[
		@within Graft
		@prop _patchThread thread
		@private

		The thread that's currently fetching the updated code and patching the code.
	]=]
	self._patchThread = nil

	--[=[
		@within Graft
		@prop _main ((...any) -> ...any)?
		@private

		A reference to the Luau module's main function.
	]=]
	self._main = nil

	--[=[
		@within Graft
		@prop Settings Settings

		The [Fiu] settings that should be used.
	]=]
	self.Settings = getDefaultSettings()

	self:Patch()
	return self
end

--[=[
	Returns true if the current environment can be hot reloaded with [Graft].
	If it is you shouldn't try hot loading it again.
]=]
function Graft.IsGrafted(): boolean
	return false
end

local function patch(self: Graft)
	local bytecodeSuccess, bytecode = pcall(self.Interface.GetBytecode)
	if not bytecodeSuccess then
		print(`[Graft] Failed to retrieve bytecode for {self.Source}: {bytecode}`)
		return
	end

	if bytecode == nil then
		return
	end

	local deserializeSuccess, deserialized = pcall(VM.luau_deserialize, bytecode :: any, self.Settings)
	if not deserializeSuccess then
		print(`[Graft] Failed to deserialize bytecode for {self.Source}: {deserialized}`)
	end

	local module = self.Module
	if not module then
		self.Module = deserialized

		for _, thread in self._waitingForModule do
			coroutine.resume(thread, deserialized)
		end
		table.clear(self._waitingForModule)

		return
	end

	local functionChangeError =
		`[Graft] Changing the amount of functions or rearranging them is not yet supported. Not patching. (source: {self.Source})`

	if #module.protoList ~= #deserialized.protoList then
		print(functionChangeError)
		return
	end

	for index, proto in module.protoList do
		local dProto = deserialized.protoList[index]
		if proto.nups ~= dProto.nups then
			print(
				`[Graft] Changing the amount of upvalues that a function has is not yet supported. Not patching. (line: {dProto.linedefined}, function name: {dProto.debugname}, source: {self.Source})`
			)
			return
		end

		if proto.sizep ~= dProto.sizep then
			print(functionChangeError)
			return
		end

		if table.concat(proto.protos, ",") ~= table.concat(dProto.protos, ",") then
			print(functionChangeError)
			return
		end
	end

	print(`[Graft] Patching {self.Source}`)

	module.stringList = deserialized.stringList
	module.typesVersion = deserialized.typesVersion

	for index, proto in module.protoList do
		local dProto = deserialized.protoList[index]
		proto.maxstacksize = dProto.maxstacksize
		proto.numparams = dProto.numparams
		proto.isvararg = dProto.isvararg
		proto.linedefined = dProto.linedefined
		proto.debugname = dProto.debugname

		proto.sizecode = dProto.sizecode
		proto.code = dProto.code
		proto.debugcode = dProto.debugcode

		proto.sizek = dProto.sizek
		proto.k = dProto.k

		proto.lineinfoenabled = dProto.lineinfoenabled
		proto.instructionlineinfo = dProto.instructionlineinfo
	end

	module.mainProto = deserialized.mainProto
end

--[=[
	Asks the [Interface] for the updated source code and then hot reloads the code.
]=]
function Graft:Patch()
	if self._patchThread then
		coroutine.close(self._patchThread)
	end

	self._patchThread = coroutine.create(patch)
	coroutine.resume(self._patchThread :: any, self)
end

--[=[
	Runs the Luau module.

	@yields
]=]
function Graft:Run(...: any): ...any
	local module = self.Module
	if not module then
		table.insert(self._waitingForModule, coroutine.running())
		module = coroutine.yield()
	end

	if not self._main then
		self._main = VM.luau_load(module :: any, getfenv(2), self.Settings)
	end

	return (self._main :: any)(...)
end

return Graft
