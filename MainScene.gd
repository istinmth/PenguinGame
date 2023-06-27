extends Node2D

var Fish = preload("res://Fish.tscn")
var Whale = preload("res://Whale.tscn")
var GreenFish = preload("res://GreenFish.tscn")
var fish_spawn_points = []
var fish_eaten = 0
var whale_spawn_point
var whale_instance = null
var last_notification_finished = false
var game_started = false
var whale_spawn_timer
var fish_spawn_timer
var whale_spawn_time = 10.0 
var green_fish_spawn_points = []
var green_fish_spawned = false

func _ready():
	$GreenFishSpawnTimer.set_wait_time(1)
	$NotificationMusic.play()
	green_fish_spawn_points = [
		$GreenFishContainer/GreenFishSpawnPoint1.global_position,
		$GreenFishContainer/GreenFishSpawnPoint2.global_position,
		$GreenFishContainer/GreenFishSpawnPoint3.global_position,
		$GreenFishContainer/GreenFishSpawnPoint4.global_position,
		$GreenFishContainer/GreenFishSpawnPoint5.global_position,
		$GreenFishContainer/GreenFishSpawnPoint6.global_position,
		$GreenFishContainer/GreenFishSpawnPoint7.global_position,
		$GreenFishContainer/GreenFishSpawnPoint8.global_position
	]
	fish_spawn_points = [$FishContainer/FishSpawnPoint1.global_position,
	$FishContainer/FishSpawnPoint2.global_position,
	$FishContainer/FishSpawnPoint3.global_position,
	$FishContainer/FishSpawnPoint4.global_position,
	$FishContainer/FishSpawnPoint5.global_position,
	$FishContainer/FishSpawnPoint6.global_position,
	$FishContainer/FishSpawnPoint7.global_position,
	$FishContainer/FishSpawnPoint8.global_position,
	$FishContainer/FishSpawnPoint9.global_position,
	$FishContainer/FishSpawnPoint10.global_position,
	$FishContainer/FishSpawnPoint11.global_position,
	$FishContainer/FishSpawnPoint12.global_position,
	$FishContainer/FishSpawnPoint13.global_position,
	$FishContainer/FishSpawnPoint14.global_position,]
	whale_spawn_point = $WhaleSpawnPoint.global_position

	whale_spawn_timer = Timer.new()
	whale_spawn_timer.set_wait_time(whale_spawn_time)
	whale_spawn_timer.set_one_shot(true)
	whale_spawn_timer.connect("timeout", self, "_on_whale_spawn_timer_timeout")
	add_child(whale_spawn_timer)

	fish_spawn_timer = Timer.new()
	fish_spawn_timer.set_wait_time(7.0)
	fish_spawn_timer.connect("timeout", self, "_on_fish_spawn_timer_timeout")
	add_child(fish_spawn_timer)

	$WhaleProgressBar.max_value = whale_spawn_time  
	$WhaleProgressBar.value = 0

func _process(delta):
	if last_notification_finished and $NotificationMusic.playing and !$MainMusic.playing:
		switch_music()
	if !game_started and $Penguin.velocity != Vector2.ZERO:
		start_game()

