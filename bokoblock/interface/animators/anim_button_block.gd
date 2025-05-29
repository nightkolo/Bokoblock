extends Button


func _ready() -> void:
	pressed.connect(anim_pressed)
	mouse_entered.connect(anim_entered)
	focus_entered.connect(anim_entered)
	
	
func anim_pressed():
	Audio.ui_button_click.play()
	

func anim_entered():
	Audio.ui_button_hover.play()
