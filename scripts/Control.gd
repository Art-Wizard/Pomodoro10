extends Control

var time_left = 25 * 60 # 25 minutes in seconds
var chime_durations = [] # Times for chime periods
var chime_duration = 10 # Duration of chime period, in seconds
var chime_timer = Timer.new() # Timer for chime duration countdown
var is_chime_period = false # Flag to indicate if we are in a chime period

func _ready():
	$Timer.stop()
	update_timer_display()
	add_child(chime_timer)
	chime_timer.wait_time = chime_duration
	chime_timer.one_shot = true
	chime_timer.connect("timeout", Callable(self, "_on_chime_timer_timeout"))
	calculate_chime_times()


func update_timer_display():
	var minutes = time_left / 60
	var seconds = time_left % 60
	$Label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_timeout():
	if time_left > 0:
		time_left -= 1
		update_timer_display()
		
		if !is_chime_period and chime_durations.has(time_left):
			start_chime_period()
	else:
		$Timer.stop()
		play_full_end_chime()

func _on_start_button_pressed():
	$Timer.start()
	update_timer_display()
	$Start.play()
	
func _on_stop_button_pressed():
	$Timer.stop()
	chime_timer.stop()
	is_chime_period = false
	
func _on_reset_button_pressed():
	time_left = 25 * 60 # Reset to 25 minutes
	update_timer_display()
	$Timer.stop()
	chime_timer.stop()
	is_chime_period = false
	calculate_chime_times()

func start_chime_period():
	is_chime_period = true
	play_start_chime()
	chime_timer.start()

func _on_chime_timer_timeout():
	play_end_chime()
	is_chime_period = false

func calculate_chime_times():
	chime_durations.clear()
	var num_chimes = randi() % 2 + 2 # Randomly 2 or 3 chimes
	for i in range(num_chimes):
		var chime_time = randi() % (20 * 60) + 5 * 60 # Ensure chimes occur between 5 minutes and 20 minutes
		chime_durations.append(time_left - chime_time)

func play_start_chime():
	$Meditate.play()

func play_end_chime():
	$Learn.play()

func play_full_end_chime():
	$Stop.play()
