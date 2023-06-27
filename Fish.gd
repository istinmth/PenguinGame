extends KinematicBody2D

export var speed = 140
var velocity = Vector2()

onready var penguin = get_node("/root/MainScene/Penguin")

func _ready():
	get_node("Area2D").connect("body_entered", self, "_on_Fish_body_entered")
	self.add_to_group("fish")

func _physics_process(delta):
	var penguin = get_node("/root/MainScene/Penguin")
	if penguin != null:
		var dir = (penguin.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide(velocity)

func _on_Fish_body_entered(body):
	if body.name == "Penguin":
		get_node("/root/MainScene").subtract_fish(3)
		body.get_node("AnimationSprite").modulate = Color.red
		get_tree().create_timer(0.5).connect("timeout", body, "reset_color")
		queue_free()
	elif body.name == "Fireball":
		body.queue_free()
		queue_free()

func spawn(position):
	global_position = position
