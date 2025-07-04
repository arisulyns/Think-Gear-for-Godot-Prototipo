extends Node3D
var Aten = 1.0
var Med = 1.0


func world_main(delta, eeg_values: Dictionary):
	$LabelGraph.text = str(eeg_values.get("eeg_data"))
	
	if int(eeg_values.get("GetAttentionValue", 0)) > 60:
		$Vermelho.visible = true
	else:
		$Vermelho.visible = false
		
	if int(eeg_values.get("GetMeditationValue", 0)) > 60:
		$Verde.visible = true
	else:
		$Verde.visible = false
