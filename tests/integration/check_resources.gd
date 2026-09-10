extends SceneTree

# Run after autoload initialization; a bare MainLoop cannot resolve App.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var paths: Array[String] = []
	scan("res://app", paths)
	scan("res://scenes", paths)
	var failed := 0
	for path in paths:
		var resource := load(path)
		if resource == null:
			failed += 1
		elif resource is GDScript and not resource.can_instantiate():
			failed += 1
	print("RESOURCES: %d files, %d failures (with project autoloads)" % [paths.size(), failed])
	quit(1 if failed else 0)

func scan(path: String, paths: Array[String]) -> void:
	var directory := DirAccess.open(path)
	for filename in directory.get_files():
		if filename.ends_with(".gd") or filename.ends_with(".tscn"):
			paths.append(path.path_join(filename))
	for folder in directory.get_directories():
		scan(path.path_join(folder), paths)
