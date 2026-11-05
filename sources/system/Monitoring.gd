extends Node
class_name Monitoring

## Facade that stays parseable without Sentry GDExtension (web Pages strips libsentry).

static var _sentryScript = null
static var _sentryChecked : bool = false

static func IsEnabled() -> bool:
	return Conf.GetUserValue("Privacy-BugReports", false)

static func _Sentry():
	if _sentryChecked:
		return _sentryScript
	_sentryChecked = true
	if OS.has_feature("sentry") and ClassDB.class_exists("SentrySDK"):
		_sentryScript = load("res://sources/system/MonitoringSentry.gd")
	return _sentryScript

static func SetPlayer(playerName : String):
	var impl = _Sentry()
	if impl:
		impl.SetPlayer(playerName)

static func SetTransport(transport : Peers.TransportType):
	var impl = _Sentry()
	if impl:
		impl.SetTransport(transport)

static func Init():
	if not IsEnabled():
		return
	var impl = _Sentry()
	if impl:
		impl.Init()
