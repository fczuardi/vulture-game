class_name MobileInput
extends MarginContainer
## Displays the 2 on-screen sticks if the first interaction is a touch event
## or just hide the paused screen message if the player is using other inputs
## like keyboard + mouse or controller

@export var paused_ui: Control
@export var on_screen_controls: Control
@export var input_to_continue_title: Label
@export var input_to_continue_subtitle: Label
@export var settle_physics_frames: int = 2

var _started: bool


func _ready() -> void:
    assert(paused_ui)
    assert(on_screen_controls)
    assert(input_to_continue_title)
    assert(input_to_continue_subtitle)
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_process_unhandled_input(true)
    paused_ui.visible = true
    _started = false
    on_screen_controls.visible = false
    input_to_continue_title.text = "Interact to Start"
    input_to_continue_subtitle.text = "\n\nTouch, Move Left Stick Sideways, or Press A or D to continue"

    # Let the world run briefly so the camera reaches its spot, THEN pause.
    get_tree().paused = false
    await _delay_physics_frames(settle_physics_frames)
    if not _started:
        get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
    #print_debug(event)
    if _started:
        return
    var via_touch := false
    if event is InputEventScreenTouch and event.pressed:
        via_touch = true
    elif event is InputEventScreenDrag:
        via_touch = true

    if via_touch or \
    event.is_action_pressed("fly_roll_right") or \
    event.is_action_pressed("fly_roll_left"):
        _start_game(via_touch)


func _start_game(via_touch: bool) -> void:
    _started = true
    get_tree().paused = false

    paused_ui.visible = false
    paused_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
    on_screen_controls.visible = via_touch
    set_process_unhandled_input(false)


func _delay_physics_frames(n: int) -> void:
    if n < 1:
        return
    for i in range(n):
        await get_tree().physics_frame
