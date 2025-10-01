extends Control

@export var hunger: HungerMeter
@export var bar: Range # ProgressBar / TextureProgressBar
@export var label: Label # optional mm:ss


func _ready() -> void:
    assert(hunger)
    assert(bar)
    bar.min_value = 0.0
    bar.max_value = hunger.max_time
    bar.value = hunger.remaining
    if label:
        label.text = _fmt(hunger.remaining)
    hunger.updated.connect(_on_changed)
    hunger.depleted.connect(_on_depleted)


func _on_changed(rem: float, maxv: float) -> void:
    bar.max_value = maxv
    bar.value = rem
    if label:
        label.text = _fmt(rem)


func _on_depleted() -> void:
    # TODO: trigger fail state / vignette / slow-mo, etc.
    pass


func _fmt(t: float) -> String:
    var s := int(ceil(t))
    var m := s / 60
    var r := s % 60
    return "%02d:%02d" % [m, r]
