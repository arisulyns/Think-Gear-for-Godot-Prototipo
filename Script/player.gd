extends CharacterBody3D

# Configurações de movimento
@export_group("Movimentação")
@export var walk_speed := 5.0
@export var run_speed := 8.0


# Configuração de Camera
@export_group("Camera")
@export var mouse_sensitivity := 0.1
@export var vertical_limit := 90.0 
@export var horizontal_limit := 360.0
@export var camera_pivot : Node3D
@export var body_pivot : Node3D

# Variáveis internas
var direction = Vector3.ZERO

func _ready():
	# Esconde e trava o cursor do mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func player_main(delta, eeg_values: Dictionary):
	move_and_slide()
	player_move(delta)
	
	$Noise.text = str(eeg_values.get("noise")) + "%\n"
	$Info.text = "Atenção: " + str(eeg_values.get("attention")) + "%\n" + "Meditação: " + str(eeg_values.get("meditation")) + "%\n"
	



func player_move(delta):
	# Captura input do teclado
	direction = Vector3.ZERO
	
	# Combina movimentos simultâneos (ex: frente + direita)
	if Input.is_action_pressed("move_forward"):
		direction += body_pivot.transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction -= body_pivot.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction += body_pivot.transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction -= body_pivot.transform.basis.x
	
	
	# Normaliza para movimento diagonal não ser mais rápido
	direction = direction.normalized()
	

	# Calcula velocidade final
	velocity = direction * walk_speed * delta
	
	if direction != Vector3.ZERO:
		body_pivot.rotation_degrees.y = lerp(body_pivot.rotation_degrees.y, camera_pivot.rotation_degrees.y, 5.0 * delta)
	








func _input(event):
	# Rotação da câmera com o mouse
	if event is InputEventMouseMotion:
		# Rotação horizontal
		camera_pivot.rotation_degrees.y += -event.relative.x * mouse_sensitivity
		
		# Rotação vertical (apenas pivô da câmera)
		var current_vert_rotation = camera_pivot.rotation_degrees.z
		var new_rotation = current_vert_rotation - (event.relative.y * mouse_sensitivity)
		camera_pivot.rotation_degrees.z = clamp(new_rotation, -vertical_limit, vertical_limit)
	
		# Rotação do corpo
		if abs(camera_pivot.rotation_degrees.y - body_pivot.rotation_degrees.y) >= horizontal_limit:
			body_pivot.rotation_degrees.y += -event.relative.x * mouse_sensitivity
			
	# Tecla para liberar/capturar mouse
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			var mouse_mode = Input.get_mouse_mode()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
