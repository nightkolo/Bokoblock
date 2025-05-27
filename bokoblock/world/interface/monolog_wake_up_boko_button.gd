extends Button
class_name WakeUp

signal have_awoken()
signal closer_wake(waking: float)


var times_to_wake: int = 0 
var times_clicked: int = 0


func _ready() -> void:
	grab_focus()
	
	times_to_wake = randi_range(6, 9)
	#print(times_to_wake)
	
	pressed.connect(func():
		if times_clicked == times_to_wake:
			have_awoken.emit()
		else:
			times_clicked += 1
			
			closer_wake.emit( times_clicked / times_to_wake )
		
			
		print(times_clicked)
		print(times_to_wake)
		print(float(times_clicked) / float(times_to_wake)
		)
