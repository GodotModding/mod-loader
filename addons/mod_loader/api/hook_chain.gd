class_name ModLoaderHookChain
extends RefCounted
## Small class to keep the state of hook execution chains and move between mod hook calls.[br]
## For examples, see [method ModLoaderMod.add_hook].


## The reference object is usually the [Node] that the vanilla script is attached to. [br]
## If the hooked method is [code]static[/code], it will contain the [GDScript] itself.
var reference_object: Object

var _callbacks: Array[Callable] = []
var _callback_index := -1


const LOG_NAME := "ModLoaderHookChain"


# `callbacks` is kept as untyped Array for simplicity when creating a new chain.
# This approach allows direct use of `[vanilla_method] + hooks` without the need to cast types with Array.assign().
func _init(reference_object: Object, callbacks: Array) -> void:
	self.reference_object = reference_object
	_callbacks.assign(callbacks)
	_callback_index = callbacks.size()


## Will execute the next mod hook callable or vanilla method and return the result.[br]
## Make sure to call this method [i][color=orange]once[/color][/i] somewhere in the [param mod_callable] you pass to [method ModLoaderMod.add_hook]. [br]
##
## [br][b]Parameters:[/b][br]
## - [param args] ([Array]): An array of all arguments passed into the vanilla function. [br]
##
## [br][b]Returns:[/b] [Variant][br][br]
func execute_next(args := []) -> Variant:
	_callback_index -= 1

	if _callback_index < 0:
		ModLoaderLog.fatal(
			"The hook chain index should never be negative. " +
			"A mod hook has called execute_next twice or ModLoaderHookChain was modified in an unsupported way.",
			LOG_NAME
		)
		return

	var callback :=  _callbacks[_callback_index]

	# Vanilla call is always at index 0 and needs to be called without the hook chain being passed
	if _callback_index == 0:
		return callback.callv(args)

	return callback.callv([self] + args)
