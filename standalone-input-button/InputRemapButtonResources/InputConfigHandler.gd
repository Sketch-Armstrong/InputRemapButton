extends Node

var input_config = ConfigFile.new()
var err = input_config.load("user://input_settings.cfg")
const INPUT_SETTINGS_FILE_PATH = "user://input_settings.cfg"


@export var action: String
@export var action_event_index: int = 0

var input_config_controller_button_index
var input_config_controller_axis_index
var input_config_controller_axis_deadzone_value := 0.5
var input_config_controller_axis_pos_or_neg := " "
var input_config_keyboard_keycode

var loading_values_test: Key

var controller_up_button = InputEventJoypadButton.new()
var controller_down_button = InputEventJoypadButton.new()
var controller_left_button = InputEventJoypadButton.new()
var controller_right_button = InputEventJoypadButton.new()
var controller_basic_action_button = InputEventJoypadButton.new()
## var controller_YOUR_ACTION_button = InputEventJoypadButton.new()

var controller_up_axis = InputEventJoypadMotion.new()
var controller_down_axis = InputEventJoypadMotion.new()
var controller_left_axis = InputEventJoypadMotion.new()
var controller_right_axis = InputEventJoypadMotion.new()
var controller_basic_action_axis = InputEventJoypadMotion.new()
## var controller_YOUR_ACTION_axis = InputEventJoypadMotion.new()

var keyboard_up = InputEventKey.new()
var keyboard_down = InputEventKey.new()
var keyboard_left = InputEventKey.new()
var keyboard_right = InputEventKey.new()
var keyboard_basic_action = InputEventKey.new()
## var keyboard_YOUR_ACTION = InputEventKey.new()

var keyboard_events := {
	"move_up": keyboard_up,
	"move_down": keyboard_down,
	"move_left": keyboard_left,
	"move_right": keyboard_right,
	"basic_action": keyboard_basic_action,
	##"your_new_action": keyboard_(NEW_ACTION)
}
var controller_button_events := {
	"move_up": controller_up_button,
	"move_down": controller_down_button,
	"move_left": controller_left_button,
	"move_right": controller_right_button,
	"basic_action": controller_basic_action_button,
	##"your_new_action": keyboard_(NEW_ACTION)
}
var controller_axis_events := {
	"move_up": controller_up_axis,
	"move_down": controller_down_axis,
	"move_left": controller_left_axis,
	"move_right": controller_right_axis,
	"basic_action": controller_basic_action_axis,
	##"your_new_action": keyboard_(NEW_ACTION)
}


var duplicate_detection_keyword: String

signal defaulted
signal duplicate_detected

var button_or_axis := " "

var controller_input_identifier: int = 1
var controller_axis_strength: float = 1.0


const default_controller_inputs_dictionary: Dictionary = {
	"move_up": {
		"button, or axis?": "button",
		"button_information": 11,
		"axis_information": [1, "-0.5"],
	},
	"move_down": {
		"button, or axis?": "button",
		"button_information": 12,
		"axis_information": [1, "+0.5"],
	},
	"move_left": {
		"button, or axis?": "button",
		"button_information": 13,
		"axis_information": [0, "-0.5"],
	},
	"move_right": {
		"button, or axis?": "button",
		"button_information": 14,
		"axis_information": [0 , "+0.5"],
	},
	"basic_action": {
		"button, or axis?": "button",
		"button_information": 0,
		"axis_information": [5, "+0.5"],
	},
}

var controller_inputs_dictionary: Dictionary 





func _ready():
	if !FileAccess.file_exists(INPUT_SETTINGS_FILE_PATH):
		create_inputs_file()
	
	if err == OK:
		sync_dictionary_to_config()
		load_inputs()



