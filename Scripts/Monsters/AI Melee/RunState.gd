extends Node

var AIController
var run: bool

func _ready() -> void:
	AIController = get_parent().get_parent()
	if AIController.attack:
		await  AIController.get_node("AnimationTree").animation_finished
		AIController.attack = false
		
	else:
		run = false
		AIController.get_node("AnimationTree").get("parameters/playback").travel("Awaken")
		AIController.Awaken = true
		await  AIController.get_node("AnimationTree").animation_finished
	
	run = true
	AIController.Awaken = false
	AIController.get_node("AnimationTree").get("parameters/playback").travel("Run")
	
func _physics_process(delta: float) -> void:
	if AIController and run:
		AIController.velocity.x = AIController.direction.x * AIController.speed
		AIController.velocity.z = AIController.direction.z * AIController.speed
		AIController.look_at(AIController.global_transform.origin + AIController.direction, Vector3(0,1,0))
