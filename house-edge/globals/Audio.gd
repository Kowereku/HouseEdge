extends Node

const MUSIC_PATH := "res://assets/audio/music.mp3"
const SFX_CHIP_PATH := "res://assets/audio/sfx.wav"

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	_start_music()


func _start_music():
	if not ResourceLoader.exists(MUSIC_PATH):
		return
	var stream: AudioStream = load(MUSIC_PATH)
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	music_player.stream = stream
	music_player.play()


func play_chip():
	if not ResourceLoader.exists(SFX_CHIP_PATH):
		return
	if sfx_player.stream == null:
		sfx_player.stream = load(SFX_CHIP_PATH)
	sfx_player.play()
