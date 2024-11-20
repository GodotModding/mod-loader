extends Node


const TEST_MOD3_DIR := "test-mod3"
const TEST_MOD3_LOG_NAME := "test-mod3:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(TEST_MOD3_DIR)
	# Add extensions
	install_script_extensions()
	# Add translations
	add_translations()


# `install_script_extension` is commented out to prevent interference
# with the script extension sorting test. Applying script extensions
# causes the `.get_base_script()` call in `_ModLoaderScriptExtension.InheritanceSorting`
# to return an incorrect value.
func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	#ModLoaderMod.install_script_extension(extensions_dir_path.path_join("script_extension_sorting/script_b.gd"))
	#ModLoaderMod.install_script_extension(extensions_dir_path.path_join("script_extension_sorting/script_d.gd"))


func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	pass