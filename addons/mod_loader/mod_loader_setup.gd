extends SceneTree


func _init() -> void:
	if ProjectSettings.get_setting("autoload/ModLoaderStore") and ProjectSettings.get_setting("autoload/ModLoader"):
		print("Mod Loader already setup.")
		print("Switch to main scene")
		change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	else:
		setup()


func setup() -> void:
		print("#################################")
		print("Start Godot Mod Loader Setup")
		print("#################################")
		ProjectSettings.set_setting("application/config/use_hidden_project_data_directory", false)
		if not ProjectSettings.get_setting("application/config/name").ends_with("Modded"):
			ProjectSettings.set_setting("application/config/name", "%s - Modded" % ProjectSettings.get_setting("application/config/name"))

		# Add Autoloads
		ProjectSettings.set_setting("autoload/ModLoaderStore", "*res://addons/mod_loader/mod_loader_store.gd")
		ProjectSettings.set_setting("autoload/ModLoader", "*res://addons/mod_loader/mod_loader.gd")

		print("Load mod loader class cache")
		var global_script_class_cache_mod_loader := ConfigFile.new()
		global_script_class_cache_mod_loader.load("res://addons/mod_loader/setup/global_script_class_cache_mod_loader.cfg")
		print("Load game class cache")
		var global_script_class_cache_game := ConfigFile.new()
		global_script_class_cache_game.load("res://.godot/global_script_class_cache.cfg")

		print("Create new class cache")
		var global_classes_mod_loader := global_script_class_cache_mod_loader.get_value("", "list")
		var global_classes_game := global_script_class_cache_game.get_value("", "list")
		print("Combine class cache")
		var global_classes_combined := []
		global_classes_combined.append_array(global_classes_mod_loader)
		global_classes_combined.append_array(global_classes_game)

		if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path("res://godot")):
			print("Create godot dir")
			DirAccess.make_dir_absolute(ProjectSettings.globalize_path("res://godot"))

		print("Save combined class cache")
		var global_script_class_cache_combined := ConfigFile.new()
		global_script_class_cache_combined.set_value("", "list", global_classes_combined)
		global_script_class_cache_combined.save("res://godot/global_script_class_cache.cfg")

		print("copy uid_cache.bin")
		# DirAccess can't open the uid_cache.bin for some reason.
		var file_uid_cache := FileAccess.open("res://.godot/uid_cache.bin", FileAccess.READ)
		var error_uid_cache := file_uid_cache.get_error()
		print("error_uid_cache: %s" % error_string(error_uid_cache))
		if error_uid_cache == OK:
			var file_uid_cache_content := file_uid_cache.get_buffer(file_uid_cache.get_length())
			var new_uid_cache := FileAccess.open("res://godot/uid_cache.bin", FileAccess.WRITE)
			var error_new_uid_cache := new_uid_cache.get_error()
			print("error_new_uid_cache: %s" % error_string(error_new_uid_cache))
			if error_new_uid_cache == OK:
				new_uid_cache.store_buffer(file_uid_cache_content)

		print("Save Project Settings to override.cfg")
		ProjectSettings.save_custom(ProjectSettings.globalize_path("res://override.cfg"))

		restart()


func restart() -> void:
	OS.set_restart_on_exit(true)
	quit()
