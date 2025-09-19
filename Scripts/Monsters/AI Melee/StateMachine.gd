extends Node

var state = {
	"Idle": preload("res://Scripts/Monsters/AI Melee/IdleState.gd"),
	"Run": preload("res://Scripts/Monsters/AI Melee/RunState.gd"),
	"Attack": preload("res://Scripts/Monsters/AI Melee/AttackState.gd"),
	"Death": preload("res://Scripts/Monsters/AI Melee/DeathState.gd"),
	"Search": preload("res://Scripts/Monsters/AI Melee/SearchState.gd")
}

var current_state = null

func change_state(new_state: String):
	# No hacer nada si ya estamos en el estado solicitado
	if current_state != null and current_state.name == new_state:
		return
	
	print("Cambiando de estado: ", current_state.name if current_state else "Ninguno", " -> ", new_state)
	
	# Limpiar el estado actual si existe
	if current_state != null:
		# Llamar a cleanup del estado actual si existe
		if current_state.has_method("cleanup"):
			current_state.cleanup()
		current_state.queue_free()
		current_state = null
	
	# Crear el nuevo estado
	if state.has(new_state):
		var state_temp = state[new_state].new()
		state_temp.name = new_state
		add_child(state_temp)
		current_state = state_temp
