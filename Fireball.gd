extends KinematicBody2D

export var speed = 300
var direction = Vector2()
var velocity = Vector2()

onready var fireball_sound = $FireballSound
var lifetime = 1.7

func _ready():
	fireball_sound.play()
	self.add_to_group("fireballs")
	get_tree().create_timer(lifetime).connect("timeout", self, "hit")


func _physics_process(delta):
	velocity = direction * speed
	move_and_slide(velocity)

func hit():
	queue_free()
