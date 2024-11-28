#class_name ModHookPreprocessorTestScriptB
extends ModHookPreprocessorTestScriptA


func vanilla_2078495481__ready() -> void:
	super._ready() # I'm super ready here


func vanilla_2078495481_that_is_super() -> void:
	super.that_is_super()


# ModLoader Hooks - The following code has been automatically added by the Godot Mod Loader.


func _ready():
	_ModLoaderHooks.call_hooks(vanilla_2078495481__ready, [], 2262823725)


func that_is_super():
	_ModLoaderHooks.call_hooks(vanilla_2078495481_that_is_super, [], 2065563731)
