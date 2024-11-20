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


func _init(reference_object: Object, callbacks: Array[Callable]) -> void:
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
	var callback := next_callback()

	# Vanilla needs to be called without the hook chain being passed
	if is_vanilla():
		return callback.callv(args)

	return callback.callv([self] + args)


## Same as [method execute_next], but asynchronous - it can be used with [code]await[/code]. [br]
## This hook needs to be used if the vanilla method uses [code]await[/code] somewhere. [br]
## Make sure to call this method [i][color=orange]once[/color][/i] somewhere in the [param mod_callable] you pass to [method ModLoaderMod.add_hook]. [br]
##
## [br][b]Parameters:[/b][br]
## - [param args] ([Array]): An array of all arguments passed into the vanilla function. [br]
##
## [br][b]Returns:[/b] [Variant][br][br]
func execute_next_async(args := []) -> Variant:
	var callback := next_callback()

	# Vanilla needs to be called without the hook chain being passed
	if is_vanilla():
		return await callback.callv(args)

	return await callback.callv([self] + args)


func next_callback() -> Variant:
	_callback_index -= 1
	if not _callback_index >= 0:
		ModLoaderLog.fatal(
			"The hook chain index should never be negative. " +
			"A mod hook has called execute_next twice or ModLoaderHookChain was modified in an unsupported way.",
			LOG_NAME
		)
		return

	return _callbacks[_callback_index]


func is_vanilla() -> bool:
	return _callback_index == 0
