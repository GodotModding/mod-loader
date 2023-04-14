class_name ModLoaderUserProfile
extends Object


# This Class provides methods for working with user profiles.

const LOG_NAME := "ModLoader:UserProfile"
const FILE_PATH_USER_PROFILES = "user://mod_user_profiles.json"

class Profile:
	extends Reference

	var name := ""
	var mod_list := {}


# API profile functions
# =============================================================================

# Enables a mod - it will be loaded on the next game start
static func enable_mod(mod_id: String, profile_name := ModLoaderStore.current_user_profile) -> bool:
	return _handle_mod_state(mod_id, profile_name, true)


# Disables a mod - it will not be loaded on the next game start
static func disable_mod(mod_id: String, profile_name := ModLoaderStore.current_user_profile) -> bool:
	return _handle_mod_state(mod_id, profile_name, false)


# Delete a mod from a user profiles mod_list
static func delete_mod(mod_id: String, profile_name := ModLoaderStore.current_user_profile) -> bool:
	# Verify whether the mod_id is present in the profile's mod_list.
	if not _is_mod_id_in_mod_list(mod_id, profile_name):
		return false

	# Erase the mod from the mod_list
	ModLoaderStore.user_profiles[profile_name].mod_list.erase(mod_id)

	# Save profiles to the user profiles JSON file
	return _save()


# Creates a new user profile with the given name, using the currently loaded mods as the mod list.
static func create(name: String) -> bool:
	# Verify that the profile name is not already in use
	if ModLoaderStore.user_profiles.has(name):
		ModLoaderUtils.log_error("User profile with the name of \"%s\" already exists." % name, LOG_NAME)
		return false

	var mod_list := {}

	# Add all currently loaded mods to the mod_list as active
	for mod_id in ModLoader.mod_data.keys():
		mod_list[mod_id] = true

	var new_profile := _create_new_profile(name, mod_list)

	# Set it as the current profile
	ModLoaderStore.current_user_profile = name

	# Store the new profile in the ModLoaderStore
	ModLoaderStore.user_profiles[name] = new_profile

	# Store the new profile in the json file
	return _save()


# Sets the current user profile to the specified profile_name.
static func set_profile(profile_name: String) -> bool:
	# Check if there is a user profile with the specified name
	if not ModLoaderStore.user_profiles.has(profile_name):
		ModLoaderUtils.log_error("User profile with name \"%s\" not found." % profile_name, LOG_NAME)
		return false

	# Update the current_user_profile in the ModLoaderStore
	ModLoaderStore.current_user_profile = profile_name

	return true


# Deletes a user profile with the given profile_name.
static func delete(profile_name: String) -> bool:
	# If the current_profile is about to get deleted change it to default
	if ModLoaderStore.current_user_profile == profile_name:
		ModLoaderUtils.log_error(str(
			"You cannot delete the currently selected user profile \"%s\" " +
			"because it is currently in use. Please switch to a different profile before deleting this one.") % profile_name,
		LOG_NAME)
		return false

	# Deleting the default profile is not allowed
	if profile_name == "default":
		ModLoaderUtils.log_error("You can't delete the default profile", LOG_NAME)
		return false

	# Delete the user profile
	if not ModLoaderStore.user_profiles.erase(profile_name):
		# Erase returns false if the the key is not present in user_profiles
		ModLoaderUtils.log_error("User profile with name \"%s\" not found." % profile_name, LOG_NAME)
		return false

	# Save profiles to the user profiles JSON file
	return _save()


# Returns an array containing all user profiles stored in ModLoaderStore
static func get_all_as_array() -> Array:
	var user_profiles := []

	for user_profile_name in ModLoaderStore.user_profiles.keys():
		user_profiles.push_back(ModLoaderStore.user_profiles[user_profile_name])

	return user_profiles


# Internal profile functions
# =============================================================================

# Update the global list of disabled mods based on the current user profile
static func _update_disabled_mods() -> void:
	var user_profile_disabled_mods := []
	var current_user_profile : Profile

	# Check if a current user profile is set
	if ModLoaderStore.current_user_profile == "":
		ModLoaderUtils.log_info("There is no current user profile. The \"default\" profile will be created.", LOG_NAME)
		return

	current_user_profile = ModLoaderStore.user_profiles[ModLoaderStore.current_user_profile]

	# Iterate through the mod list in the current user profile to find disabled mods
	for mod_id in current_user_profile.mod_list:
		if not current_user_profile.mod_list[mod_id]:
			user_profile_disabled_mods.push_back(mod_id)

	# Append the disabled mods to the global list of disabled mods
	ModLoaderStore.ml_options.disabled_mods.append_array(user_profile_disabled_mods)


