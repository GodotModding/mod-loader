## ModLoader - A mod loader for GDScript
#
# Written in 2021 by harrygiel <harrygiel@gmail.com>,
# in 2021 by Mariusz Chwalba <mariusz@chwalba.net>,
# in 2022 by Vladimir Panteleev <git@cy.md>,
# in 2023 by KANA <kai@kana.jetzt>,
# in 2023 by Darkly77,
# in 2023 by otDan <otdanofficial@gmail.com>,
# in 2023 by Qubus0/Ste
#
# To the extent possible under law, the author(s) have
# dedicated all copyright and related and neighboring
# rights to this software to the public domain worldwide.
# This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public
# Domain Dedication along with this software. If not, see
# <http://creativecommons.org/publicdomain/zero/1.0/>.

extends Node


## Emitted if something is logged with [ModLoaderLog]
signal logged(entry: ModLoaderLog.ModLoaderLogEntry)
## Emitted if the [member ModData.current_config] of any mod changed.
## Use the [member ModConfig.mod_id] of the [ModConfig] to check if the config of your mod has changed.
signal current_config_changed(config: ModConfig)
## Emitted when new mod hooks are created. A game restart is required to load them.
signal new_hooks_created

const LOG_NAME := "ModLoader"

var is_in_editor := OS.has_feature("editor")


# Main
# =============================================================================


func _init() -> void:
	# if mods are not enabled - don't load mods
	if ModLoaderStore.REQUIRE_CMD_LINE and not _ModLoaderCLI.is_running_with_command_line_arg("--enable-mods"):
		return

	# Only load the hook pack if not in the editor
	# We can't use it in the editor - see https://github.com/godotengine/godot/issues/19815
	# Mod devs can use the Dev Tool to generate hooks in the editor.
	if not is_in_editor and _ModLoaderFile.file_exists(_ModLoaderPath.get_path_to_hook_pack()):
		_load_mod_hooks_pack()

	# Rotate the log files once on startup. Can't be checked in utils, since it's static
	ModLoaderLog._rotate_log_file()

	if not ModLoaderStore.ml_options.enable_mods:
		ModLoaderLog.info("Mods are currently disabled", LOG_NAME)
		return

	# Ensure the ModLoaderStore and ModLoader autoloads are in the correct position.
	_ModLoaderGodot.check_autoload_positions()

	# Log the autoloads order. Helpful when providing support to players
	ModLoaderLog.debug_json_print("Autoload order", _ModLoaderGodot.get_autoload_array(), LOG_NAME)

	# Log game install dir
	ModLoaderLog.info("game_install_directory: %s" % _ModLoaderPath.get_local_folder_dir(), LOG_NAME)

	# Load user profiles into ModLoaderStore
	var _success_user_profile_load := ModLoaderUserProfile._load()

	# --- Start loading mods ---
	var loaded_count := 0

	# mod_path can be a directory in mods-unpacked or a mod.zip
	for mod_path in _ModLoaderPath.get_mod_paths_from_all_sources():
		var is_zip := _ModLoaderPath.is_zip(mod_path)

		# Load manifest file
		var manifest_data: Dictionary = _ModLoaderFile.load_manifest_file(mod_path)
		var manifest := ModManifest.new(manifest_data, mod_path)

		if not manifest.is_valid:
			ModLoaderLog.error("The mod from path \"%s\" cannot be loaded. Manifest validation failed with the following errors: %s" % [mod_path, "\n\t -".join(manifest.validation_messages_error)], LOG_NAME)
			continue

		# Init ModData
		var mod := ModData.new(manifest, mod_path)

		if not mod.is_loadable:
			ModLoaderStore.ml_options.disabled_mods.append(mod.manifest.get_mod_id())
			ModLoaderLog.error("Mod %s can't be loaded due to errors." % [mod.manifest.get_mod_id()], LOG_NAME)
			continue

		ModLoaderStore.mod_data[manifest.get_mod_id()] = mod

		if is_zip:
			var is_mod_loaded_successfully := ProjectSettings.load_resource_pack(mod_path, false)

			if not is_mod_loaded_successfully:
				ModLoaderLog.error("Failed to load mod zip from path \"%s\" into the virtual filesystem." % mod_path, LOG_NAME)
				continue

			# Notifies developer of an issue with Godot, where using `load_resource_pack`
			# in the editor WIPES the entire virtual res:// directory the first time you
			# use it. This means that unpacked mods are no longer accessible, because they
			# no longer exist in the file system. So this warning basically says
			# "don't use ZIPs with unpacked mods!"
			# https://github.com/godotengine/godot/issues/19815
			# https://github.com/godotengine/godot/issues/16798
			if is_in_editor:
				ModLoaderLog.warning(
					"Loading any resource packs (.zip/.pck) with `load_resource_pack` will WIPE the entire virtual res:// directory.
					If you have any unpacked mods in %s, they will not be loaded.Please unpack your mod ZIPs instead, and add them to %s" %
					[_ModLoaderPath.get_unpacked_mods_dir_path(), _ModLoaderPath.get_unpacked_mods_dir_path()], LOG_NAME, true
				)

		ModLoaderLog.success("%s loaded." % mod_path, LOG_NAME)
		loaded_count += 1

	ModLoaderLog.success("DONE: Loaded %s mod files into the virtual filesystem" % loaded_count, LOG_NAME)

	# Update active state of mods based on the current user profile
	ModLoaderUserProfile._update_disabled_mods()

	# Load all Mod Configs
	for dir_name in ModLoaderStore.mod_data:
		var mod: ModData = ModLoaderStore.mod_data[dir_name]
		if mod.manifest.get("config_schema") and not mod.manifest.config_schema.is_empty():
			mod.load_configs()

	ModLoaderLog.success("DONE: Loaded all mod configs", LOG_NAME)

	# Check for mods with load_before. If a mod is listed in load_before,
	# add the current mod to the dependencies of the the mod specified
	# in load_before.
	for dir_name in ModLoaderStore.mod_data:
		var mod: ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		_ModLoaderDependency.check_load_before(mod)

	# Run optional dependency checks.
	# If a mod depends on another mod that hasn't been loaded,
	# the dependent mod will be loaded regardless.
	for dir_name in ModLoaderStore.mod_data:
		var mod: ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		var _is_circular := _ModLoaderDependency.check_dependencies(mod, false)

	# Run dependency checks. If a mod depends on another
	# mod that hasn't been loaded, the dependent mod won't be loaded.
	for dir_name in ModLoaderStore.mod_data:
		var mod: ModData = ModLoaderStore.mod_data[dir_name]
		if not mod.is_loadable:
			continue
		var _is_circular := _ModLoaderDependency.check_dependencies(mod)

	# Sort mod_load_order by the importance score of the mod
	ModLoaderStore.mod_load_order = _ModLoaderDependency.get_load_order(ModLoaderStore.mod_data.values())

	# Log mod order
	var mod_i := 1
	for mod in ModLoaderStore.mod_load_order: # mod === mod_data
		mod = mod as ModData
		ModLoaderLog.info("mod_load_order -> %s) %s" % [mod_i, mod.dir_name], LOG_NAME)
		mod_i += 1

	# Instance every mod and add it as a node to the Mod Loader
	for mod in ModLoaderStore.mod_load_order:
		mod = mod as ModData

		# Continue if mod is disabled
		if not mod.is_active:
			continue

		ModLoaderLog.info("Initializing -> %s" % mod.manifest.get_mod_id(), LOG_NAME)
		_init_mod(mod)

	ModLoaderLog.debug_json_print("mod data", ModLoaderStore.mod_data, LOG_NAME)

	ModLoaderLog.success("DONE: Completely finished loading mods", LOG_NAME)

	_ModLoaderScriptExtension.handle_script_extensions()

	ModLoaderLog.success("DONE: Installed all script extensions", LOG_NAME)

	_ModLoaderSceneExtension.refresh_scenes()

	_ModLoaderSceneExtension.handle_scene_extensions()

	ModLoaderLog.success("DONE: Applied all scene extensions", LOG_NAME)

	ModLoaderStore.is_initializing = false


