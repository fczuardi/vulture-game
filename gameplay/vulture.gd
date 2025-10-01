extends CharacterBody3D

@export var cam_rig: Node3D # assign sibling CameraRig (with SpringArm+Camera)
@export var energy_resource: Energy

# --- Simple knobs ---
@export var cruise_speed: float = 5.0 # forward base speed
@export var roll_speed: float = 2.5 # how fast you bank
@export var roll_return: float = 2.0 # auto-level strength
@export var yaw_from_bank: float = 0.7 # banked turn rate
@export var cam_turn_smooth: float = 5.0

@export var climb_energy_per_sec: float = 12.0
@export var glide_regen_per_sec: float = 1.0

@export var pitch_speed: float = 2.8 # rad/s for pitch input
@export var pitch_return: float = 2.6 # auto-level pitch speed
@export var pitch_limit_deg: float = 28.0 # clamp so it stays tame
@export var climb_rate: float = 10.0 # vertical m/s at full pitch (sin)
@export var speed_pitch_influence: float = 1.0 # faster down, slower up

const DEADZONE := 0.06

var _roll := 0.0
var _yaw := 0.0
var _pitch := 0.0

signal climb_executed(climb_speed: float, player_driven: bool)


func _physics_process(delta: float) -> void:
    # --- Input (with deadzones) ---
    var i_roll := Input.get_action_strength("fly_roll_left") - Input.get_action_strength("fly_roll_right")
    if abs(i_roll) < DEADZONE:
        i_roll = 0.0
    var i_pitch := Input.get_action_strength("fly_pitch_up") - Input.get_action_strength("fly_pitch_down")
    if abs(i_pitch) < DEADZONE:
        i_pitch = 0.0

    # ----- ENERGY RULES -----
    var wants_climb := i_pitch > 0.0
    if energy_resource != null:
        if wants_climb:
            if energy_resource.current > 0.0:
                energy_resource.spend(climb_energy_per_sec * i_pitch * delta)
            else:
                # out of energy: no climbing
                i_pitch = 0.0
        else:
            # gentle regen when not pitching up
            energy_resource.regen(glide_regen_per_sec * delta)

    # --- Roll ---
    _roll += i_roll * roll_speed * delta
    _roll = lerp(_roll, 0.0, roll_return * delta)
    _roll = clamp(_roll, -0.9, 0.9)

    # --- Yaw from bank (wrap to avoid float drift) ---
    _yaw += _roll * yaw_from_bank * delta
    _yaw = wrapf(_yaw, -PI, PI)

    # --- Pitch ---
    _pitch += i_pitch * pitch_speed * delta
    var limit := deg_to_rad(pitch_limit_deg)
    _pitch = clamp(_pitch, -limit, limit)
    if i_pitch == 0.0:
        _pitch = lerp(_pitch, 0.0, pitch_return * delta)

    # --- Apply orientation ---
    rotation = Vector3(_pitch, _yaw, _roll)

    # --- Movement (decoupled vertical) ---
    var s := sin(_pitch)
    var fwd_flat := (-global_transform.basis.z).slide(Vector3.UP).normalized() # no Y
    var speed: float = max(0.1, cruise_speed - s * speed_pitch_influence)
    velocity = fwd_flat * speed + Vector3.UP * (s * climb_rate)
    move_and_slide()

    # --- Camera (after movement), uses same fwd_flat ---
    if cam_rig:
        var anchor := global_position - fwd_flat * 0.8
        cam_rig.global_position = cam_rig.global_position.lerp(anchor, 12.0 * delta)

        var tgt := Basis.looking_at(fwd_flat, Vector3.UP)
        cam_rig.global_basis = cam_rig.global_basis.slerp(tgt, cam_turn_smooth * delta)