# This function updates the mod lists of all user profiles with newly loaded mods that are not already present.
# It does so by comparing the current set of loaded mods with the mod list of each user profile, and adding any missing mods.
static func _update_mod_lists() -> bool:
	var current_mod_list := {}

	# Create a mod_list with the currently loaded mods
	for mod_id in ModLoader.mod_data.keys():
		current_mod_list[mod_id] = true

	# Iterate over all user profiles and merge the current mod list with each profile's mod list
	for profile_name in ModLoaderStore.user_profiles.keys():
		var profile: Profile = ModLoaderStore.user_profiles[profile_name]
		profile.mod_list.merge(current_mod_list)

	# Save the updated user profiles to the JSON file
	return _save()


# Handles the activation or deactivation of a mod in a user profile.
static func _handle_mod_state(mod_id: String, profile_name: String, activate: bool) -> bool:
	# Verify whether the mod_id is present in the profile's mod_list.
	if not _is_mod_id_in_mod_list(mod_id, profile_name):
		return false

	# Handle mod state
	ModLoaderStore.user_profiles[profile_name].mod_list[mod_id] = activate

	# Save profiles to the user profiles JSON file
	return _save()


# Checks whether a given mod_id is present in the mod_list of the specified user profile.
# Returns True if the mod_id is present, False otherwise.
static func _is_mod_id_in_mod_list(mod_id: String, profile_name: String) -> bool:
	# Return false if the mod_id is not in the profile's mod_list
	if not ModLoaderStore.user_profiles[profile_name].mod_list.has(mod_id):
		ModLoaderUtils.log_error("Mod id \"%s\" not found in the \"mod_list\" of user profile \"%s\"." % [mod_id, profile_name], LOG_NAME)
		return false

	# Return true if the mod_id is in the profile's mod_list
	return true


# Creates a new Profile with the given name and mod list.
# Returns the newly created Profile object.
static func _create_new_profile(name: String, mod_list: Dictionary) -> Profile:
	var new_profile := Profile.new()

	# If no name is provided, log an error and return null
	if name == "":
		ModLoaderUtils.log_error("Please provide a name for the new profile", LOG_NAME)
		return null

	# Set the profile name
	new_profile.name = name

	# If no mods are specified in the mod_list, log a warning and return the new profile
	if mod_list.keys().size() == 0:
		ModLoaderUtils.log_warning("No mod_ids inside \"mod_list\" for user profile \"%s\" " % name, LOG_NAME)
		return new_profile

	# Set the mod_list
	new_profile.mod_list = mod_list

	return new_profile


# Loads user profiles from the JSON file and adds them to ModLoaderStore.
static func _load() -> bool:
	# Load JSON data from the user profiles file
	var data := ModLoaderUtils.get_json_as_dict(FILE_PATH_USER_PROFILES)

	# If there is no data, log an error and return
	if data.empty():
		ModLoaderUtils.log_error("No profile file found at \"%s\"" % FILE_PATH_USER_PROFILES, LOG_NAME)
		return false

	# Set the current user profile to the one specified in the data
	ModLoaderStore.current_user_profile = data.current_profile

	# Loop through each profile in the data and add them to ModLoaderStore
	for profile_name in data.profiles.keys():
		# Get the profile data from the JSON object
		var profile_data: Dictionary = data.profiles[profile_name]

		# Create a new profile object and add it to ModLoaderStore.user_profiles
		var new_profile := _create_new_profile(profile_name, profile_data.mod_list)
		ModLoaderStore.user_profiles[profile_name] = new_profile

	return true


# Saves the user profiles in the ModLoaderStore to the user profiles JSON file.
static func _save() -> bool:
	# Initialize a dictionary to hold the serialized user profiles data
	var save_dict := {
		"current_profile": "",
		"profiles": {}
	}

	# Set the current profile name in the save_dict
	save_dict.current_profile = ModLoaderStore.current_user_profile

	# Serialize the mod_list data for each user profile and add it to the save_dict
	for profile_name in ModLoaderStore.user_profiles.keys():
		var profile: Profile = ModLoaderStore.user_profiles[profile_name]

		save_dict.profiles[profile.name] = {}
		save_dict.profiles[profile.name].mod_list = {}

		# For each mod_id in the mod_list, add its ID and activation status to the save_dict
		for mod_id in profile.mod_list:
			var is_activated: bool = profile.mod_list[mod_id]
			save_dict.profiles[profile.name].mod_list[mod_id] = is_activated

	# Save the serialized user profiles data to the user profiles JSON file
	return ModLoaderUtils.save_dictionary_to_json_file(save_dict, FILE_PATH_USER_PROFILES)