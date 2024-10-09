extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $"../UI_manager/HealthBar"
var speed = 250.0
const jump_power = -300.0
var jump_count = 0
var jump_max = 2
var gravity = 900
var health = 100
var player_alive = true
var enemy_inattack_range = false
var attack_cooldown_stopped = false
var anyMovement = false
var combo = 0
var KNOCKBACK_DAMAGE_1 = 100
var KNOCKBACK_DAMAGE_2 = 300
var ATTACK_1_DAMAGE = 30
var ATTACK_2_DAMAGE = 50

var enemy = null

signal facing_direction_changed(facing_right:bool)


func _ready():
	healthbar.init_health(health)

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	det_dir(direction)
	gravity_and_jump(delta)
	attack()
	player_controller(direction)

	move_and_slide()
	
func det_dir(dir):
	if dir == 1:
		animated_sprite.flip_h = false
	if dir == -1:
		animated_sprite.flip_h = true
		
	emit_signal("facing_direction_changed", !animated_sprite.flip_h)
		
func gravity_and_jump(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	elif jump_count != 0:
		jump_count = 0
		
func player_controller(dir):
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if !anyMovement:
		if is_on_floor():
			speed = 250
			if velocity.x == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
				det_dir(dir)
		else:
			speed = 100
			
	if Input.is_action_just_pressed("up") and jump_count < jump_max:
		speed = 100
		velocity.y = jump_power
		jump_count += 1 

func attack():
	if Input.is_action_just_pressed("attack") and !anyMovement:
		
		anyMovement = true
		speed = 20
		
		if combo == 0:
			$AttackTimer.start()
			animated_sprite.play("attack_1")
			send_damage(ATTACK_1_DAMAGE)
			combo = 1
			attack_cooldown_stopped = false
		elif combo == 1 and not attack_cooldown_stopped:
			animated_sprite.play("attack_2")
			await get_tree().create_timer(0.2).timeout
			send_damage(ATTACK_2_DAMAGE)
			combo = 0
			attack_cooldown_stopped = true
			$AttackTimer.stop()

		await get_tree().create_timer(0.7).timeout
		anyMovement = false


func send_damage(damage):
	if enemy_inattack_range and enemy:
		enemy.take_damage(damage)

		
func player():
	pass

func take_damage(damage_amount):
	healthbar.visible = true
	health -= damage_amount
	if health <= 0:
		player_alive = false
		health = 0
		$AnimatedSprite2D.play("death")
		await get_tree().create_timer(1).timeout
		self.queue_free()

	healthbar.health = health

func _on_player_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		enemy_inattack_range = true
		enemy = body

func _on_player_hitbox_body_exited(body):
	if body == enemy:
		enemy_inattack_range = false
		enemy = null


func _on_attack_timer_timeout():
	combo = 0
	attack_cooldown_stopped = true
