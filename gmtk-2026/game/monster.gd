extends CharacterBody3D
class_name Monster

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed:float = 2.0

@onready var hsm:LimboHSM = $LimboHSM
@onready var idle_state:LimboState = $LimboHSM/IdleState
@onready var move_state:LimboState = $LimboHSM/MoveState
@onready var attack_state:LimboState = $LimboHSM/AttackState
@onready var dying_state:LimboState = $LimboHSM/DyingState

@onready var playerLosRaycast:RayCast3D = $PlayerLosRay

const EVENT_TORCHED:StringName = &"torched"

enum MonsterAppearance
{
	Idle,
	Attacking,
	Dying
}

func _ready() -> void:
	init_state_machine()
	
func _physics_process(delta) -> void:
	velocity.y += -gravity * delta
	#var input = Input.get_vector("left", "right", "forward", "back")
	#var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
	#velocity.x = movement_dir.x * speed
	#velocity.z = movement_dir.z * speed

	move_and_slide()
	
func init_state_machine() -> void:
	hsm.add_transition(idle_state, move_state, idle_state.EVENT_FINISHED)
	hsm.add_transition(move_state, attack_state, move_state.EVENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, dying_state, EVENT_TORCHED)
	
	hsm.initial_state = idle_state
	hsm.initialize(self)
	hsm.set_active(true)
	
func setAppearance(appearance:MonsterAppearance) -> void:
	match appearance:
		MonsterAppearance.Idle:
			$IdleSprite.visible = true
			$MoveSprite.visible = false
			$DyingSprite.visible = false
			$FirePfx.emitting = false
		MonsterAppearance.Attacking:
			$IdleSprite.visible = false
			$MoveSprite.visible = true
			$DyingSprite.visible = false
			$FirePfx.emitting = false
		MonsterAppearance.Dying:
			$IdleSprite.visible = false
			$MoveSprite.visible = false
			$DyingSprite.visible = true
			$FirePfx.emitting = true
			
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

func _on_awareness_area_body_entered(_body: Node3D) -> void:
	hsm.dispatch($LimboHSM/IdleState.EVENT_FINISHED)

func check_los(targetPlayer:Node3D) -> bool:
	var directionToTarget = targetPlayer.global_position - global_position
	playerLosRaycast.target_position = directionToTarget
	# note that raycast is masked to only collide with environment
	if playerLosRaycast.is_colliding():
		return false
	else:
		return true


func _on_hit_box_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"Player"):
		print("Game Over")
		SignalBus.game_over.emit()
	elif body.is_in_group(&"Torches"):
		print("I've been torched!")
		hsm.dispatch(EVENT_TORCHED)
