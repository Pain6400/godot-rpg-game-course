extends Node

var AIController
var run: bool = false
var is_active: bool = true

func _ready() -> void:
	AIController = get_parent().get_parent()
	is_active = true
	
	# Si estamos atacando, esperar a que termine
	if AIController.attacking:
		await AIController.get_node("AnimationTree").animation_finished
		AIController.attacking = false
	
	# Si estamos despertando, esperar a que termine
	if AIController.Awakening:
		await AIController.get_node("AnimationTree").animation_finished
		AIController.Awakening = false
	
	run = true
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Run")
	
func _physics_process(delta: float) -> void:
	if AIController and run and is_active:
		AIController.velocity.x = AIController.direction.x * AIController.speed
		AIController.velocity.z = AIController.direction.z * AIController.speed
		AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3(0,1,0))

# Método para limpiar el estado
func cleanup():
	is_active = false
	run = false

func _exit_tree():
	cleanup()
