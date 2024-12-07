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
	# mod_path can be a directory in mods-unpacked or a mod.zip
	for mod_path in _ModLoaderPath.get_mod_paths_from_all_sources():
		var zip_path := mod_path if _ModLoaderPath.is_zip(mod_path) else ""

		# Load manifest files
		var manifest_data: Dictionary = _ModLoaderFile.load_manifest_file(mod_path)
		var manifest := ModManifest.new(manifest_data, mod_path)

		if not manifest.is_valid:
			ModLoaderLog.error("The mod from path \"%s\" cannot be loaded. Manifest validation failed with the following errors: %s" % [mod_path, "\n\t -".join(manifest.validation_messages_error)], LOG_NAME)
			continue

		# Init ModData
		var mod := ModData.new(manifest, mod_path)

		if not mod:
			ModLoaderStore.ml_options.disabled_mods.append(mod.manifest.get_mod_id())
			ModLoaderLog.error("Mod %s can't be loaded due to errors." % [mod.manifest.get_mod_id()], LOG_NAME)
			continue

		ModLoaderStore.mod_data[manifest.get_mod_id()] = mod




func _load_mod_hooks_pack() -> void:
	# Load mod hooks
	var load_hooks_pack_success := ProjectSettings.load_resource_pack(_ModLoaderPath.get_path_to_hook_pack())
	if not load_hooks_pack_success:
		ModLoaderLog.error("Failed loading hooks pack from: %s" % _ModLoaderPath.get_path_to_hook_pack(), LOG_NAME)
	else:
		ModLoaderLog.debug("Successfully loaded hooks pack from: %s" % _ModLoaderPath.get_path_to_hook_pack(), LOG_NAME)
