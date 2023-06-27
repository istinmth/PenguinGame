extends KinematicBody2D

export var speed = 100
var velocity = Vector2()

func _ready():
	var despawn_timer = Timer.new()
	add_child(despawn_timer)
	despawn_timer.wait_time = 7
	despawn_timer.one_shot = true
	despawn_timer.start()
	despawn_timer.connect("timeout", self, "queue_free")

	var penguin = get_node("/root/MainScene/Penguin")
	var direction = (penguin.global_position - global_position).normalized()
	velocity = direction * speed

func _physics_process(delta):
	move_and_slide(velocity)


