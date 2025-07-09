extends Node3D

var materialVermelho = load("res://Asset/World/Vermelho.tres") as StandardMaterial3D
var materialVerde  = load("res://Asset/World/Verde.tres") as StandardMaterial3D
var itens: Array = []


func _ready() -> void:
	# Busca automaticamente todos os nós filhos chamados "ItemX" e adiciona ao array
	for child in get_children():
		if child.name.begins_with("Item"):
			itens.append(child)

func world_main(delta, eeg_values: Dictionary):
	$LabelGraph.text = str(eeg_values.get("eeg_data"))
	materialVermelho.albedo_color = lerp(materialVermelho.albedo_color, Color(0.971, 0.0, 0.169, float(eeg_values.get("attention", 0))/100 ), 0.5 * delta)
	materialVerde.albedo_color = lerp(materialVerde.albedo_color, Color(0.278, 0.686, 0.29, float(eeg_values.get("meditation", 0))/100 ), 0.5 * delta)

	# Chama item_main() em cada instância
	for item in itens:
		if item.has_method("item_main"):
			item.item_main(delta, eeg_values)
