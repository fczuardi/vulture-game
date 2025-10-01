class_name HungerTicker
extends Node

@export var hunger: HungerMeter
@export var auto_start: bool = true  # starts ticking immediately when unpaused

func _ready() -> void:
    if hunger and auto_start:
        hunger.set_running(true)

func _process(delta: float) -> void:
    if hunger:
        hunger.tick(delta)
