extends CharacterBody3D
class_name Monster

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed:float = 2.0

@onready var hsm:LimboHSM = $LimboHSM
@onready var idle_state:LimboState = $LimboHSM/IdleState
@onready var move_state:LimboState = $LimboHSM/MoveState

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
	hsm.add_transition(move_state, idle_state, move_state.EVENT_FINISHED)
	
	hsm.initialize(self)
	hsm.set_active(true)
	
func idle_ready():
	pass

func idle_update(delta):
	pass
	
func move_ready():
	pass

func move_update(delta):
	pass
	
func setAppearance(appearance:MonsterAppearance):
	match appearance:
		MonsterAppearance.Idle:
			$IdleSprite.visible = true
			$MoveSprite.visible = false
			$DyingSprite.visible = false
		MonsterAppearance.Attacking:
			$IdleSprite.visible = false
			$MoveSprite.visible = true
			$DyingSprite.visible = false
		MonsterAppearance.Dying:
			$IdleSprite.visible = false
			$MoveSprite.visible = false
			$DyingSprite.visible = true