func create_inputs_file() -> void:
	input_config.set_value("keybindings", "move_up", "Up")
	input_config.set_value("keybindings", "move_down", "Down")
	input_config.set_value("keybindings", "move_left", "Left")
	input_config.set_value("keybindings", "move_right", "Right")
	input_config.set_value("keybindings", "basic_action", "Space")
	##input_config.set_value("keybindings", "YOUR_ACTION", "YOUR_INPUT")
	
	input_config.set_value("controller_bindings", "move_up", 11)
	input_config.set_value("controller_bindings", "move_down", 12)
	input_config.set_value("controller_bindings", "move_left", 13)
	input_config.set_value("controller_bindings", "move_right", 14)
	input_config.set_value("controller_bindings", "basic_action", 0)
	##input_config.set_value("keybindings", "YOUR_ACTION", "YOUR_INPUT", YOUR_button_index)
		## consult lines 17 through 35 of input_button for a basic dictionary of controller inputs
	
	input_config.set_value("DEFAULT_BINDINGS_KEYS", "move_up", "Up")
	input_config.set_value("DEFAULT_BINDINGS_KEYS", "move_down", "Down")
	input_config.set_value("DEFAULT_BINDINGS_KEYS", "move_left", "Left")
	input_config.set_value("DEFAULT_BINDINGS_KEYS", "move_right", "Right")
	input_config.set_value("DEFAULT_BINDINGS_KEYS", "basic_action", "Space")
	## input_config.set_value("DEFAULT_BINDINGS_KEYS", "YOUR_ACTION", "KEYBOARD_KEY")
	
	input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "move_up", 11)
	input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "move_down", 12)
	input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "move_left", 13)
	input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "move_right", 14)
	input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "basic_action", 0)
	##input_config.set_value("DEFAULT_BINDINGS_CONTROLLER", "YOUR_ACTION", YOUR_button_index)
	
	input_config.set_value("CONTROLLER_DICTIONARY", "BUTTON_AND_AXIS_VALUES", default_controller_inputs_dictionary)
	input_config.set_value("DEFAULT_DICTIONARY_CONTROLLER", "DEFAULT_BUTTON_AND_AXIS_VALUES", default_controller_inputs_dictionary)
	
	input_config.save(INPUT_SETTINGS_FILE_PATH)
	return

