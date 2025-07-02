extends Node3D
var Aten = 1.0
var Med = 1.0


func world_main(delta, eeg_values: Dictionary):
	$LabelGraph.text = str(eeg_values.get("eeg_data"))
	$Mesh1.transparency = Aten
	$Mesh2.transparency = Med
	
	if eeg_values.get("noise") != null and eeg_values.get("noise") >= 90.0:
		$Mesh1/Label1.text = str(eeg_values.get("attention"))
		$Mesh2/Label2.text = str(eeg_values.get("meditation"))
		if int(eeg_values.get("attention")) >= 50:
			Aten = 0.0
		else:
			Aten = 1.0
			
		if int(eeg_values.get("meditation")) >= 50:
			Med = 0.0
		else:
			Med = 1.0
