extends Node

var AIController
var is_active: bool = true

func _ready() -> void:
	AIController = get_parent().get_parent()
	is_active = true
	
	# Verificar si hay jugadores en el área de detección al iniciar Idle
	var chase_area = AIController.get_node("chase_player_detection")
	var overlapping_bodies = chase_area.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("Players"):
			# Si hay jugadores, cambiar inmediatamente a Run
			AIController.state_machine.change_state("Run")
			return
	
	# Forzar la transición a Idle solo si no hay jugadores
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Idle")
	
func _physics_process(delta: float) -> void:
	if AIController and is_active:
		AIController.velocity.x = 0
		AIController.velocity.z = 0

# Método para limpiar el estado
func cleanup():
	is_active = false

func _exit_tree():
	cleanup()
