extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@onready var camera: Camera3D = $%MainCamera3D  # Ajusta esta ruta según tu escena
@onready var animation_tree: AnimationTree = $AnimationTree

var anim_state: AnimationNodeStateMachinePlayback

#Animation node names
var idle_node_name: String = "Idle"
var walk_node_name: String = "Walk"
var run_node_name: String = "Run"
var jump_node_name: String = "Jump"
var attak_node_name: String = "Attack"
var death_node_name: String = "Death"
func _ready():
	# Configurar acciones de input si no existen
	_setup_input_actions()
	
		# Inicializar el AnimationTree y obtener el playback
	if animation_tree:
		animation_tree.active = true
		# Obtener el playback después de activar el AnimationTree
		anim_state = animation_tree.get("parameters/playback")
	else:
		print("Error: AnimationTree no encontrado")

func _setup_input_actions():
	var actions = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)

func _physics_process(delta):
	# Aplicar gravedad
	var on_floor = is_on_floor()
	if not on_floor:
		velocity.y -= gravity * delta
	
	# Manejar salto
	if Input.is_action_just_pressed("jump") and on_floor:
		velocity.y = jump_force
	
	# Obtener input de movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Convertir la dirección al espacio de la cámara
	if direction.length() > 0 and camera:
		var camera_basis = camera.global_transform.basis
		direction = camera_basis * direction
		direction.y = 0
		direction = direction.normalized()
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	if animation_tree:
		animation_tree["parameters/conditions/IsOnFloor"] = on_floor
		animation_tree["parameters/conditions/IsInAir"] = !on_floor
	
	#anim_state["parameters/conditions/IsWalking"] = is_walking
	#anim_state["parameters/conditions/IsNotWalking"] = !is_walking
	#anim_state["parameters/conditions/IsRunning"] = is_running
	#anim_state["parameters/conditions/IsNotRunning"] = !is_running
	#anim_state["parameters/conditions/IsDaying"] = is_dying
