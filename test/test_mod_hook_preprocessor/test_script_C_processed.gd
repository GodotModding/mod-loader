#class_name ModHookPreprocessorTestScriptC
extends Node

var six: set = actual_setter
#var six: set = set_exclude_me
var seven: set= actual_setter, get = actually_get_something
var eight: get = actually_get_something, set= actual_setter
var nine: int: set= actual_setter, get = actually_get_something
var thirteen: int: set= actual_setter ,get = actually_get_something
var ten: Array[String]: get = actually_get_something, set= actual_setter
var eleven: = 4 #set= set_exclude_me, get = get_exclude_me
var twelve: set= actual_setter#, get = get_exclude_me
var four10: get = actually_get_something, set= actual_setter
var _5teen: get = actually_get_something, set= actual_setter
var _16: get = actually_get_something, set= actual_setter
var _seven_teen: get = actually_get_something, set= actual_setter
var eighteen: get = actually_get_something, \
set= actual_setter

@export var one : Vector2 = Vector2.ZERO :
	set(value):
		one = value
		print("")
		pass
		get_groups()
	get:
		return one

var two: int = 0:
	set(v): two = v

var three: int = 0:
	get: return three + 5

var four: int = 0:
	get: return three + 6

var five:
	get:
		set_something()
		return five *2
	set (value):
		one = value
		print("")
		pass
		get_groups()


func vanilla_2078531418__ready() -> void:
	pass


func vanilla_2078531418_method(
	one, #Some comment
	two, 	three:  int, # More comments
		four
):
	pass


func vanilla_2078531418_super_something():
	pass


func vanilla_2078531418_super_something_else():
	print("oy")


func vanilla_2078531418_sup_func_two(): pass


func vanilla_2078531418_sup_func():
	pass


#func other_test_func(some_param: Cool):
	#pass # test if comments match
func vanilla_2078531418_other_test_func():
	pass


#func more_comment_testing(some_param: Cool) -> void:
	#pass # test if comments match
# 	func more_comment_testing(some_param: Cool) -> void:
	#pass # test if comments match
func vanilla_2078531418_more_comment_testing() -> void:
	pass


static func vanilla_2078531418_static_super():
	pass


func vanilla_2078531418_this_is_so_cursed():
	pass


func vanilla_2078531418_this_too():
	pass


# func please_stop()
#func please_stop()
func vanilla_2078531418_please_stop():
	pass


func vanilla_2078531418_why_would_you(put: int, \
	backslashes := "\\", in_here := "?!\n"
	):
	pass


class SomeTestingSubclass:
	# check that we are not getting inner funcs with the same name
	func get_something():
		return "something"

	func set_something():
		pass


func vanilla_2078531418_param_super(one: int, two: String) -> int:
	return one


func vanilla_2078531418_other_param_super(one: int, two: String) -> int:
	return one


func vanilla_2078531418_get_something():
	return "something"


func vanilla_2078531418_set_something():
	pass


func actually_get_something():
	pass


func actual_setter(val):
	six = val


func vanilla_2078531418_set_exclude_me():
	pass


func vanilla_2078531418_get_exclude_me():
	pass


func vanilla_2078531418_definitely_a_coroutine(args := []):
	await tree_entered


func vanilla_2078531418_definitely_a_coroutine2(args := []):
	var callback := func():
		print("test")
	return await callback.callv(args)


func vanilla_2078531418_definitely_a_coroutine3(args := []):
	var callback := func():
		print("test")
	return await callback.callv([self] + args)


func vanilla_2078531418_definitely_a_coroutine4(args := []):
	await get_tree().create_timer(1).timeout


func vanilla_2078531418_absolutely_not_a_coroutine(args := []):
	get_something() # await is a keyword
	pass


func vanilla_2078531418_definitely_a_coroutine5(args := []):
	print("# hello", await get_something())


func vanilla_2078531418_definitely_a_coroutine6(args := []):
	print(""" test
	# hello""", await get_something())


func vanilla_2078531418_absolutely_not_a_coroutine2(args := []):
	print(""" test
	# hello""", get_something()) # don't await


func vanilla_2078531418_definitely_a_coroutine7(args := []):
	print("# \'hello", await get_something())


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418__ready, [], 2330625102)
	else:
		vanilla_2078531418__ready()


