extends Node3D
var tgam_node
var eeg_values: Dictionary
var player
var npc
var world

	
func _ready():
	tgam_node = get_node("TGAM")
	player = get_node("Player")
	npc = get_node("NPC")
	world = get_node("World")
	
	#Pegar Sinal a cada 0.5 Segundos
	$TGAM/TGAMTimer.start(0.5)
	
		

func _physics_process(delta: float) -> void:
	player.player_main(delta, eeg_values)
	npc.npc_main(delta, eeg_values, player)
	world.world_main(delta, eeg_values)
	
	
	


func _on_tgam_timer_timeout() -> void:
	eeg_values = {
	"eeg_data": tgam_node.call("GetEEGData"),
	"attention": tgam_node.call("GetAttentionValue"),
	"meditation": tgam_node.call("GetMeditationValue"),
	"noise": tgam_node.call("GetNoisePercentage")
	}
