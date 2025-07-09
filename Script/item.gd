extends CharacterBody3D

var areaView = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func item_main(delta, eeg_values: Dictionary):
	if areaView and eeg_values.get("attention") > 50:
		velocity.y = 1.0
		
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func _on_area_view_area_entered(_area: Area3D) -> void:
	areaView = true


func _on_area_view_area_exited(_area: Area3D) -> void:
	areaView = false
