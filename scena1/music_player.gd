extends Node

var music_tracks = [
	preload("res://assets/music/level1/Corrupted Circuitry.wav"),
	preload("res://assets/music/level1/Electric Eel Fishing.wav")
]
var current_track = 0


func _ready():
	music_player.stream = music_tracks[current_track]
	music_player.play()
	music_player.finished.connect(_on_music_finished) # <-- ключевая строка

func _on_music_finished():
	current_track = (current_track + 1) % music_tracks.size()
	music_player.stream = music_tracks[current_track]
	music_player.play()
