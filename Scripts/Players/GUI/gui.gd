extends CanvasLayer
@onready var containter: Control = $containter
@onready var inventoty_button: Button = $containter/VBoxContainer/inventoty_button
@onready var profile_button: Button = $containter/VBoxContainer/profile_button
@onready var inventory: Control = $containter/inventory
@onready var profile: Control = $containter/profile

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


func _on_inventoty_button_pressed() -> void:
	inventoty_button.disabled = true
	profile_button.disabled = false
	inventory.show()
	profile.hide()
	
func _on_profile_button_pressed() -> void:
	inventoty_button.disabled = false
	profile_button.disabled = true
	inventory.hide()
	profile.show()
