extends CanvasLayer
@onready var containter: Control = $containter

func  _ready() -> void:
	containter.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		containter.visible = get_tree().paused
		match get_tree().paused:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			false:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