func load_inputs() -> void:
	InputMap.action_erase_events("move_up")
	
	var keyboard_up_value = input_config.get_value("keybindings", "move_up")
	keyboard_up.keycode = OS.find_keycode_from_string(keyboard_up_value)
	InputMap.action_add_event("move_up", keyboard_up)
	
	if controller_inputs_dictionary["move_up"]["button, or axis?"] == "button":
		controller_up_button.button_index = controller_inputs_dictionary["move_up"]["button_information"]
		InputMap.action_add_event("move_up", controller_up_button)
	elif controller_inputs_dictionary["move_up"]["button, or axis?"] == "axis":
		var up_axis_info = controller_inputs_dictionary["move_up"]["axis_information"]
		controller_up_axis.axis = up_axis_info[0]
		controller_up_axis.axis_value = float(up_axis_info[1])
		InputMap.action_add_event("move_up", controller_up_axis)
	
	
	InputMap.action_erase_events("move_down")
		
	var keyboard_down_value = input_config.get_value("keybindings", "move_down")
	keyboard_down.keycode = OS.find_keycode_from_string(keyboard_down_value)
	InputMap.action_add_event("move_down", keyboard_down)
	
	if controller_inputs_dictionary["move_down"]["button, or axis?"] == "button":
		controller_down_button.button_index = controller_inputs_dictionary["move_down"]["button_information"]
		InputMap.action_add_event("move_down", controller_down_button)
	
	elif controller_inputs_dictionary["move_down"]["button, or axis?"] == "axis":
		var down_axis_info = controller_inputs_dictionary["move_down"]["axis_information"]
		controller_down_axis.axis = down_axis_info[0]
		controller_down_axis.axis_value = float(down_axis_info[1])
		InputMap.action_add_event("move_down", controller_down_axis)
	
	
	
	InputMap.action_erase_events("move_left")
	
	var keyboard_left_value = input_config.get_value("keybindings", "move_left")
	keyboard_left.keycode = OS.find_keycode_from_string(keyboard_left_value)
	InputMap.action_add_event("move_left", keyboard_left)
	
	
	if controller_inputs_dictionary["move_left"]["button, or axis?"] == "button":
		controller_left_button.button_index = controller_inputs_dictionary["move_left"]["button_information"]
		InputMap.action_add_event("move_left", controller_left_button)
	
	elif controller_inputs_dictionary["move_left"]["button, or axis?"] == "axis":
		var left_axis_info = controller_inputs_dictionary["move_left"]["axis_information"]
		controller_left_axis.axis = left_axis_info[0]
		controller_left_axis.axis_value = float(left_axis_info[1])
		InputMap.action_add_event("move_left", controller_left_axis)
	
	
	InputMap.action_erase_events("move_right")
	
	var keyboard_right_value = input_config.get_value("keybindings", "move_right")
	keyboard_right.keycode = OS.find_keycode_from_string(keyboard_right_value)
	InputMap.action_add_event("move_right", keyboard_right)
	
	
	if controller_inputs_dictionary["move_right"]["button, or axis?"] == "button":
		controller_right_button.button_index = controller_inputs_dictionary["move_right"]["button_information"]
		InputMap.action_add_event("move_right", controller_right_button)
	
	elif controller_inputs_dictionary["move_right"]["button, or axis?"] == "axis":
		var right_axis_info = controller_inputs_dictionary["move_right"]["axis_information"]
		controller_right_axis.axis = right_axis_info[0]
		controller_right_axis.axis_value = float(right_axis_info[1])
		InputMap.action_add_event("move_right", controller_right_axis)
	
	
	InputMap.action_erase_events("basic_action")
	
	var keyboard_basic_action_value = input_config.get_value("keybindings", "basic_action")
	keyboard_basic_action.keycode = OS.find_keycode_from_string(keyboard_basic_action_value)
	InputMap.action_add_event("basic_action", keyboard_basic_action)
	
	if controller_inputs_dictionary["basic_action"]["button, or axis?"] == "button":
		controller_basic_action_button.button_index = controller_inputs_dictionary["basic_action"]["button_information"]
		InputMap.action_add_event("basic_action", controller_basic_action_button)
	
	elif controller_inputs_dictionary["basic_action"]["button, or axis?"] == "axis":
		var basic_action_axis_info = controller_inputs_dictionary["basic_action"]["axis_information"]
		controller_basic_action_axis.axis = basic_action_axis_info[0]
		controller_basic_action_axis.axis_value = float(basic_action_axis_info[1])
		InputMap.action_add_event("basic_action", controller_basic_action_axis)
	
		## copy paste lines 228 through 242 and replace "basic_action" with your own custom action
	
	return





