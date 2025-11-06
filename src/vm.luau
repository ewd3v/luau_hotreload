--!strict

--[=[
	@class VM
	@external Fiu https://github.com/rce-incorporated/Fiu

	[Fiu] VM
]=]

local Fiu = require("../fiu/Source")

--[=[
	@within VM
	@type Module { [string]: any }

	The deserialized Luau bytecode by [Fiu].
]=]
export type Module = typeof(Fiu.luau_deserialize(nil :: any, nil :: any))

--[=[
	@within VM
	@type Settings { [string]: any }

	The Luau settings used by [Fiu].
]=]
export type Settings = typeof(Fiu.luau_newsettings())

return Fiu
