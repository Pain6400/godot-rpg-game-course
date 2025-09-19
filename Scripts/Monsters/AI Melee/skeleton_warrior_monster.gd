extends CharacterBody3D


var speed: float = 1.0
@onready var state_machine: Node = $StateMachine
@export var player_1: CharacterBody3D
@onready var attack_player_detection: Area3D = $attack_player_detection
var direction: Vector3
var Awakening: bool = false
var attacking: bool = false
var health: int = 4
var damage: int = 2
var dying: bool = false
var just_hit: bool = false


func _ready() -> void:
	await get_tree().process_frame
	state_machine.change_state("Idle")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player_1:
		direction = (player_1.global_transform.origin - self.global_transform.origin).normalized()
	move_and_slide()


func _on_chase_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		print("Jugador detectado en área de persecución")
		
		# Si estamos en estado de búsqueda, interrumpirlo inmediatamente
		if state_machine.current_state != null and state_machine.current_state.name == "Search":
			state_machine.current_state.cleanup()
		
		state_machine.change_state("Run")


func _on_chase_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		print("Jugador salió del área de persecución")
		
		# Verificar si todavía hay otros jugadores en el área
		var overlapping_bodies = $chase_player_detection.get_overlapping_bodies()
		var other_players_in_area = false
		
		for overlapping_body in overlapping_bodies:
			if overlapping_body.is_in_group("Players") and overlapping_body != body:
				other_players_in_area = true
				break

		# Solo cambiar a búsqueda si no hay otros jugadores en el área
		if not other_players_in_area:
			state_machine.change_state("Search")


func _on_attack_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		state_machine.change_state("Attack")


func _on_attack_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		state_machine.change_state("Run")


#func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#if "Awaken" in anim_name:
		#Awakening = false
	#elif "Attack" in anim_name:
		#if(player_1 in attack_player_detection.get_overlapping_bodies() and !dying):
			#state_machine.change_state("Attack")
	#elif "Death" in anim_name:
		#death()

func death():
	self.queue_free()
