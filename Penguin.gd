extends KinematicBody2D

var speed = 4
var velocity = Vector2()
var Fireball = preload("res://Fireball.tscn")

var fireball_limit = 11
var fireball_count = fireball_limit
var refill_time = 10.0
var last_refill

func _ready():
	last_refill = OS.get_ticks_msec() / 1000
	self.add_to_group("penguin")

func _physics_process(delta):
	var direction = Vector2()
	if Input.is_action_pressed('ui_right'):
		direction.x += 1
		$AnimationSprite.play("walk_right")
	elif Input.is_action_pressed('ui_left'):
		direction.x -= 1
		$AnimationSprite.play("walk_left")
	elif Input.is_action_pressed('ui_down'):
		direction.y += 1
		$AnimationSprite.play("walk_down")
	elif Input.is_action_pressed('ui_up'):
		direction.y -= 1
		$AnimationSprite.play("walk_up")
	else:
		if $AnimationSprite.animation == "walk_up":
			$AnimationSprite.play("Idle_Up")
		elif $AnimationSprite.animation == "walk_down":
			$AnimationSprite.play("Idle_Down")
		elif $AnimationSprite.animation == "walk_left":
			$AnimationSprite.play("Idle_Left")
		elif $AnimationSprite.animation == "walk_right":
			$AnimationSprite.play("Idle_Right")

	if direction.length() > 0:
		if !$WalkingSound.playing:
			$WalkingSound.play()
	else:
		$WalkingSound.stop()

	direction = direction.normalized()
	velocity = direction * speed
	var collision_info = move_and_collide(velocity)

	if fireball_count <= 0 and OS.get_ticks_msec() / 1000 - last_refill >= refill_time:
		fireball_count = fireball_limit
		last_refill = OS.get_ticks_msec() / 1000
	
	if Input.is_action_just_pressed('shoot'):
		if fireball_count > 0:
			var closest_target = get_closest_target()
			if closest_target != null:
				var fireball = Fireball.instance()
				fireball.direction = (closest_target.global_position - global_position).normalized()
				fireball.global_position = global_position
				get_parent().add_child(fireball)
				fireball_count -= 1
		else:
			get_node("/root/MainScene/Notification").show_notification("Out of fireballs")
			yield(get_tree().create_timer(1.0), "timeout")
			get_node("/root/MainScene/Notification").hide_notification()
			
func get_closest_target():
	var closest_target = null
	var closest_distance = 1e6
	for fish in get_tree().get_nodes_in_group("fish"):
		var distance = global_position.distance_to(fish.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_target = fish
	return closest_target

func reset_color():
	get_node("AnimationSprite").modulate = Color.white
