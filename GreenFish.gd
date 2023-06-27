extends KinematicBody2D

signal disappeared

func _ready():
	get_node("Area2D").connect("body_entered", self, "_on_GreenFish_body_entered")
	self.add_to_group("green_fish")

func _on_GreenFish_body_entered(body):
	if body.name == "Penguin":
		get_node("/root/MainScene").add_score(2)
		emit_signal("disappeared")
		queue_free()
		get_node("/root/MainScene").green_fish_spawned = false
