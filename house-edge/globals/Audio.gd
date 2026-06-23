extends Node

# Central sound manager (autoload).
#   Audio.play_sfx("shoot")        - one-shot effect, polyphonic, slight pitch variation
#   Audio.play_music(stream, true) - swap the looping background track
# SFX keys map to files in assets/audio/. Missing files are skipped safely so
# the game never crashes if an asset is absent.

const MUSIC_PATH := "res://assets/audio/music.mp3"

# key -> file path. Add new effects here and they're instantly usable.
const SFX_PATHS := {
	"chip": "res://assets/audio/sfx.wav",
	"shoot": "res://assets/audio/shoot.wav",
	"hit": "res://assets/audio/hit.wav",
	"enemy_death": "res://assets/audio/enemy_death.wav",
	"level_up": "res://assets/audio/level_up.wav",
	"hurt": "res://assets/audio/hurt.wav",
	"click": "res://assets/audio/click.wav",
}

const SFX_VOICES := 12  # how many effects can overlap at once

var music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_next: int = 0
var _streams: Dictionary = {}

func _ready():
	# Run even while the game is paused (so menu clicks still sound).
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	for i in SFX_VOICES:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

	_preload_streams()
	_start_music()

	# Auto-play a click on every button in the game, present or future,
	# with no per-scene wiring needed.
	get_tree().node_added.connect(_on_node_added)
	_hook_existing_buttons(get_tree().root)

func _preload_streams():
	for key in SFX_PATHS:
		var path: String = SFX_PATHS[key]
		if ResourceLoader.exists(path):
			_streams[key] = load(path)

func _start_music():
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	play_music(load(MUSIC_PATH), true)

# --- Public API ---------------------------------------------------------

func play_sfx(key: String, pitch_variation: float = 0.08):
	if not _streams.has(key):
		return
	var player := _sfx_pool[_sfx_next]
	_sfx_next = (_sfx_next + 1) % _sfx_pool.size()
	player.stream = _streams[key]
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()

func play_music(stream: AudioStream, loop: bool = true):
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	music_player.stream = stream
	music_player.play()

# Kept for backwards compatibility with existing calls.
func play_chip():
	play_sfx("chip")

# --- Button click auto-wiring -------------------------------------------

func _on_node_added(node: Node):
	if node is BaseButton and not node.pressed.is_connected(_play_click):
		node.pressed.connect(_play_click)

func _hook_existing_buttons(node: Node):
	if node is BaseButton and not node.pressed.is_connected(_play_click):
		node.pressed.connect(_play_click)
	for child in node.get_children():
		_hook_existing_buttons(child)

func _play_click():
	play_sfx("click", 0.0)
