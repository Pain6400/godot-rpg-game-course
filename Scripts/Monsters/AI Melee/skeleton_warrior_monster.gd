extends CharacterBody3D


const speed: float = 1.0
@onready var state_machine: Node = $StateMachine
@export var player_1: CharacterBody3D
var direction: Vector3
var Awaken: bool = false
var health: int = 4
var damage: int = 2
var dying: bool = false
var just_hit: bool = false
var attack: bool = true

func _ready() -> void:
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
		state_machine.change_state("Run")


func _on_chase_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		state_machine.change_state("Idle")


func _on_attack_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		state_machine.change_state("Attack")


func _on_attack_player_detection_body_exited(body: Node3D) -> void:
	if body.is_in_group("Players") and !dying:
		state_machine.change_state("Run")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Awaken" in anim_name:
		Awaken = false
	elif "Attack" in anim_name:
		if(player_1 in get_node("attack_player_detection").get_overlapping_bodies() and !dying):
			state_machine.change_state("Attack")
	elif "Death" in anim_name:
		death()

func death():
	self.queue_free()
