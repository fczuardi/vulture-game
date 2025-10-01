class_name Energy
extends Resource

@export var total: float = 100.0
var current: float = 100.0

signal updated(current: float, total: float)


func _init() -> void:
    current = total


func spend(amount: float) -> void:
    if amount <= 0.0:
        return
    var before := current
    current = clampf(current - amount, 0.0, total)
    if current != before:
        updated.emit(current, total)


func regen(amount: float) -> void:
    if amount <= 0.0:
        return
    var before := current
    current = clampf(current + amount, 0.0, total)
    if current != before:
        updated.emit(current, total)
