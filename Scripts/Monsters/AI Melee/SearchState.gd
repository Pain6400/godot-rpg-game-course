extends Node

var AIController
var search_time: float = 5.0
var current_search_time: float = 0.0
var search_radius: float = 5.0
var target_position: Vector3
var reached_target: bool = false
var is_active: bool = true

func _ready() -> void:
	AIController = get_parent().get_parent()
	# Reiniciar el temporizador cada vez que se entra en este estado
	current_search_time = 0.0
	is_active = true
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Search")
	generate_new_target()

func generate_new_target():
	if not is_active:
		return
		
	var random_angle = randf() * 2 * PI
	var random_distance = randf() * search_radius
	var offset = Vector3(cos(random_angle) * random_distance, 0, sin(random_angle) * random_distance)
	target_position = AIController.global_transform.origin + offset
	reached_target = false

func _physics_process(delta: float) -> void:
	if not is_active or not AIController:
		return
		
	# Verificar si el jugador está en el área de detección durante la búsqueda
	var chase_area = AIController.get_node("chase_player_detection")
	var overlapping_bodies = chase_area.get_overlapping_bodies()
	var player_detected = false
	
	for body in overlapping_bodies:
		if body.is_in_group("Players"):
			player_detected = true
			break
	
	# Si se detecta al jugador durante la búsqueda, cambiar inmediatamente a Run
	if player_detected:
		cleanup()
		AIController.state_machine.change_state("Run")
		return
		
	current_search_time += delta
	
	# Si ha pasado el tiempo de búsqueda, volver a Idle
	if current_search_time >= search_time:
		cleanup()
		AIController.state_machine.change_state("Idle")
		return
	
	# Calcular dirección hacia el objetivo actual
	var direction_to_target = (target_position - AIController.global_transform.origin).normalized()
	direction_to_target.y = 0
	
	# Mover hacia el objetivo
	AIController.velocity.x = direction_to_target.x * AIController.speed * 0.5
	AIController.velocity.z = direction_to_target.z * AIController.speed * 0.5
	
	# Mirar hacia la dirección del movimiento
	if direction_to_target.length() > 0.1:
		AIController.look_at(AIController.global_transform.origin + direction_to_target, Vector3.UP)
	
	# Verificar si ha llegado al objetivo
	var distance_to_target = AIController.global_transform.origin.distance_to(target_position)
	if distance_to_target < 0.5 and !reached_target:
		reached_target = true
		# Esperar un poco antes de generar un nuevo objetivo
		await get_tree().create_timer(1.0).timeout
		if is_active:  # Verificar que aún esté activo después de la espera
			generate_new_target()

# Método para limpiar el estado
func cleanup():
	is_active = false
	if AIController:
		AIController.velocity.x = 0
		AIController.velocity.z = 0
		AIController.get_node("AnimationTree").get("parameters/playback").travel("Idle")

func _exit_tree():
	cleanup()