func start_game():
	game_started = true
	whale_spawn_timer.start()
	fish_spawn_timer.start()
	$Tween.interpolate_property($CanvasModulate, "color", Color(0, 0, 0, 1), Color(1, 1, 1, 1), 7, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($Penguin/Light2D, "energy", 1, 0, 3.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$GreenFishSpawnTimer.start()
	$Tween.start()

func switch_music():
	$MusicTween.interpolate_property($NotificationMusic, "volume_db", 0, -80, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MusicTween.interpolate_callback(self, 3.0, "start_main_music")
	$MusicTween.start()

func start_main_music():
	$MainMusic.play()
	$MusicTween.interpolate_property($MainMusic, "volume_db", -80, 0, 3.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$MusicTween.start()

func _on_last_notification_finished():
	last_notification_finished = true

func spawn_whale():
	if game_started and whale_instance == null:
		whale_instance = Whale.instance()
		whale_instance.position = whale_spawn_point
		whale_instance.connect("whale_disappeared", self, "_on_whale_disappeared")
		if game_started:
			add_child(whale_instance)
		else:
			whale_instance.hide()

func _on_whale_disappeared():
	whale_spawn_time = 7.0
	whale_spawn_timer.start(whale_spawn_time)
	$WhaleProgressBar.max_value = whale_spawn_time
	$WhaleProgressBar.value = 0
	if fish_eaten >= 111:
		end_game()

func _on_fish_spawn_timer_timeout():
	if game_started:
		var fish_to_spawn = max(3, fish_eaten / 9) 
		for i in range(fish_to_spawn):
			if fish_eaten >= 9:
				var fish = Fish.instance()
				fish.spawn(fish_spawn_points[randi() % fish_spawn_points.size()])
				$FishContainer.add_child(fish)

func _on_whale_spawn_timer_timeout():
	spawn_whale()
	whale_spawn_timer.set_wait_time(whale_spawn_time)
	$WhaleProgressBar.max_value = whale_spawn_time
	$WhaleProgressBar.value = 0
	$Tween.start()

func get_fish_eaten():
	return fish_eaten
	
func add_score(score_increase):
	fish_eaten += score_increase
	$FishEatenCounter.text = "+" + str(score_increase)
	yield(get_tree().create_timer(0.6), "timeout")
	$FishEatenCounter.text = str(fish_eaten)
	if not green_fish_spawned:
		spawn_green_fish()
	if fish_eaten >= 111:
		end_game()


func _on_ScoreIncrementTimer_timeout():
	print("Score increment timer timed out.") # debug print
	$ScoreIncrementLabel.hide()
	$FishEatenCounter.text = str(fish_eaten)
	$FishEatenCounter.show()


func start_green_fish_timer():
	print("Green fish timer started.")
	
func add_fish(fish_count):
	fish_eaten += fish_count
	$FishEatenCounter.text = "+" + str(fish_count)
	yield(get_tree().create_timer(0.6), "timeout")
	$FishEatenCounter.text = str(fish_eaten)
	if not green_fish_spawned:
		spawn_green_fish()

func _on_GreenFishSpawnTimer_timeout():
	spawn_green_fish()
	$GreenFishSpawnTimer.start()

var last_spawn_point = Vector2()

func spawn_green_fish():
	if not green_fish_spawned:
		var green_fish_instance = GreenFish.instance()
		var spawn_point = calculate_random_spawn_point()
		while spawn_point == last_spawn_point:
			spawn_point = calculate_random_spawn_point()
		last_spawn_point = spawn_point
		green_fish_instance.global_position = spawn_point
		$GreenFishContainer.add_child(green_fish_instance)
		green_fish_spawned = true
		print("Spawned green fish")
	if game_started:
		$GreenFishSpawnTimer.start()

func calculate_random_spawn_point():
	return green_fish_spawn_points[randi() % green_fish_spawn_points.size()]

		
func _on_green_fish_disappeared():
	green_fish_spawned = false
	
func calculate_furthest_spawn_point(position):
	var max_distance = 0
	var furthest_spawn_point = Vector2.ZERO
	for spawn_point in green_fish_spawn_points:
		var distance = position.distance_to(spawn_point)
		if distance > max_distance:
			max_distance = distance
			furthest_spawn_point = spawn_point
	return furthest_spawn_point

func subtract_fish(fish_count):
	fish_eaten = max(fish_eaten - fish_count, 0)
	var score_deduction = fish_count
	$FishEatenCounter.text = "-" + str(score_deduction)
	yield(get_tree().create_timer(0.6), "timeout")
	$FishEatenCounter.text = str(fish_eaten)


func _physics_process(delta):
	$WhaleProgressBar.value = whale_spawn_time - whale_spawn_timer.time_left

func _on_RestartButton_pressed():
	if not is_a_parent_of($WhaleContainer):
		add_child($WhaleContainer)
	get_tree().reload_current_scene()

func vibe_penguin():
	while game_started == false:
		var bpm = 120.0
		var bps = bpm / 60.0
		var beat_duration = 1 / bps
		$VibeTween.interpolate_property($Penguin, "scale", Vector2(10, 10), Vector2(12, 12), beat_duration / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$VibeTween.start()
		yield(get_tree().create_timer(beat_duration), "timeout")
		$VibeTween.interpolate_property($Penguin, "scale", Vector2(12, 12), Vector2(10, 10), beat_duration / 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$VibeTween.start()
		yield(get_tree().create_timer(beat_duration), "timeout")

func end_game():
	game_started = false
	if whale_instance != null:
		whale_instance.disconnect("body_entered", whale_instance, "_on_body_entered")
		whale_instance.connect("whale_disappeared", self, "_on_whale_disappeared")
	whale_spawn_timer.stop()
	fish_spawn_timer.stop()
	$GreenFishSpawnTimer.stop()
	for whale in $WhaleContainer.get_children():
		whale.queue_free()
		
	for green_fish in $GreenFishContainer.get_children():
		green_fish.queue_free()
		
	if whale_instance != null:
		var whale_collision = whale_instance.get_node("CollisionShape2D")
		if whale_collision != null:
			whale_instance.remove_child(whale_collision)

	for fish in $FishContainer.get_children():
		fish.queue_free()

	move_child($Penguin, get_child_count() - 1)
	if is_a_parent_of($WhaleContainer):
		remove_child($WhaleContainer)
	$WhaleProgressBar.hide()
	$EndgameSprite.show()
	$EndsceneNotification.show_notification("[center]You ate so much fish that you became a mutant fat-ass penguin...[/center]")
	vibe_penguin()
	move_child($RestartButton, get_child_count() - 1)
	$RestartButton.show()
