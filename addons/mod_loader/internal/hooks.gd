class_name _ModLoaderHooks
extends Object

# This Class provides utility functions for working with Mod Hooks.
# Currently all of the included functions are internal and should only be used by the mod loader itself.
# Functions with external use are exposed through the ModLoaderMod class.

const LOG_NAME := "ModLoader:Hooks"

## Internal ModLoader method. [br]
## To add hooks from a mod use [method ModLoaderMod.add_hook].
static func add_hook(mod_callable: Callable, script_path: String, method_name: String) -> void:
	ModLoaderStore.any_mod_hooked = true
	var hash = get_hook_hash(script_path, method_name)

	if not ModLoaderStore.modding_hooks.has(hash):
		ModLoaderStore.modding_hooks[hash] = []
	ModLoaderStore.modding_hooks[hash].push_back(mod_callable)
	ModLoaderLog.debug('Added hook script: "%s" to method: "%s"' % [script_path, method_name ], LOG_NAME)

	if not ModLoaderStore.hooked_script_paths.has(script_path):
		ModLoaderStore.hooked_script_paths[script_path] = true


static func call_hooks(vanilla_method: Callable, args: Array, hook_hash: int) -> Variant:
	var hooks = ModLoaderStore.modding_hooks.get(hook_hash, null)
	if not hooks:
		return vanilla_method.callv(args)

	# Create a linkage chain which will recursively call down until the vanilla method is reached
	var linkage := ModLoaderHook.new(vanilla_method)
	for mod_func in hooks:
		linkage = ModLoaderHook.new(mod_func, linkage)

	return linkage._execute_chain(args)


static func get_hook_hash(path: String, method: String) -> int:
	return hash(path + method)



