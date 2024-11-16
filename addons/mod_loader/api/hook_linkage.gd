class_name ModLoaderHookLinkage
extends RefCounted
## Small class to pass data between mod hook calls.[br]
## For examples, see [method ModLoaderMod.add_hook].


## The reference object is usually the [Node] that the vanilla script is attached to. [br]
## If the hooked method is [code]static[/code], it will contain the [GDScript] itself.
var reference_object: Object

var _return_val: Variant
# The next linkage in the chain
var _next_linkage: ModLoaderHookLinkage
# The mod hook callable or vanilla method
var _method: Callable


func _init(mod_method: Callable, next_linkage: ModLoaderHookLinkage = null) -> void:
	_method = mod_method
	_next_linkage = next_linkage
	reference_object = _next_linkage.reference_object if _next_linkage else _method.get_object()


## Will execute the next mod hook callable or vanilla method and return the result.[br]
## Make sure to call this method [i]somewhere[/i] in your [method ModLoaderMod.add_hook] [param mod_callable].
func execute_next(args := []) -> Variant:
	if _next_linkage:
		_return_val = _next_linkage._execute(args)

	# If there is no next linkage, the result from [method _execute] will be returned
	return _return_val


func _execute_chain(args := []) -> Variant:
	return _execute(args)


func _execute(args := []) -> Variant:
	# Remember the value to later return from [method execute_next] if there is no next linkage
	# No next linkage means we are at the end of the chain and call the vanilla method directly
	_return_val = _method.callv([self] + args) if _next_linkage else _method.callv(args)
	return _return_val
