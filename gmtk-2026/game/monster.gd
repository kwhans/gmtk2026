extends CharacterBody3D
class_name Monster

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed:float = 3.0
@export var gavinVariant:bool = false
@export var alreadyMoving:bool = false

@onready var idle_sprite: MeshInstance3D = $IdleSprite
@onready var move_sprite: MeshInstance3D = $MoveSprite
@onready var dying_sprite: MeshInstance3D = $DyingSprite
@onready var glow_eyes_sprite: MeshInstance3D = $GlowEyesSprite
@onready var fire_pfx: GPUParticles3D = $FirePfx
@onready var breathing_sound: AudioStreamPlayer3D = $BreathingSound
@onready var attack_sound: AudioStreamPlayer3D = $AttackSound
@onready var darkness_sound: AudioStreamPlayer3D = $DarknessSound
@onready var lost_sound: AudioStreamPlayer3D = $LostSound
@onready var pain_sound: AudioStreamPlayer3D = $PainSound
@onready var scream_sound: AudioStreamPlayer3D = $ScreamSound

@onready var idle_sounds_timer: Timer = $IdleSoundsTimer

@onready var hsm:LimboHSM = $LimboHSM
@onready var idle_state:LimboState = $LimboHSM/IdleState
@onready var move_state:LimboState = $LimboHSM/MoveState
@onready var attack_state:LimboState = $LimboHSM/AttackState
@onready var dying_state:LimboState = $LimboHSM/DyingState

@onready var player_los_raycast:RayCast3D = $PlayerLosRay
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

const EVENT_TORCHED:StringName = &"torched"
const EVENT_OUT_OF_TORCHES:StringName = &"out_of_torches"

var move_direction: Vector3 = Vector3.ZERO
var path_target_node:Node3D = null

enum MonsterAppearance
{
	Idle,
	Moving,
	Attacking,
	Dying
}

func _ready() -> void:
	if gavinVariant:
		idle_sprite = $IdleSprite2
		move_sprite = $MoveSprite2
		dying_sprite = $DyingSprite2
		glow_eyes_sprite = $GlowEyesSprite2
		
	init_state_machine()
	navigation_agent_3d.velocity_computed.connect(on_safe_velocity_computed)
	SignalBus.out_of_torches.connect(on_out_of_torches)
	SignalBus.level_complete.connect(on_level_complete)
	
func _physics_process(delta) -> void:
	var new_velocity:Vector3 = velocity
	new_velocity.y += -gravity * delta
	
	var pathDirection = move_direction
	new_velocity.x = pathDirection.x * speed
	new_velocity.z = pathDirection.z * speed
	
	# Pass desired velocity to the agent for avoidance calculation
	if navigation_agent_3d.avoidance_enabled:
		navigation_agent_3d.set_velocity(new_velocity)
	else:
		on_safe_velocity_computed(new_velocity)

func on_safe_velocity_computed(safe_velocity: Vector3):
	#var velDiff = safe_velocity - velocity
	#print("safe_velocity difference = ", velDiff)
	velocity = safe_velocity
	move_and_slide()

func init_state_machine() -> void:
	hsm.add_transition(idle_state, move_state, idle_state.EVENT_FINISHED)
	hsm.add_transition(move_state, attack_state, move_state.EVENT_FINISHED)
	hsm.add_transition(attack_state, move_state, attack_state.EVENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, dying_state, EVENT_TORCHED)
	
	hsm.add_transition(idle_state, move_state, EVENT_OUT_OF_TORCHES)
	
	hsm.initial_state = move_state if alreadyMoving else idle_state
	hsm.initialize(self)
	hsm.set_active(true)
	
