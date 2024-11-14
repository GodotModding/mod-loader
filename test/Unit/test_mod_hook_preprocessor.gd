extends GutTest


var test_get_closing_paren_index_params = [
	["(", 0, -1],
	["func test(", 9, -1],
	["()", 0, 1],
	["func test()", 9, 10],
	["())", 0, 1],
	["func test())", 9, 10],
	["(()", 0, -1],
	["func test(()", 9, -1],
	["(())", 0, 3],
	["func test(())", 9, 12],
	["(((((()))(()))(())))", 0, 19],
	["func test(((((()))(()))(())))", 9, 28],
]


func test_get_closing_paren_index(params: Array = use_parameters(test_get_closing_paren_index_params)) -> void:
	# prepare
	var string: String = params[0]
	var opening_paren_index: int = params[1]

	var expected_result: int = params[-1]

	# test
	var result := _ModLoaderModHookPreProcessor.get_closing_paren_index(opening_paren_index, string)

	# validate
	assert_eq(
		result, expected_result,
		"Expected %s but was %s instead for string \"%s\"" % [expected_result, result, string]
	)


var test_match_func_with_whitespace_params = [
	["abc", FUNCTIONS_SAMPLE1, 0, ["func abc(", 0, 9]],
	["test", FUNCTIONS_SAMPLE1, 0, ["func test(", 19, 29]],
	["_ready", FUNCTIONS_SAMPLE2, 0, ["func _ready(", 70, 82]],
	["_on_hit_detector_body_entered", FUNCTIONS_SAMPLE2, 0, ["func _on_hit_detector_body_entered(", 155, 190]],
]

const FUNCTIONS_SAMPLE1 := """\
func abc():
	pass

func test():
	print('hello'))

func end():
	pass

"""

const FUNCTIONS_SAMPLE2 := """\
extends Portal

@export var label_level_name_override := "New Game"


func _ready() -> void:
	super()
	label_level_name.text = label_level_name_override


func _on_hit_detector_body_entered(body: Node3D) -> void:
	super(body)
	Global.reset_game()
"""

func test_match_func_with_whitespace(params: Array = use_parameters(test_match_func_with_whitespace_params)) -> void:
	# prepare
	var method_name: String = params[0]
	var text: String = params[1]
	var offset: int  = params[2]

	var expected_string: String = params.back()[0]
	var expected_start: int = params.back()[1]
	var expected_end: int = params.back()[2]

	# test
	var result := _ModLoaderModHookPreProcessor.match_func_with_whitespace(method_name, text, offset)

	gut.p("Matched: \"%s\"" % result.get_string(), 1)

	# validate
	assert_eq(
		result.get_string(), expected_string,
		"expected %s, got %s" % [expected_string, result.get_string()]
	)
	assert_eq(
		result.get_start(), expected_start,
		"expected %s, got %s" % [expected_start, result.get_start()]
	)
	assert_eq(
		result.get_end(), expected_end,
		"expected %s, got %s" % [expected_end, result.get_end()]
	)
