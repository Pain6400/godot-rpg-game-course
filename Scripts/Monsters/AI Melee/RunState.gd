extends Node

var AIController
var run: bool

func _ready() -> void:
	AIController = get_parent().get_parent()
	if AIController.attacking:
		await  AIController.get_node("AnimationTree").animation_finished
		AIController.attacking = false

	else:
		run = false
		AIController.get_node("AnimationTree").get("parameters/playback").travel("Awaken")
		AIController.Awakening = true
		await  AIController.get_node("AnimationTree").animation_finished
	
	run = true
	AIController.Awakening = false
	AIController.searching = false
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Run")
	
func _physics_process(delta: float) -> void:
	if AIController and run and not AIController.searching:
		AIController.velocity.x = AIController.direction.x * AIController.speed
		AIController.velocity.z = AIController.direction.z * AIController.speed
		AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3(0,1,0))
