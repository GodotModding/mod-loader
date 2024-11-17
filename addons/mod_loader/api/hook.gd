class_name ModLoaderHook
extends RefCounted
## Small class to pass data between mod hook calls.[br]
## For examples, see [method ModLoaderMod.add_hook].


## The reference object is usually the [Node] that the vanilla script is attached to. [br]
## If the hooked method is [code]static[/code], it will contain the [GDScript] itself.
var reference_object: Object

# The mod hook callable or vanilla method
var _method: Callable
var _next_hook: ModLoaderHook


func _init(method: Callable, next_hook: ModLoaderHook = null) -> void:
	_method = method
	_next_hook = next_hook
	reference_object = _next_hook.reference_object if _next_hook else _method.get_object()


## Will execute the next mod hook callable or vanilla method and return the result.[br]
## Make sure to call this method [i]somewhere[/i] in the [param mod_callable] you pass to [method ModLoaderMod.add_hook]. [br]
##
## [br][b]Parameters:[/b][br]
## - [param args] ([Array]): An array of all arguments passed into the vanilla function. [br]
##
## [br][b]Returns:[/b] [Variant][br][br]
func execute_next(args := []) -> Variant:
	if _next_hook:
		return _next_hook._execute(args)

	return null


# _execute just brings the logic to the current hook
# instead of having it all "external" in the previous hook's execute_next
func _execute(args := []) -> Variant:
	# No next hook means we are at the end of the chain and call the vanilla method directly
	if not _next_hook:
		return _method.callv(args)

	return _method.callv([self] + args)


# This starts the chain of hooks, which goes as follows:
# 	_execute 1
# 	calls _method, the stored mod_callable
# 	if that method is a mod hook, it passes the ModLoaderHook object along
#		mod_callable 1
# 		the mod hook is implemented by modders, here they can change parameters
# 		it needs to call execute_next, otherwise the chain breaks
# 			execute_next 1
#			that then calls _execute on the next hook
#				_execute 2
#				calls _method
# 				if _method contains the vanilla method, it is called directly
#				otherwise we go another layer deeper
# 					_method (vanilla) returns
# 				_execute 2 returns
# 			execute_next 1 returns
#		mod_callable 1
# 		at this point the final return value can be modded again
#		mod_callable 1 returns
# 	_execute 1 returns the final value
# and _execute_chain spits it back out to _ModLoaderHooks.call_hooks
# which was called from the processed vanilla method
func _execute_chain(args := []) -> Variant:
	return _execute(args)
