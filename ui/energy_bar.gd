extends Control

@export var energy: Energy
@export var energy_bar: Range # ProgressBar or TextureProgressBar


func _ready() -> void:
    assert(energy)
    assert(energy_bar)
    energy_bar.min_value = 0.0
    energy_bar.max_value = energy.total
    energy_bar.value = energy.current
    energy.updated.connect(_on_energy_changed)


func _on_energy_changed(cur: float, maxv: float) -> void:
    energy_bar.max_value = maxv
    energy_bar.value = cur
