extends RichTextLabel

onready var tween = $Tween

func _ready():
	self.connect("visibility_changed", self, "_on_visibility_changed")

func _on_visibility_changed():
	if self.visible:
		show_notification(self.bbcode_text)
	else:
		hide_notification()

func show_notification(text):
	self.bbcode_text = "[center]" + text + "[/center]"
	self.modulate = Color(1, 1, 1, 0)
	tween.interpolate_property(self, "modulate",
							   Color(1, 1, 1, 0), Color(1, 1, 1, 1), 
							   1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func hide_notification():
	tween.interpolate_property(self, "modulate",
							   Color(1, 1, 1, 1), Color(1, 1, 1, 0), 
							   1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
