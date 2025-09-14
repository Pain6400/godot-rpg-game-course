extends Camera3D

@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D
@onready var _aim_pcam: PhantomCamera3D = %PlayerAimPhantomCamera3D
@onready var player_1: CharacterBody3D = %player_1

@export var mouse_sensitivity: float = 0.05
@export var min_pitch: float = -89.9
@export var max_pitch: float = 40
@export var min_yaw: float = 0
@export var max_yaw: float = 360

# Variables para guardar la configuración actual en lugar de la inicial
var _current_spring_length: float
var _current_rotation: Vector3
var _is_aiming: bool = false

func _ready() -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if player_1.velocity.length() > 0.2:
		var look_direction: Vector2 = Vector2(player_1.velocity.z, player_1.velocity.x)

func _unhandled_input(event: InputEvent) -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.FollowMode.THIRD_PERSON:
		# Guardar la configuración actual antes de aplicar rotaciones
		_current_rotation = _player_pcam.get_third_person_rotation_degrees()
		
		_set_pcam_rotation(_player_pcam, event)
		_set_pcam_rotation(_aim_pcam, event)
		
		if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
			_toggle_aim_pcam(event)

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3 = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		pcam_rotation_degrees.x = clampf(pcam_rotation_degrees.x, min_pitch, max_pitch)
		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_yaw, max_yaw)
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)
		
		# Actualizar la rotación actual
		if pcam == _player_pcam:
			_current_rotation = pcam_rotation_degrees

func _toggle_aim_pcam(event: InputEvent) -> void:
	if not (_player_pcam.is_active() or _aim_pcam.is_active()):
		return
	
	_is_aiming = !_is_aiming
	
	if _is_aiming:
		# Guardar la configuración actual antes de cambiar a la cámara de apuntar
		_current_spring_length = _player_pcam.spring_length
		_current_rotation = _player_pcam.get_third_person_rotation_degrees()
		
		# Cambiar a la cámara de apuntar
		_aim_pcam.set_priority(30)
		_player_pcam.set_priority(0)
	else:
		# Volver a la cámara principal y restaurar configuración actual
		_aim_pcam.set_priority(0)
		_player_pcam.set_priority(30)
	
