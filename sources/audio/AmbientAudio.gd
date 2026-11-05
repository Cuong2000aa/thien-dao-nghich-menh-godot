extends Node
class_name AmbientAudio

## TDNM — BUILD 13: Ambient audio integration point
## Plays looping ambience on the Ambient bus when a valid stream is provided.
## Stops cleanly on map leave / tree exit — no infinite overlap after scene close.
## Do not invent proprietary audio assets; only call Play() with cleared-rights streams.

static var _player : AudioStreamPlayer = null

static func EnsurePlayer(host : Node) -> AudioStreamPlayer:
	if _player and is_instance_valid(_player):
		return _player
	if host == null or not is_instance_valid(host):
		return null
	_player = AudioStreamPlayer.new()
	_player.name = "AmbientAudioPlayer"
	_player.bus = ActorCommons.AmbientBus
	host.add_child(_player)
	return _player

static func Play(host : Node, stream : AudioStream, volumeDb : float = -8.0) -> void:
	if stream == null:
		return
	var player := EnsurePlayer(host)
	if player == null:
		return
	if player.stream == stream and player.playing:
		return
	player.stream = stream
	player.volume_db = volumeDb
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	player.play()

static func Stop() -> void:
	if _player and is_instance_valid(_player):
		_player.stop()
		_player.stream = null

static func Dispose() -> void:
	Stop()
	if _player and is_instance_valid(_player):
		_player.queue_free()
	_player = null
