class_name ModLoaderHookPass
extends RefCounted
## Small class to pass data between mod hook calls


## The reference object is usually the [Node] that the vanilla script is attached to. [br]
## If the hooked method is [code]static[/code], it will contain the [GDScript] itself.
var reference_object: Object

var return_val: Variant
var _next_passalong: ModLoaderHookPass
var _method: Callable


func _init(method: Callable, next_passalong: ModLoaderHookPass = null) -> void:
	_method = method
	_next_passalong = next_passalong
	reference_object = _next_passalong.reference_object if _next_passalong else _method.get_object()


func _execute(args := []) -> Variant:
	if _next_passalong:
		return_val = _method.callv([self] + args)
	else:
		return_val = _method.callv(args)
	return return_val


## Will execute the next mod hook callable or vanilla method and return the result.[br]
## Make sure to call this method [i]somewhere[/i] in your [method ModLoaderMod.add_hook] [param mod_callable].
func execute_next(args := []) -> Variant:
	if _next_passalong:
		return_val = _next_passalong._execute(args)
	return return_val

