extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_force: float = 4.5
@export var gravity: float = 9.8
@export var run_speed: float = 8.0
@export var attack_cooldown_time: float = 0.5

@onready var camera: Camera3D = $%MainCamera3D
@onready var animation_tree: AnimationTree = $AnimationTree

var anim_state: AnimationNodeStateMachinePlayback

# Variables de estado
var is_walking: bool = false
var is_running: bool = false
var is_attacking: bool = false
var is_dying: bool = false
var attack_cooldown: float = 0.0
var current_speed: float = 0.0

func _ready():
	_setup_input_actions()
	
	if animation_tree:
		animation_tree.active = true
		anim_state = animation_tree.get("parameters/playback")
	else:
		print("Error: AnimationTree no encontrado")

func _setup_input_actions():
	var actions = {
		"move_forward": KEY_W,
		"move_backward": KEY_S,
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"run": KEY_SHIFT,
		"attack": KEY_Q
	}
	
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event = InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)

func _physics_process(delta):
	# Manejar el cooldown del ataque
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	# Aplicar gravedad
	var on_floor = is_on_floor()
	if not on_floor:
		velocity.y -= gravity * delta
	
	# Manejar salto
	if Input.is_action_just_pressed("jump") and on_floor and not is_attacking:
		velocity.y = jump_force
	
	# Determinar si estamos atacando
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0 and on_floor and not is_dying:
		is_attacking = true
		attack_cooldown = attack_cooldown_time
		# Forzar la animación de ataque
		if anim_state:
			anim_state.travel("Attack")
	
	# Obtener input de movimiento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Convertir la dirección al espacio de la cámara
	if direction.length() > 0 and camera and not is_attacking and not is_dying:
		var camera_basis = camera.global_transform.basis
		direction = camera_basis * direction
		direction.y = 0
		direction = direction.normalized()
		
		# Usar la velocidad de correr si corresponde
		#if is_running:
			#anim_state.travel("Run")
			# Determinar si estamos corriendo (solo si estamos en el suelo y no atacando)
		if Input.is_action_pressed("run") and on_floor and not is_attacking:
			is_running = true
			velocity.x = direction.x * run_speed
			velocity.z = direction.z * run_speed
		else:
			is_running = false
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

		
		# Actualizar estado de caminata
		is_walking = true
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		is_walking = false
		
	
	
	move_and_slide()
	

	# Actualizar animaciones - USAR SET() EN LUGAR DE ASIGNACIÓN DIRECTA
	if animation_tree:
		animation_tree.set("parameters/conditions/IsOnFloor", on_floor)
		animation_tree.set("parameters/conditions/IsInAir", !on_floor)
		animation_tree.set("parameters/conditions/IsWalking", is_walking and not is_running and not is_attacking)
		animation_tree.set("parameters/conditions/IsNotWalking", not is_walking )
		animation_tree.set("parameters/conditions/IsRunning",  is_walking and is_running and not is_attacking)
		animation_tree.set("parameters/conditions/IsNotRunning", not is_running)
		animation_tree.set("parameters/conditions/IsDying", is_dying)
	
	# Reiniciar el estado de ataque después de un tiempo
	if is_attacking and attack_cooldown <= attack_cooldown_time * 0.8:
		is_attacking = false

# Función para manejar la muerte del personaje
func die():
	is_dying = true
	if anim_state:
		anim_state.travel("Death")
	set_physics_process(false)

# Función para revivir el personaje
func revive():
	is_dying = false
	set_physics_process(true)

# Señal para detectar cuando una animación termina (conectar en el editor)
func _on_animation_finished(anim_name):
	if anim_name == "Attack":
		is_attacking = false


func _on_demage_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Monsters") and is_attacking:
		body.hit(2)
