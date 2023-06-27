extends TextureButton

var is_sound_on = true

func _ready():
	connect("toggled", self, "_on_button_toggled")

func _on_button_toggled(button_pressed):
	is_sound_on = not is_sound_on

	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not is_sound_on)

	if is_sound_on:
		texture_normal = load("res://sound.png")
		texture_pressed = load("res://mute.png")
	else:
		texture_normal = load("res://sound.png")
		texture_pressed = load("res://mute.png")
