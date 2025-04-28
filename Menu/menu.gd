extends Node2D

var background_scenes = {
	"morning": preload("res://Menu/morning_city.tscn"),
	"day": preload("res://Menu/day_city.tscn"),
	"night": preload("res://Menu/night_city.tscn")
}

func get_time_of_day() -> String:
	var time = Time.get_time_dict_from_system()
	var hour = time["hour"]
	
	if hour >= 5 and hour <= 12:
		return "morning"
	elif hour > 12 and hour <= 18:
		return "day"
	else:
		return "night" 

func set_background_based_on_time():
	var time_of_day = get_time_of_day()
	var new_background = background_scenes[time_of_day].instantiate()
	
	if get_child_count() > 0:
		for child in get_children():
			if child is ParallaxBackground:
				child.queue_free()
	
	add_child(new_background)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_background_based_on_time()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_выйти_pressed() -> void:
	get_tree().quit()
	


func _on_играть_pressed() -> void:
	get_tree().change_scene_to_file("res://scena1/Location1.tscn")
