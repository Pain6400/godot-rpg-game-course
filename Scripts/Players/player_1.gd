extends CharacterBody3D

@onready var _player_pcam: PhantomCamera3D = %PlayerPhantomCamera3D
@onready var _aim_pcam: PhantomCamera3D = %PlayerAimPhantomCamera3D


@export var mouse_sensitivity: float = 0.05

@export var min_pitch: float = -89.9
@export var max_pitch: float = 40

@export var min_yaw: float = 0
@export var max_yaw: float = 360
