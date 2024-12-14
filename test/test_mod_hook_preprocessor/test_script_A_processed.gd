#class_name ModHookPreprocessorTestScriptA
extends Node


@export var some_export_var_with_type: float = 1.11
@export_dir var some_export_var_no_type

var some_var_no_type = "text"
var some_var_with_type: int = -1
var some_var_with_inline_set :
	set(new_value):
		some_var_with_inline_set = new_value
var some_var_with_inline_get :
	get():
		return some_var_with_inline_get
var some_var_with_inline_get_set :
	set(new_value):
		some_var_with_inline_get_set = new_value
	get():
		return some_var_with_inline_get_set
var some_var_with_set := _set_some_var_with_set
var some_var_with_get := _get_some_var_with_get

@onready var some_var_onready_no_type
@onready var some_var_onready_with_type: String = "ready"


func vanilla_2078459544__ready() -> void:
	some_var_no_type = "update"
	await get_tree().create_timer(0.1).timeout
	some_var_with_inline_set = "time has passed"


func vanilla_2078459544__process(delta: float) -> void:
	pass


func vanilla_2078459544_that_is_super() -> void:
	pass


func vanilla_2078459544_give_default() -> String:
	return "AAAAAAHHHHHH"


func vanilla_2078459544_did_you_know_you_can_realy_write_your_function___like_this(param_1: String \
,param_2 = give_default()                 ) ->   \
			void:
	pass


func vanilla_2078459544__set_some_var_with_set(new_value):
	some_var_with_set = new_value


func vanilla_2078459544__get_some_var_with_get():
	return some_var_with_get


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	await _ModLoaderHooks.call_hooks_async(vanilla_2078459544__ready, [], 2195022348)


func _process(delta: float):
	_ModLoaderHooks.call_hooks(vanilla_2078459544__process, [delta], 319893654)


func that_is_super():
	_ModLoaderHooks.call_hooks(vanilla_2078459544_that_is_super, [], 3896778322)


func give_default() -> String:
	return _ModLoaderHooks.call_hooks(vanilla_2078459544_give_default, [], 3905258887)


func did_you_know_you_can_realy_write_your_function___like_this(param_1: String\
, param_2=give_default()):
	_ModLoaderHooks.call_hooks(vanilla_2078459544_did_you_know_you_can_realy_write_your_function___like_this, [param_1, param_2], 833669474)


func _set_some_var_with_set(new_value):
	_ModLoaderHooks.call_hooks(vanilla_2078459544__set_some_var_with_set, [new_value], 1894552580)


func _get_some_var_with_get():
	return _ModLoaderHooks.call_hooks(vanilla_2078459544__get_some_var_with_get, [], 2756748012)