func reset_to_default_inputs() -> void:
	set_dictionary_to_default()
	InputMap.action_erase_events("move_up")
	
	var keyboard_up_value = input_config.get_value("DEFAULT_BINDINGS_KEYS", "move_up")
	keyboard_up.keycode = OS.find_keycode_from_string(keyboard_up_value)
	InputMap.action_add_event("move_up", keyboard_up)
	
	controller_up_button.button_index = input_config.get_value("DEFAULT_BINDINGS_CONTROLLER", 
	"move_up", "FAILSAFE NULL VALUE")
	InputMap.action_add_event("move_up", controller_up_button)
	
	var up_axis_info = controller_inputs_dictionary["move_up"]["axis_information"]
	controller_up_axis.axis = up_axis_info[0]
	controller_up_axis.axis_value = float(up_axis_info[1])
	InputMap.action_add_event("move_up", controller_up_axis)
	
	
	
	
	InputMap.action_erase_events("move_down")
	
	var keyboard_down_value = input_config.get_value("DEFAULT_BINDINGS_KEYS", "move_down")
	keyboard_down.keycode = OS.find_keycode_from_string(keyboard_down_value)
	InputMap.action_add_event("move_down", keyboard_down)
	
	controller_down_button.button_index = input_config.get_value("DEFAULT_BINDINGS_CONTROLLER", 
	"move_down", "FAILSAFE NULL VALUE")
	InputMap.action_add_event("move_down", controller_down_button)
	
	var down_axis_info = controller_inputs_dictionary["move_down"]["axis_information"]
	controller_down_axis.axis = down_axis_info[0]
	controller_down_axis.axis_value = float(down_axis_info[1])
	InputMap.action_add_event("move_down", controller_down_axis)
	
	
	InputMap.action_erase_events("move_left")
	
	var keyboard_left_value = input_config.get_value("DEFAULT_BINDINGS_KEYS", "move_left")
	keyboard_left.keycode = OS.find_keycode_from_string(keyboard_left_value)
	InputMap.action_add_event("move_left", keyboard_left)
	
	controller_left_button.button_index = input_config.get_value("DEFAULT_BINDINGS_CONTROLLER", 
	"move_left", "FAILSAFE NULL VALUE")
	InputMap.action_add_event("move_left", controller_left_button)
	
	var left_axis_info = controller_inputs_dictionary["move_left"]["axis_information"]
	controller_left_axis.axis = left_axis_info[0]
	controller_left_axis.axis_value = float(left_axis_info[1])
	InputMap.action_add_event("move_left", controller_left_axis)
	
	InputMap.action_erase_events("move_right")
	
	var keyboard_right_value = input_config.get_value("DEFAULT_BINDINGS_KEYS", "move_right")
	keyboard_right.keycode = OS.find_keycode_from_string(keyboard_right_value)
	InputMap.action_add_event("move_right", keyboard_right)
	
	controller_right_button.button_index = input_config.get_value("DEFAULT_BINDINGS_CONTROLLER", 
	"move_right", "FAILSAFE NULL VALUE")
	InputMap.action_add_event("move_right", controller_right_button)
	
	var right_axis_info = controller_inputs_dictionary["move_right"]["axis_information"]
	controller_right_axis.axis = right_axis_info[0]
	controller_right_axis.axis_value = float(right_axis_info[1])
	InputMap.action_add_event("move_right", controller_right_axis)
	
	
	InputMap.action_erase_events("basic_action")
	
	var keyboard_basic_action_value = input_config.get_value("DEFAULT_BINDINGS_KEYS", "basic_action")
	keyboard_basic_action.keycode = OS.find_keycode_from_string(keyboard_basic_action_value)
	InputMap.action_add_event("basic_action", keyboard_basic_action)
	
	controller_basic_action_button.button_index = input_config.get_value("DEFAULT_BINDINGS_CONTROLLER", 
	"basic_action", "FAILSAFE NULL VALUE")
	InputMap.action_add_event("basic_action", controller_basic_action_button)
	
	var basic_action_axis_info = controller_inputs_dictionary["basic_action"]["axis_information"]
	controller_basic_action_axis.axis = basic_action_axis_info[0]
	controller_basic_action_axis.axis_value = float(basic_action_axis_info[1])
	InputMap.action_add_event("basic_action", controller_basic_action_axis)
	
	## copy paste lines 319 through 332 and replace "basic_action" with your own custom action
	
	create_inputs_file()
	
	
	defaulted.emit()
	return

func sync_dictionary_to_config() -> void:
	controller_inputs_dictionary = input_config.get_value("CONTROLLER_DICTIONARY", "BUTTON_AND_AXIS_VALUES").duplicate(true)
	return

func set_dictionary_to_default() -> void:
	controller_inputs_dictionary = input_config.get_value("DEFAULT_DICTIONARY_CONTROLLER", "DEFAULT_BUTTON_AND_AXIS_VALUES").duplicate(true)


func sync_config_to_dictionary() -> void:
	input_config.set_value("CONTROLLER_DICTIONARY", "BUTTON_AND_AXIS_VALUES", controller_inputs_dictionary)
	return

