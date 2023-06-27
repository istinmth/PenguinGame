extends Area2D

signal whale_disappeared

var befriended = false
var is_gathering = false
var gather_timer
var water_spawn_point = Vector2(618, 496)

func _ready():
	connect("body_entered", self, "_on_body_entered")

	gather_timer = Timer.new()
	gather_timer.set_wait_time(7)
	gather_timer.set_one_shot(true)
	gather_timer.connect("timeout", self, "_on_gather_timer_timeout")
	add_child(gather_timer)

func _on_body_entered(body):
	if body.name == "Penguin":
		var main_scene = get_node("/root/MainScene")
		if not befriended and main_scene.game_started:
			befriended = true
			get_node("/root/MainScene/BefriendNotification").show_notification("[center]You befriended Splashy the whale![/center]")
			yield(get_tree().create_timer(5.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/BefriendNotification").hide_notification()
			get_node("/root/MainScene/Notification").show_notification("[center]Splashy will return to the edge of the ice where you can meet him...[/center]")
			global_position = water_spawn_point
			yield(get_tree().create_timer(4.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").hide_notification()
			get_node("/root/MainScene/Notification").show_notification("[center]And gather some fish for you! [/center]")
			yield(get_tree().create_timer(4.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").hide_notification()
			get_node("/root/MainScene/Notification").show_notification("[center]However, beware the crimson fish, from whom you need to keep a safe SPACE[/center]")
			yield(get_tree().create_timer(3.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").hide_notification()
			get_node("/root/MainScene")._on_last_notification_finished()
			get_node("/root/MainScene/Notification").hide_notification()
			yield(get_tree().create_timer(3.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").show_notification("[center]Whoa! You didn't think this way such an eerie game, did you?[/center]")
			yield(get_tree().create_timer(3.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").hide_notification()
			get_node("/root/MainScene/Notification").show_notification("[center]Let's roll![/center]")
			yield(get_tree().create_timer(3.0), "timeout")
			if not is_instance_valid(self):
				return
			get_node("/root/MainScene/Notification").hide_notification()
		elif befriended and not is_gathering:
			is_gathering = true
			hide()
			global_position = water_spawn_point
			gather_timer.start()
			emit_signal("whale_disappeared")

func _on_gather_timer_timeout():
	show()
	is_gathering = false
	global_position = water_spawn_point
	var score_increase = 7
	get_node("/root/MainScene").call("add_score", score_increase)

