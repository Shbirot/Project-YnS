extends Node

var version_string = "DEV-UNKNOWN"

const VERSION_PATHS = [
	"res://.VERSION",
	"res://../.VERSION",
]

func _ready() -> void:
	version_string = _read_version()

func _read_version() -> String:
	for path in VERSION_PATHS:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			if file:
				return file.get_as_text().strip_edges()
	return "DEV-UNKNOWN"
