class_name CameraRig
extends Node3D

@export var yaw_node: Node3D
@export var pitch_node: Node3D
@export var spring_arm: SpringArm3D

@export var mouse_sens: float = 0.12
@export var touch_sens: float = 0.12 # pixels → degrees (match mouse feel)
@export var stick_sens: float = 90.0 # deg/sec at full stick
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 45.0
@export var invert_yaw: bool = true
@export var invert_pitch: bool = true
@export var mouse_requires_rmb: bool = false
@export var touch_look_enabled: bool = true # whole-screen drag for camera

# Yaw cone relative to body (CamRig anchor)
@export var limit_yaw: bool = true
@export var yaw_min_deg: float = -110.0
@export var yaw_max_deg: float = 110.0
@export var normalize_yaw: bool = true # if not limiting, keep in [-180, 180]

var _yaw_deg: float = 0.0
var _pitch_deg: float = 0.0

# touch state
var _touch_active: bool = false
var _touch_index: int = -1
var _last_touch_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
    if yaw_node == null or pitch_node == null:
        push_warning("Assign yaw_node (LookYaw) and pitch_node (LookPitch).")
        return
    _yaw_deg = yaw_node.rotation_degrees.y
    _pitch_deg = pitch_node.rotation_degrees.x
    if not _is_mobile() and not mouse_requires_rmb:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    set_process_input(true) # ensure _input runs everywhere


func _input(event: InputEvent) -> void:
    # --- capture mouse on click (desktop/web) ---
    if event is InputEventMouseButton and event.pressed and not mouse_requires_rmb:
        if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

    # --- mouse-look ---
    if event is InputEventMouseMotion and _mouse_enabled():
        var yaw_sign := 1.0
        if invert_yaw:
            yaw_sign = -1.0
        var pitch_sign := 1.0
        if invert_pitch:
            pitch_sign = -1.0
        _yaw_deg += event.relative.x * mouse_sens * yaw_sign
        _pitch_deg -= event.relative.y * mouse_sens * pitch_sign

    # --- touch-look (whole screen drag) ---
    if touch_look_enabled:
        if event is InputEventScreenTouch:
            if event.pressed and not _touch_active:
                _touch_active = true
                _touch_index = event.index
                _last_touch_pos = event.position
            elif not event.pressed and event.index == _touch_index:
                _touch_active = false
                _touch_index = -1
        elif event is InputEventScreenDrag:
            if _touch_active and event.index == _touch_index:
                var rel: Vector2 = event.relative
                # Some platforms may give (0,0); fall back to diff
                if rel == Vector2.ZERO:
                    rel = event.position - _last_touch_pos
                var yaw_sign2 := 1.0
                if invert_yaw:
                    yaw_sign2 = -1.0
                var pitch_sign2 := 1.0
                if invert_pitch:
                    pitch_sign2 = -1.0
                _yaw_deg += rel.x * touch_sens * yaw_sign2
                _pitch_deg -= rel.y * touch_sens * pitch_sign2
                _last_touch_pos = event.position


func _process(delta: float) -> void:
    # virtual-stick (if you still keep it mapped)
    var lx := Input.get_action_strength("cam_look_right") - Input.get_action_strength("cam_look_left")
    var ly := Input.get_action_strength("cam_look_down") - Input.get_action_strength("cam_look_up")

    var yaw_sign := 1.0
    if invert_yaw:
        yaw_sign = -1.0
    var pitch_sign := 1.0
    if invert_pitch:
        pitch_sign = -1.0

    _yaw_deg += lx * stick_sens * delta * yaw_sign
    _pitch_deg += ly * stick_sens * delta * pitch_sign

    # clamp pitch
    _pitch_deg = clampf(_pitch_deg, pitch_min_deg, pitch_max_deg)

    # clamp/normalize yaw (relative to anchor)
    if limit_yaw:
        if _yaw_deg < yaw_min_deg:
            _yaw_deg = yaw_min_deg
        if _yaw_deg > yaw_max_deg:
            _yaw_deg = yaw_max_deg
    elif normalize_yaw:
        while _yaw_deg > 180.0:
            _yaw_deg -= 360.0
        while _yaw_deg < -180.0:
            _yaw_deg += 360.0

    # apply to pivots
    if yaw_node:
        var ye := yaw_node.rotation_degrees
        ye.y = _yaw_deg
        yaw_node.rotation_degrees = ye
    if pitch_node:
        var pe := pitch_node.rotation_degrees
        pe.x = _pitch_deg
        pitch_node.rotation_degrees = pe


func _mouse_enabled() -> bool:
    if mouse_requires_rmb:
        return Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
    return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED


func _is_mobile() -> bool:
    var n := OS.get_name()
    return n == "Android" or n == "iOS"
