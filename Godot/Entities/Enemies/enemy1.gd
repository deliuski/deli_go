extends CharacterBody2D
class_name enemy

@onready var healthbar = $HealthBar
@onready var animated_sprite = $AnimatedSprite2D
var speed = 70
var health = 100 
var knockback_high = 200.0
var dead = false
var player_in_area = false
var player = null
var gravity = 900
var player_oniloh = false
var attack_damage = 3
var attacking = false
var turzuursaadal = true


signal facing_direction_changed(facing_right:bool)

func _ready():
	healthbar.visible = false
	dead = false
	healthbar.init_health(health)

func _physics_process(delta):
	playerru_Attack()
	velocity.y += gravity * delta
	is_death()

	if player_in_area:
		if is_on_floor():
			velocity.y = 0

		if !player_oniloh and player and player_in_area:	
			var direction = (player.position - position).normalized()
			velocity.x = direction.x * speed 
			det_dir(direction)
			animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	move_and_slide()

func det_dir(dir: Vector2):
	if dir.x > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	emit_signal("facing_direction_changed", !animated_sprite.flip_h)

func take_damage(damage_amount):
	healthbar.visible = true
	await wait_for_animation("damaged", 0.8)
	health -= damage_amount
	healthbar.health = health

func wait_for_animation(anim: String, duration: float) -> void:
	animated_sprite.play(anim)
	await get_tree().create_timer(duration).timeout
	

func is_death():
	if health <= 0:
		dead = true
		health = 0
		await wait_for_animation("death", 0.8)
		queue_free()

func playerru_Attack():
	if player_oniloh and not attacking:
		if turzuursaadal:
			await get_tree().create_timer(0.5).timeout
			turzuursaadal = false
		send_damage()

func send_damage():
	if not attacking and player_oniloh:
		$attack_cooldown.start()
		attacking = true
		await wait_for_animation("attack_1", 1)
		player.take_damage(attack_damage)
		
	elif player_oniloh:
		animated_sprite.play("idle")
		
func _on_attack_cooldown_timeout():
	attacking = false

func _on_hitbox_body_entered(body):
	if body == player:
		player_oniloh = true

func _on_hitbox_body_exited(body):
	if body == player:
		player_oniloh = false
		attacking = false
		
func _on_detection_area_body_entered(body):
	print("orj irsen body ", body)
	if body.has_method("player"):
		player_in_area = true
		player = body 

func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		body = null

		
