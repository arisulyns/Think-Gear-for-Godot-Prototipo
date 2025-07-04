extends Node3D
var Aten = 1.0
var Med = 1.0
var materialVermelho = load("res://Asset/World/Vermelho.tres") as StandardMaterial3D
var materialVerde  = load("res://Asset/World/Verde.tres") as StandardMaterial3D


func world_main(delta, eeg_values: Dictionary):
	$LabelGraph.text = str(eeg_values.get("eeg_data"))
	if int(eeg_values.get("attention", 0)) > 60:
		Aten = 1.0
	else:
		Aten = 0.0
		
	if int(eeg_values.get("meditation", 0)) > 60:
		Med = 1.0
	else:
		Med = 0.0
		
	materialVermelho.albedo_color = lerp(materialVermelho.albedo_color, Color(0.971, 0.0, 0.169, Aten), 0.5 * delta)
	materialVerde.albedo_color = lerp(materialVerde.albedo_color, Color(0.278, 0.686, 0.29, Med), 0.5 * delta)
	
