class_name ModLoaderHook
extends RefCounted
## Small class to pass data between mod hook calls.[br]
## For examples, see [method ModLoaderMod.add_hook].


## The reference object is usually the [Node] that the vanilla script is attached to. [br]
## If the hooked method is [code]static[/code], it will contain the [GDScript] itself.
var reference_object: Object

var _callbacks := []
var _callback_index :=-1


func _init(reference_object:Object, callbacks : Array) -> void:
	self.reference_object = reference_object
	_callbacks = callbacks
	_callback_index = callbacks.size()

## Will execute the next mod hook callable or vanilla method and return the result.[br]
## Make sure to call this method [i]somewhere[/i] in the [param mod_callable] you pass to [method ModLoaderMod.add_hook]. [br]
##
## [br][b]Parameters:[/b][br]
## - [param args] ([Array]): An array of all arguments passed into the vanilla function. [br]
##
## [br][b]Returns:[/b] [Variant][br][br]
func execute_next(args := []) -> Variant:
	_callback_index -= 1
	assert(_callback_index >= 0, "_callback_index should never be negative. ModLoaderHook was modified in an unsupported way.") 

	var callback =  _callbacks[_callback_index]

	#Vanilla call is always at index 0 and needs to be called without the hooked being passed
	if _callback_index == 0:
		return callback.callv(args)

	return callback.callv([self] + args)