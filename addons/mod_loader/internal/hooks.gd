class_name _ModLoaderHooks
extends Object

# This Class provides utility functions for working with Mod Hooks.
# Currently all of the included functions are internal and should only be used by the mod loader itself.
# Functions with external use are exposed through the ModLoaderMod class.

const LOG_NAME := "ModLoader:Hooks"


static func add_hook(mod_callable: Callable, script_path: String, method_name: String, is_before := false) -> void:
	ModLoaderStore.any_mod_hooked = true
	var hash = get_hook_hash(script_path,method_name,is_before)
	if not ModLoaderStore.modding_hooks.has(hash):
		ModLoaderStore.modding_hooks[hash] = []
	ModLoaderStore.modding_hooks[hash].push_back(mod_callable)
	ModLoaderLog.debug("Added hook script: \"%s\" %s method: \"%s\""
		% [script_path, "before" if is_before else "after", method_name ], LOG_NAME
	)
	if not ModLoaderStore.hooked_script_paths.has(script_path):
		ModLoaderStore.hooked_script_paths[script_path] = true


static func call_hooks(self_object: Object, args: Array, hook_hash:int) -> void:
	var hooks = ModLoaderStore.modding_hooks.get(hook_hash, null)
	if hooks:
		for mod_func: Callable in hooks:
			mod_func.bind(self_object).callv(args)


static func get_hook_hash(path:String, method:String, is_before:bool) -> int:
	return hash(path + method + ("before" if is_before else "after"))