@warning_ignore("unused_parameter")
func check_if_duplicates_keyboard(action_name: String, event: InputEvent) -> bool:
	pass
	var check_keyboard_up = input_config.get_value("keybindings", "move_up")
	var check_keyboard_down = input_config.get_value("keybindings", "move_down")
	var check_keyboard_left = input_config.get_value("keybindings", "move_left")
	var check_keyboard_right = input_config.get_value("keybindings", "move_right")
	var check_keyboard_basic_action = input_config.get_value("keybindings", "basic_action")
	## create your own var check_keyboard_YOUR_ACTION = input_config.get_value("keybindings", "YOUR_ACTION")
	
	var all_but_up_array = [check_keyboard_down, check_keyboard_left, check_keyboard_right, check_keyboard_basic_action]
	var all_but_down_array = [check_keyboard_up, check_keyboard_left, check_keyboard_right, check_keyboard_basic_action]
	var all_but_left_array = [check_keyboard_up, check_keyboard_down, check_keyboard_right, check_keyboard_basic_action]
	var all_but_right_array = [check_keyboard_up, check_keyboard_down, check_keyboard_left, check_keyboard_basic_action]
	var all_but_basic_action_array = [check_keyboard_up, check_keyboard_down, check_keyboard_left, check_keyboard_right]
	## ====================IMPORTANT==========================
	
	## copy paste one of the arrays and rename it appropriately
	## as the name states, include each "check_keyboard_(action)" EXCEPT your own custom action
	## after doing so, MAKE SURE YOU ADD check_keyboard_YOUR_ACTION BACK into each preceding array
	
	## ====================IMPORTANT==========================
	
	if action_name == "move_up":
		if input_config_keyboard_keycode in all_but_up_array:
			return true
		else:
			return false
	
	if action_name == "move_down":
		if input_config_keyboard_keycode in all_but_down_array:
			return true
		else:
			return false
	
	if action_name == "move_left":
		if input_config_keyboard_keycode in all_but_left_array:
			return true
		else:
			return false
	
	if action_name == "move_right":
		if input_config_keyboard_keycode in all_but_right_array:
			return true
		else:
			return false
	
	if action_name == "basic_action":
		if input_config_keyboard_keycode in all_but_basic_action_array:
			return true
		else:
			return false
	
		## copy paste lines 401 through 405. replace "basic_action" with your own action's exact string name
		## replace "all_but_basic_action_array" with your own "all_but_YOUR_ACTION_array"
	
	else:
		return false