func setAppearance(appearance:MonsterAppearance) -> void:
	match appearance:
		MonsterAppearance.Idle:
			idle_sprite.visible = true
			move_sprite.visible = false
			dying_sprite.visible = false
			glow_eyes_sprite.material_override.emission = Color(1.0, 1.0, 0.388, 1.0) if gavinVariant else Color(0.0, 1.0, 0.596, 1.0)
			glow_eyes_sprite.visible = true
			fire_pfx.emitting = false
			breathing_sound.playing = false
			idle_sounds_timer.start(randf_range(5.0, 20.0))
			
		MonsterAppearance.Moving:
			idle_sprite.visible = true
			move_sprite.visible = false
			dying_sprite.visible = false
			glow_eyes_sprite.material_override.emission = Color(1.0, 1.0, 0.388, 1.0) if gavinVariant else Color(0.0, 1.0, 0.596, 1.0)
			glow_eyes_sprite.visible = true
			fire_pfx.emitting = false
			breathing_sound.playing = true
			idle_sounds_timer.start(randf_range(5.0, 20.0))
			
		MonsterAppearance.Attacking:
			idle_sprite.visible = false
			move_sprite.visible = true
			dying_sprite.visible = false
			glow_eyes_sprite.material_override.emission = Color(1.0, 0.0, 0.0, 1.0)
			glow_eyes_sprite.visible = true
			fire_pfx.emitting = false
			breathing_sound.playing = true
			idle_sounds_timer.stop()
			attack_sound.play()
			
		MonsterAppearance.Dying:
			idle_sprite.visible = false
			move_sprite.visible = false
			dying_sprite.visible = true
			#glow_eyes_sprite.material_override.emission = Color(0.0, 0.0, 0.0, 1.0) if gavinVariant else Color(1.0, 1.0, 1.0, 1.0)
			glow_eyes_sprite.visible = false
			fire_pfx.emitting = true
			breathing_sound.playing = false
			idle_sounds_timer.stop()
			scream_sound.play()
			
func beginFadeOut(duration:float) -> void:
	# Prevent player from dying to a dying ghost
	$HitBox.set_deferred("monitoring", false)
	
	# Create a new Tween instance
	var tween = create_tween()
	
	# Animate the modulate property to transparent (alpha 0.0)
	tween.tween_property(
		$DyingSprite, 
		"transparency", 
		1.0,
		duration
	)
	
	tween.tween_callback(self.queue_free)
	# Start the tween (auto-starts in Godot 4, but explicit is clear)
	tween.play()

func check_los_clear(targetPlayer:Node3D) -> bool:
	if not is_instance_valid(targetPlayer):
		return false
	var directionToTarget = targetPlayer.global_position - global_position
	player_los_raycast.target_position = directionToTarget
	# note that raycast is masked to only collide with environment
	if player_los_raycast.is_colliding():
		#var collider = player_los_raycast.get_collider()
		#print("LOS check collides with", collider)
		return false
	else:
		#print("LOS check didn't collide with anything")
		return true

func update_path_target(targetPlayer:Node3D) -> void:
	path_target_node = targetPlayer
	if targetPlayer == null:
		return
	navigation_agent_3d.target_position = targetPlayer.global_position

func get_next_waypoint() -> Vector3:
	return navigation_agent_3d.get_next_path_position()
	
func set_path_direction(direction:Vector3) -> void:
	move_direction = direction

func _on_hit_box_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"Player"):
		print("Game Over")
		SignalBus.game_over.emit()
		queue_free() # my work here is done
	elif body.is_in_group(&"Torches"):
		print("I've been torched!")
		hsm.dispatch(EVENT_TORCHED)

func on_out_of_torches() -> void:
	hsm.dispatch(EVENT_OUT_OF_TORCHES)

func on_level_complete() -> void:
	hsm.dispatch(EVENT_TORCHED)


func _on_idle_sounds_timer_timeout() -> void:
	# play a random idle sound
	var i = randi() % 3
	match i:
		0: 
			darkness_sound.play()
		1:
			lost_sound.play()
		2:
			pain_sound.play()
			
	# queue up the next random sound time
	idle_sounds_timer.start(randf_range(5.0, 15.0))
