extends Node3D

var materialNPC  = load("res://Asset/Allay/Allay.tres") as StandardMaterial3D
var areaView
var direction
var target_angle
var meditacao

func npc_main(delta, eeg_values: Dictionary, player):
	meditacao = str(eeg_values.get("meditation"))
	meditacao = float(meditacao)
	
	if areaView:
		materialNPC.albedo_color = lerp(materialNPC.albedo_color, Color(1.0, 1.0, 1.0, meditacao/200 ), 0.5 * delta)
	else:
		materialNPC.albedo_color = lerp(materialNPC.albedo_color, Color(1.0, 1.0, 1.0, 0.0), 2.0 * delta)
	
	
	
	direction = player.global_position - global_position
	direction.y = 0  # Ignora o eixo vertical

	if direction.length() > 0.1:
		direction = direction.normalized()
		
		# Calcula o ângulo alvo apenas no eixo Y
		target_angle = atan2(direction.x, direction.z)
		
		# Aplica apenas ao eixo Y usando lerp normal (não lerp_angle)
		$npc_model.rotation.y = lerp_angle($npc_model.rotation.y, target_angle, 2 * delta)


func _on_area_view_body_entered(_body: Node3D) -> void:
	areaView = true


func _on_area_view_body_exited(_body: Node3D) -> void:
	areaView = false
