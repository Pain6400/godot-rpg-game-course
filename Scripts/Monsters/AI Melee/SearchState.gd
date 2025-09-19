# Search state (search.gd)
extends Node

var AIController
var search_time: float = 5.0
var current_search_time: float = 0.0
var search_radius: float = 3.0
var target_position: Vector3
var reached_target: bool = false

func _ready() -> void:
	AIController = get_parent().get_parent()
	
	# Guardar la última posición conocida del jugador
	if AIController.player_1:
		target_position = AIController.player_1.global_transform.origin
	else:
		target_position = AIController.global_transform.origin
	
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Search")
	current_search_time = 0.0
	reached_target = false

func _physics_process(delta: float) -> void:
	if not AIController:
		return
		
	current_search_time += delta
	
	# Volver a Idle si se acaba el tiempo de búsqueda
	if current_search_time >= search_time:
		AIController.state_machine.change_state("Idle")
		return
	
	# Calcular dirección hacia el objetivo
	var direction_to_target = (target_position - AIController.global_transform.origin).normalized()
	direction_to_target.y = 0
	
	# Mover hacia el objetivo
	AIController.velocity.x = direction_to_target.x * AIController.speed * 0.7
	AIController.velocity.z = direction_to_target.z * AIController.speed * 0.7
	
	# Rotar hacia la dirección del movimiento
	if direction_to_target.length() > 0.1:
		AIController.look_at(AIController.global_transform.origin + direction_to_target, Vector3.UP)
	
	# Verificar si llegó al objetivo
	var distance_to_target = AIController.global_transform.origin.distance_to(target_position)
	if distance_to_target < 0.5 and not reached_target:
		reached_target = true
		start_search_pattern()

func start_search_pattern():
	# Generar puntos de búsqueda aleatorios alrededor de la última posición
	for i in range(3):
		if not AIController or AIController.state_machine.current_state != self:
			break
			
		var random_angle = randf() * 2 * PI
		var random_distance = randf() * search_radius
		var new_target = target_position + Vector3(
			cos(random_angle) * random_distance,
			0,
			sin(random_angle) * random_distance
		)
		
		target_position = new_target
		reached_target = false
		
		# Esperar en cada punto de búsqueda
		await get_tree().create_timer(1.0).timeout
	
	# Después de completar el patrón de búsqueda, volver a Idle
	if AIController:
		AIController.state_machine.change_state("Idle")