@warning_ignore("unused_parameter")
func check_if_duplicates_controller(action_name: String, event: InputEvent) -> bool:
	pass
	sync_dictionary_to_config()
	var input_config_controller_axis_direction = input_config_controller_axis_pos_or_neg + str(input_config_controller_axis_deadzone_value)
	var input_config_controller_axis_both: Array = [input_config_controller_axis_index, input_config_controller_axis_direction]
	
	
	var check_controller_up_button
	var check_controller_down_button
	var check_controller_left_button
	var check_controller_right_button
	var check_controller_basic_action_button
	##var check_controller_YOUR_ACTION_button
	
	var check_controller_up_axis
	var check_controller_up_axis_value
	
	var check_controller_down_axis
	var check_controller_down_axis_value
	
	var check_controller_left_axis
	var check_controller_left_axis_value
	
	var check_controller_right_axis
	var check_controller_right_axis_value
	
	var check_controller_basic_action_axis
	var check_controller_basic_action_axis_value
	
	check_controller_up_button = controller_inputs_dictionary["move_up"]["button_information"]
	check_controller_down_button = controller_inputs_dictionary["move_down"]["button_information"]
	check_controller_left_button = controller_inputs_dictionary["move_left"]["button_information"]
	check_controller_right_button = controller_inputs_dictionary["move_right"]["button_information"]
	check_controller_basic_action_button = controller_inputs_dictionary["basic_action"]["button_information"]
	##check_controller_YOUR_ACTION_button = controller_inputs_dictionary["YOUR_ACTION"]["button_information"]
	
	check_controller_up_axis = controller_inputs_dictionary["move_up"]["axis_information"][0]
	check_controller_up_axis_value = controller_inputs_dictionary["move_up"]["axis_information"][1]
	
	check_controller_down_axis = controller_inputs_dictionary["move_down"]["axis_information"][0]
	check_controller_down_axis_value = controller_inputs_dictionary["move_down"]["axis_information"][1]
	
	check_controller_left_axis = controller_inputs_dictionary["move_left"]["axis_information"][0]
	check_controller_left_axis_value = controller_inputs_dictionary["move_left"]["axis_information"][1]
	
	check_controller_right_axis = controller_inputs_dictionary["move_right"]["axis_information"][0]
	check_controller_right_axis_value = controller_inputs_dictionary["move_right"]["axis_information"][1]
	
	check_controller_basic_action_axis = controller_inputs_dictionary["basic_action"]["axis_information"][0]
	check_controller_basic_action_axis_value = controller_inputs_dictionary["basic_action"]["axis_information"][1]
		## need your own version of 462 and 463
	
	print("check controller basic_action axis was: ",check_controller_basic_action_axis)
	print("check controller basic_action axis value was: ",check_controller_basic_action_axis_value)
	
	var check_controller_right_axis_both: Array = [check_controller_right_axis, check_controller_right_axis_value]
	var check_controller_left_axis_both: Array = [check_controller_left_axis, check_controller_left_axis_value]
	var check_controller_down_axis_both: Array = [check_controller_down_axis, check_controller_down_axis_value]
	var check_controller_up_axis_both: Array = [check_controller_up_axis, check_controller_up_axis_value]
	var check_controller_basic_action_axis_both: Array = [check_controller_basic_action_axis, check_controller_basic_action_axis_value]
		## create your own corresponding array
	
	var all_but_up_array = [check_controller_down_button, check_controller_left_button, check_controller_right_button, check_controller_basic_action_button]
	var all_but_down_array = [check_controller_up_button, check_controller_left_button, check_controller_right_button, check_controller_basic_action_button]
	var all_but_left_array = [check_controller_up_button, check_controller_down_button, check_controller_right_button, check_controller_basic_action_button]
	var all_but_right_array = [check_controller_up_button, check_controller_down_button,check_controller_left_button, check_controller_basic_action_button]
	var all_but_basic_action_array = [check_controller_up_button, check_controller_down_button, check_controller_left_button, check_controller_right_button]
		## ====================IMPORTANT==========================
	
	## copy paste one of the arrays and rename it appropriately
	## as the name states, include each "check_controller_(action)_button" EXCEPT your own custom action
	## after doing so, MAKE SURE YOU ADD check_controller_YOUR_ACTION_button BACK into each preceding array
	
		## ====================IMPORTANT==========================
	
	var all_but_up_array_axis = [check_controller_down_axis_both, check_controller_left_axis_both, check_controller_right_axis_both, check_controller_basic_action_axis_both]
	var all_but_down_array_axis = [check_controller_up_axis_both, check_controller_left_axis_both, check_controller_right_axis_both, check_controller_basic_action_axis_both]
	var all_but_left_array_axis = [check_controller_up_axis_both, check_controller_down_axis_both, check_controller_right_axis_both, check_controller_basic_action_axis_both]
	var all_but_right_array_axis = [check_controller_up_axis_both, check_controller_down_axis_both, check_controller_left_axis_both, check_controller_basic_action_axis_both]
	var all_but_basic_action_array_axis = [check_controller_up_axis_both, check_controller_down_axis_both, check_controller_left_axis_both, check_controller_right_axis_both]
		## ====================IMPORTANT==========================
	
	## copy paste one of the arrays and rename it appropriately
	## as the name states, include each "check_controller_(action)_axis_both" EXCEPT your own custom action
	## after doing so, MAKE SURE YOU ADD check_controller_YOUR_ACTION_axis_both BACK into each preceding array
	
		## ====================IMPORTANT==========================
	
	
	if event is InputEventJoypadButton:
		if action_name == "move_up":
			if input_config_controller_button_index in all_but_up_array:
				duplicate_detection_keyword = "dupe_up"
				return true
			else:
				return false
		
		if action_name == "move_down":
			if input_config_controller_button_index in all_but_down_array:
				duplicate_detection_keyword = "dupe_down"
				return true
			else:
				return false
		
		if action_name == "move_left":
			if input_config_controller_button_index in all_but_left_array:
				duplicate_detection_keyword = "dupe_left"
				return true
			else:
				return false
		
		if action_name == "move_right":
			if input_config_controller_button_index in all_but_right_array:
				duplicate_detection_keyword = "dupe_right"
				return true
			else:
				return false
		
		if action_name == "basic_action":
			if input_config_controller_button_index in all_but_basic_action_array:
				duplicate_detection_keyword = "dupe_action"
				return true
			else:
				return false
	
			## consult line 107 of input_button.gd
	
	if event is InputEventJoypadMotion:
		if action_name == "move_up":
			if input_config_controller_axis_both in all_but_up_array_axis:
				duplicate_detection_keyword = "dupe_up"
				return true
			else:
				return false
		
		if action_name == "move_down":
			if input_config_controller_axis_both in all_but_down_array_axis:
				duplicate_detection_keyword = "dupe_down"
				return true
			else:
				return false
		
		if action_name == "move_left":
			if input_config_controller_axis_both in all_but_left_array_axis:
				duplicate_detection_keyword = "dupe_left"
				return true
			else:
				return false
		
		if action_name == "move_right":
			if input_config_controller_axis_both in all_but_right_array_axis:
				duplicate_detection_keyword = "dupe_right"
				return true
			else:
				return false
		
		if action_name == "basic_action":
			if input_config_controller_axis_both in all_but_basic_action_array_axis:
				duplicate_detection_keyword = "dupe_action"
				return true
			else:
				return false
	
			## consult line 107 of input_button.gd
	
	else:
		return false
	
	return false