func method(one, #Somecomment
two, three: int, #Morecomments
four):
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_method, [one, two, three, four], 2863650651)
	else:
		vanilla_2078531418_method(one, two, three, four)


func super_something():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_super_something, [], 561212438)
	else:
		vanilla_2078531418_super_something()


func super_something_else():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_super_something_else, [], 683196062)
	else:
		vanilla_2078531418_super_something_else()


func sup_func_two():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_sup_func_two, [], 1626900374)
	else:
		vanilla_2078531418_sup_func_two()


func sup_func():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_sup_func, [], 1698024413)
	else:
		vanilla_2078531418_sup_func()


func other_test_func():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_other_test_func, [], 124073286)
	else:
		vanilla_2078531418_other_test_func()


func more_comment_testing():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_more_comment_testing, [], 502348540)
	else:
		vanilla_2078531418_more_comment_testing()


static func static_super():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_static_super, [], 1720709936)
	else:
		vanilla_2078531418_static_super()


func this_is_so_cursed():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_this_is_so_cursed, [], 1705479347)
	else:
		vanilla_2078531418_this_is_so_cursed()


func this_too():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_this_too, [], 1507098083)
	else:
		vanilla_2078531418_this_too()


func please_stop():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_please_stop, [], 2851245561)
	else:
		vanilla_2078531418_please_stop()


func why_would_you(put: int, \
backslashes: ="\\", in_here: ="?!\n"):
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_why_would_you, [put, backslashes, in_here], 1414126584)
	else:
		vanilla_2078531418_why_would_you(put, backslashes, in_here)


func param_super(one: int, two: String) -> int:
	if ModLoaderStore.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2078531418_param_super, [one, two], 2371788505)
	else:
		return vanilla_2078531418_param_super(one, two)


func other_param_super(one: int, two: String) -> int:
	if ModLoaderStore.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2078531418_other_param_super, [one, two], 2009491482)
	else:
		return vanilla_2078531418_other_param_super(one, two)


func get_something():
	if ModLoaderStore.any_mod_hooked:
		return _ModLoaderHooks.call_hooks(vanilla_2078531418_get_something, [], 3887992391)
	else:
		return vanilla_2078531418_get_something()


func set_something():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_set_something, [], 2687664211)
	else:
		vanilla_2078531418_set_something()


func set_exclude_me():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_set_exclude_me, [], 1755202272)
	else:
		vanilla_2078531418_set_exclude_me()


func get_exclude_me():
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_get_exclude_me, [], 2711326548)
	else:
		vanilla_2078531418_get_exclude_me()


func definitely_a_coroutine(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine, [args], 1072984126)
	else:
		await vanilla_2078531418_definitely_a_coroutine(args)


func definitely_a_coroutine2(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine2, [args], 1048737840)
	else:
		return await vanilla_2078531418_definitely_a_coroutine2(args)


func definitely_a_coroutine3(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		return await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine3, [args], 1048737841)
	else:
		return await vanilla_2078531418_definitely_a_coroutine3(args)


func definitely_a_coroutine4(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine4, [args], 1048737842)
	else:
		await vanilla_2078531418_definitely_a_coroutine4(args)


func absolutely_not_a_coroutine(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_absolutely_not_a_coroutine, [args], 2502244037)
	else:
		vanilla_2078531418_absolutely_not_a_coroutine(args)


func definitely_a_coroutine5(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine5, [args], 1048737843)
	else:
		await vanilla_2078531418_definitely_a_coroutine5(args)


func definitely_a_coroutine6(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine6, [args], 1048737844)
	else:
		await vanilla_2078531418_definitely_a_coroutine6(args)


func absolutely_not_a_coroutine2(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		_ModLoaderHooks.call_hooks(vanilla_2078531418_absolutely_not_a_coroutine2, [args], 969674647)
	else:
		vanilla_2078531418_absolutely_not_a_coroutine2(args)


func definitely_a_coroutine7(args: =[]):
	if ModLoaderStore.any_mod_hooked:
		await _ModLoaderHooks.call_hooks_async(vanilla_2078531418_definitely_a_coroutine7, [args], 1048737845)
	else:
		await vanilla_2078531418_definitely_a_coroutine7(args)
