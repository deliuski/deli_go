extends Area2D

@export var speed = 200
@export var damage = 15

var direction:Vector2
var self_

func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

func set_direction(bulletDirection: Vector2, combos: int , self__ ):
	self_ = self__
	if combos == 1:
		$AnimatedSprite2D.play("attack_1")
	else:
		$AnimatedSprite2D.play("attack_2")
	direction = bulletDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position + direction))


func _physics_process(delta):
	global_position += direction * speed * delta
	
func magic():
	pass
	
func _on_body_entered(body):
	if body.has_method("take_damage") :
		if self_ != body:
			body.take_damage(damage)
			queue_free()
