extends Node3D

var materialNPC  = load("res://Asset/Allay/Allay.tres") as StandardMaterial3D
var direction
var target_angle
var meditacao
var diferenca_npc_to_player = 0.0

func npc_main(delta, eeg_values: Dictionary, player):
	meditacao = str(eeg_values.get("meditation"))
	meditacao = float(meditacao)
	
	materialNPC.albedo_color = lerp(materialNPC.albedo_color, Color(1.0, 1.0, 1.0, clamp(meditacao/100 - abs(diferenca_npc_to_player/10), 0.0, 1.0) ), 0.5 * delta)

	
	
	
	direction = player.global_position - global_position
	direction.y = 0  # Ignora o eixo vertical
	diferenca_npc_to_player = direction.x + direction.z
	
	if direction.length() > 0.1:
		direction = direction.normalized()
		
		
		# Calcula o ângulo alvo apenas no eixo Y
		target_angle = atan2(direction.x, direction.z)
		
		# Aplica apenas ao eixo Y usando lerp normal (não lerp_angle)
		$npc_model.rotation.y = lerp_angle($npc_model.rotation.y, target_angle, 2 * delta)