@warning_ignore("unused_parameter")
@warning_ignore("unused_parameter")
func save_keyboard_input(action_name: String, event: InputEvent, action_events_list: Array) -> void:
	var duplicate_return_value = check_if_duplicates_keyboard(action_name, event)
	
	if duplicate_return_value == false:
		input_config.set_value("keybindings", action_name, input_config_keyboard_keycode)
		input_config.save(INPUT_SETTINGS_FILE_PATH)
		
		var key_event: InputEventKey = keyboard_events[action_name]
		InputMap.action_erase_event(action_name, key_event)
		key_event.keycode = OS.find_keycode_from_string(input_config_keyboard_keycode)
		InputMap.action_add_event(action_name, key_event)
	elif duplicate_return_value == true:
		duplicate_detected.emit()
	return

@warning_ignore("unused_parameter")
func save_controller_input(action_name: String, event: InputEvent, action_events_list: Array) -> void:
	var duplicate_return_value = check_if_duplicates_controller(action_name, event)
	
	
	if duplicate_return_value == false:
		if event is InputEventJoypadButton:
			save_controller_input_button(action_name, event, action_events_list)
			input_config.save(INPUT_SETTINGS_FILE_PATH)
		elif event is InputEventJoypadMotion:
			save_controller_input_axis(action_name, event, action_events_list)
			input_config.save(INPUT_SETTINGS_FILE_PATH)
	elif duplicate_return_value == true:
		duplicate_detected.emit()

	return

@warning_ignore("unused_parameter")
@warning_ignore("unused_parameter")
func save_controller_input_button(action_name: String, event: InputEvent, action_events_list: Array) -> void:
	controller_inputs_dictionary[action_name]["button, or axis?"] = "button"
	controller_inputs_dictionary[action_name]["button_information"] = input_config_controller_button_index
	input_config.set_value("CONTROLLER_DICTIONARY", "BUTTON_AND_AXIS_VALUES", controller_inputs_dictionary)
	
	var button_event: InputEventJoypadButton = controller_button_events[action_name]
	InputMap.action_erase_event(action_name, button_event)
	button_event.button_index = input_config_controller_button_index
	InputMap.action_add_event(action_name, button_event)
	return

@warning_ignore("unused_parameter")
func save_controller_input_axis(action_name: String, event: InputEvent, action_events_list: Array) -> void:
	controller_inputs_dictionary[action_name]["button, or axis?"] = "axis"
	controller_inputs_dictionary[action_name]["axis_information"] = [input_config_controller_axis_index, 
	str(input_config_controller_axis_pos_or_neg + str(input_config_controller_axis_deadzone_value))]
	input_config.set_value("CONTROLLER_DICTIONARY", "BUTTON_AND_AXIS_VALUES", controller_inputs_dictionary)
	
	var axis_event: InputEventJoypadMotion = controller_axis_events[action_name]
	InputMap.action_erase_event(action_name, axis_event)
	axis_event.axis = input_config_controller_axis_index
	axis_event.axis_value = input_config_controller_axis_deadzone_value * (1.0 if input_config_controller_axis_pos_or_neg == "+" else -1.0)
	InputMap.action_add_event(action_name, axis_event)
	return
