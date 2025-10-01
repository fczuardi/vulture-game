class_name HungerMeter
extends Resource

@export var max_time: float = 90.0 # seconds until starving
@export var rate: float = 1.0 # drain speed multiplier (1 = real time)
@export var running: bool = true

var remaining: float = 90.0

signal updated(remaining: float, max_time: float)
signal depleted()


func _init() -> void:
    remaining = max_time


func tick(delta: float) -> void:
    if not running or remaining <= 0.0:
        return
    var before := remaining
    remaining = max(0.0, remaining - delta * rate)
    if remaining != before:
        updated.emit(remaining, max_time)
        if remaining == 0.0:
            emit_signal("depleted")


func reset(new_max: float = -1.0) -> void:
    if new_max > 0.0:
        max_time = new_max
    remaining = max_time
    updated.emit(remaining, max_time)


func add_time(seconds: float) -> void:
    if seconds <= 0.0:
        return
    var before := remaining
    remaining = clampf(remaining + seconds, 0.0, max_time)
    if remaining != before:
        updated.emit(remaining, max_time)


func set_running(v: bool) -> void:
    running = v
