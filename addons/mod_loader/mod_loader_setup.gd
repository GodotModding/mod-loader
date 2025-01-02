extends SceneTree


func _init() -> void:
	if ProjectSettings.get_setting("autoload/ModLoaderStore") and ProjectSettings.get_setting("autoload/ModLoader"):
		print("Mod Loader already setup.")
		print("Switch to main scene")
		change_scene_to_file.call_deferred(ProjectSettings.get_setting("application/run/main_scene"))
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

		print("copy all files in res://.godot to res://godot")
		# DirAccess can't open the uid_cache.bin for some reason.
		var godot_files := get_flat_view_dict("res://.godot")

		for file in godot_files:
			copy_file(file, file.trim_prefix("res://.godot").insert(0, "res://godot"))

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

		print("Save Project Settings to override.cfg")
		ProjectSettings.save_custom(ProjectSettings.globalize_path("res://override.cfg"))

		restart()


func copy_file(from: String, to: String) -> void:
	print("Copy file from: \"%s\" to: \"%s\"" % [from, to])
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(to.get_base_dir())):
		print("Creating dir \"%s\"" % ProjectSettings.globalize_path(to.get_base_dir()))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(to.get_base_dir()))

	var file_from := FileAccess.open(from, FileAccess.READ)
	var file_from_error := file_from.get_error()

	if not file_from_error == OK:
		print("file_from_error: %s" % error_string(file_from_error))
		return

	var file_from_content := file_from.get_buffer(file_from.get_length())
	var file_to := FileAccess.open(to, FileAccess.WRITE)
	var file_to_error := file_to.get_error()

	if not file_to_error == OK:
		print("file_to_error: %s" % error_string(file_to_error))
		return

	file_to.store_buffer(file_from_content)


# Slightly modified version of:
# https://gist.github.com/willnationsdev/00d97aa8339138fd7ef0d6bd42748f6e
# Removed .import from the extension filter.
# p_match is a string that filters the list of files.
# If p_match_is_regex is false, p_match is directly string-searched against the FILENAME.
# If it is true, a regex object compiles p_match and runs it against the FILEPATH.
func get_flat_view_dict(
	p_dir := "res://",
 	p_match := "",
	p_match_file_extensions: Array[StringName] = [],
	p_match_is_regex := false,
	include_empty_dirs := false,
	ignored_dirs: Array[StringName] = []
) -> PackedStringArray:
	var data: PackedStringArray = []
	var regex: RegEx

	if p_match_is_regex:
		regex = RegEx.new()
		var _compile_error: int = regex.compile(p_match)
		if not regex.is_valid():
			return data

	var dirs := [p_dir]
	var first := true
	while not dirs.is_empty():
		var dir_name : String = dirs.back()
		var dir := DirAccess.open(dir_name)
		dirs.pop_back()

		if dir_name.lstrip("res://").get_slice("/", 0) in ignored_dirs:
			continue

		if dir:
			var _dirlist_error: int = dir.list_dir_begin()
			var file_name := dir.get_next()
			if include_empty_dirs and not dir_name == p_dir:
				data.append(dir_name)
			while file_name != "":
				if not dir_name == "res://":
					first = false
				# ignore hidden, temporary, or system content
				if not file_name.begins_with(".") and not file_name.get_extension() == "tmp":
					# If a directory, then add to list of directories to visit
					if dir.current_is_dir():
						dirs.push_back(dir.get_current_dir() + "/" + file_name)
					# If a file, check if we already have a record for the same name
					else:
						var path := dir.get_current_dir() + ("/" if not first else "") + file_name
						# grab all
						if not p_match and not p_match_file_extensions:
							data.append(path)
						# grab matching strings
						elif not p_match_is_regex and p_match and file_name.contains(p_match):
							data.append(path)
						# garb matching file extension
						elif p_match_file_extensions and file_name.get_extension() in p_match_file_extensions:
							data.append(path)
						# grab matching regex
						elif p_match_is_regex:
							var regex_match := regex.search(path)
							if regex_match != null:
								data.append(path)
				# Move on to the next file in this directory
				file_name = dir.get_next()
			# We've exhausted all files in this directory. Close the iterator.
			dir.list_dir_end()
	return data


func restart() -> void:
	OS.set_restart_on_exit(true)
	quit()
