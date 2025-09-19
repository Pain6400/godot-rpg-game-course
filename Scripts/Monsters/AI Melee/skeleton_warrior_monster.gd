extends CharacterBody3D


var speed: float = 1.0
@onready var state_machine: Node = $StateMachine
@export var player_1: CharacterBody3D
@onready var attack_player_detection: Area3D = $attack_player_detection
@onready var just_hit_Timer: Timer = $Just_Hit

var direction: Vector3
var Awakening: bool = false
var attacking: bool = false
var searching: bool = false
var health: int = 4
var damage: int = 2
var dying: bool = false
var just_hit: bool = false
var last_known_player_position: Vector3

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
		if player_1:
			last_known_player_position = player_1.global_transform.origin
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

func hit(demage: int):
	print("vida: ",health)
	print("demage: ",demage)
	print("just_hit: ",just_hit)
	if !just_hit:
		just_hit = true
		just_hit_Timer.start()
		health -=demage
		print(health)
		if health < 1:
			state_machine.change_state("Death")
			
		var tween = create_tween()
		tween.tween_property(self, "global_position", global_position - (direction/1.5), 0.2)

func _on_demage_detecter_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_just_hit_timeout() -> void:
	just_hit = false
