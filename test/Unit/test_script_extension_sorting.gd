extends GutTest


#var order_before_357_correct := [
#	"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_b.gd",
#	"res://mods-unpacked/test-mod2/extensions/script_extension_sorting/script_c.gd",
#	"res://mods-unpacked/test-mod1/extensions/script_extension_sorting/script_c.gd",
#	"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_d.gd"
#]

var order_after_357_correct := [
	"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_b.gd",
	"res://mods-unpacked/test-mod1/extensions/script_extension_sorting/script_c.gd",
	"res://mods-unpacked/test-mod2/extensions/script_extension_sorting/script_c.gd",
	"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_d.gd"
]


func test_handle_script_extensions():
	var extension_paths := [
		"res://mods-unpacked/test-mod1/extensions/script_extension_sorting/script_c.gd",
		"res://mods-unpacked/test-mod2/extensions/script_extension_sorting/script_c.gd",
		"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_b.gd",
		"res://mods-unpacked/test-mod3/extensions/script_extension_sorting/script_d.gd"
	]

	_ModLoaderScriptExtension.InheritanceSorting.new(extension_paths)

	assert_true(extension_paths == order_after_357_correct, "Expected %s but was %s instead" % [JSON.stringify(order_after_357_correct, "\t"), JSON.stringify(extension_paths, "\t")])