func _load_mod_hooks_pack() -> void:
	# Load mod hooks
	var load_hooks_pack_success := ProjectSettings.load_resource_pack(_ModLoaderPath.get_path_to_hook_pack())
	if not load_hooks_pack_success:
		ModLoaderLog.error("Failed loading hooks pack from: %s" % _ModLoaderPath.get_path_to_hook_pack(), LOG_NAME)
	else:
		ModLoaderLog.debug("Successfully loaded hooks pack from: %s" % _ModLoaderPath.get_path_to_hook_pack(), LOG_NAME)


# Instantiate every mod and add it as a node to the Mod Loader.
func _init_mod(mod: ModData) -> void:
	var mod_main_path := mod.get_required_mod_file_path(ModData.RequiredModFiles.MOD_MAIN)
	var mod_overwrites_path := mod.get_optional_mod_file_path(ModData.OptionalModFiles.OVERWRITES)

	# If the mod contains overwrites initialize the overwrites script
	if mod.is_overwrite:
		ModLoaderLog.debug("Overwrite script detected -> %s" % mod_overwrites_path, LOG_NAME)
		var mod_overwrites_script := load(mod_overwrites_path)
		mod_overwrites_script.new()
		ModLoaderLog.debug("Initialized overwrite script -> %s" % mod_overwrites_path, LOG_NAME)

	ModLoaderLog.debug("Loading script from -> %s" % mod_main_path, LOG_NAME)
	var mod_main_script: GDScript = ResourceLoader.load(mod_main_path)
	ModLoaderLog.debug("Loaded script -> %s" % mod_main_script, LOG_NAME)

	var mod_main_instance: Node = mod_main_script.new()
	mod_main_instance.name = mod.manifest.get_mod_id()

	ModLoaderStore.saved_mod_mains[mod_main_path] = mod_main_instance

	ModLoaderLog.debug("Adding mod main instance to ModLoader -> %s" % mod_main_instance, LOG_NAME)
	add_child(mod_main_instance, true)
