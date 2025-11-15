extends Node
class_name ConfigSchema

const TYPE_INT_VALUE = TYPE_INT
const TYPE_FLOAT_VALUE = TYPE_FLOAT
const TYPE_STRING_VALUE = TYPE_STRING
const TYPE_ARRAY_VALUE = TYPE_ARRAY
const TYPE_DICTIONARY_VALUE = TYPE_DICTIONARY
const TYPE_BOOL_VALUE = TYPE_BOOL

const WAVE_SCHEMA = {
	"magic": TYPE_STRING_VALUE,
	"waves": TYPE_ARRAY_VALUE,
}

const AUTOPLAY_SCHEMA = {
	"magic": TYPE_STRING_VALUE,
	"script": TYPE_ARRAY_VALUE,
}

static func validate(config: Dictionary, schema: Dictionary) -> Array:
	var errors: Array = []
	for key in schema.keys():
		if not config.has(key):
			errors.append("Missing key: %s" % key)
			continue
		var expected_type = schema[key]
		var value_type = typeof(config[key])
		if expected_type == TYPE_ARRAY or expected_type == TYPE_DICTIONARY:
			if value_type != expected_type:
				errors.append("Key %s expected %s but got %s" % [key, expected_type, value_type])
		elif value_type != expected_type:
			errors.append("Key %s expected %s but got %s" % [key, expected_type, value_type])
	return errors
