extends Resource
class_name WaveEvent

@export var start_time: int = 0         # When this event starts (in seconds)
@export var end_time: int = 60          # When it ends (in seconds)
@export var enemy_scene: PackedScene    # The enemy to spawn
@export var spawn_interval: int = 1     # How often to spawn them (in seconds)
@export var amount_per_spawn: int = 1   # How many to spawn at once