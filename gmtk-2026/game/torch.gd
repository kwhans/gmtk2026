extends RigidBody3D
class_name Torch

@onready var regular_burn_timer: Timer = $RegularBurnTimer
@onready var burnout_timer: Timer = $BurnoutTimer
@onready var despawn_timer: Timer = $DespawnTimer

@onready var fire_particles_early: GPUParticles3D = $TorchStick/FireParticlesEarly
@onready var fire_particles_mid: GPUParticles3D = $TorchStick/FireParticlesMid
@onready var fire_particles_late: GPUParticles3D = $TorchStick/FireParticlesLate

@onready var smoke_particles: GPUParticles3D = $TorchStick/SmokeParticles

@onready var omni_light_3d: OmniLight3D = $TorchStick/OmniLight3D

func _ready() -> void:
	omni_light_3d.light_energy = 0.0
	var tween = create_tween()
	tween.tween_property(omni_light_3d, "light_energy", 5.0, 2.0)

func enableCollisions() -> void:
	$CollisionShape3D.set_deferred("disabled", false)
	
func _on_early_burn_timer_timeout() -> void:
	fire_particles_mid.emitting = true
	fire_particles_early.emitting = false
	regular_burn_timer.start()
	
	var tween = create_tween()
	tween.tween_property(omni_light_3d, "light_energy", 2.0, 3.0)
	
func _on_regular_burn_timer_timeout() -> void:
	fire_particles_late.emitting = true
	fire_particles_mid.emitting = false
	burnout_timer.start()
	
	var tween = create_tween()
	#tween.set_parallel(true)  # in case I want to add more things in parallel later
	tween.tween_property(omni_light_3d, "light_energy", 0.0, burnout_timer.wait_time)
	#tween.tween_property(fire_particles, "lifetime", 0.1, burnout_timer.wait_time)
	
func _on_burnout_timer_timeout() -> void:
	fire_particles_late.emitting = false
	smoke_particles.emitting = false
	despawn_timer.start()
	
func _on_despawn_timer_timeout() -> void:
	queue_free()
