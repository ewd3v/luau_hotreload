--!strict

--[=[
	@class Interface

	An interface is required in order to create a [Graft] object.
	It provides all the required information to it that it needs in order to perform hot reloading (mainly watching for changes and reading / compiling code sources).

	The main reason why this can't be included in the library by default is because pure Luau can't actually read it's own source code or watch for io changes.
	Because of this, there's really no standard to the implementation that runtimes that do support this chooses to have.
	
	It's planned in the future to create packages for these runtimes which will implement this interface for you. Which will be listed here.
]=]

export type Interface = {
	GetBytecode: () -> buffer?,
}

--[=[
	@within Interface
	@function GetBytecode
	@return buffer?
	@yields

	Function that will compile and return the bytecode of the Luau module to run.

	This function may get called multiple times, once while constructing the [Graft] object, and then whenever [Graft:Patch] gets called.

	If the function returns nil instead of a buffer containing the bytecode then that will be interpreted as the module not being ready at the time.  
	If that's the case, then one of two things will happen:  
	1. If this function was called while constructing the Graft object, then any calls to [Graft:Run] will yield until this function is triggered again and returns bytecode.  
	2. If this function was called by [Graft:Patch], then the patching process will cancel (i.e hot reloading will not take place).

	The function may throw errors, in which case the error will be caught printed to the output, with the above logic taking place.

	Yielding is also ok, but to mind that this will slow down the initial load of the module and the time it takes to perform a reload.  
	Note that if the function does yield, and another call to [Graft:Patch] happens, then the thread running this function will get cancelled.
]=]

return nil
