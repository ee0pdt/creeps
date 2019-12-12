extends Area2D

signal hit
signal collectedCoin

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.

func _ready():
    screen_size = get_viewport_rect().size
    hide()
  
func _process(delta):
    var velocity = Vector2()  # The player's movement vector.
    if Input.is_action_pressed("ui_right"):
        velocity.x += 1
    if Input.is_action_pressed("ui_left"):
        velocity.x -= 1
    if Input.is_action_pressed("ui_down"):
        velocity.y += 1
    if Input.is_action_pressed("ui_up"):
        velocity.y -= 1
    if velocity.length() > 0:
        velocity = velocity.normalized() * speed
        $AnimatedSprite.play()
    else:
        $AnimatedSprite.stop()
    position += velocity * delta
    position.x = clamp(position.x, 0, screen_size.x)
    position.y = clamp(position.y, 0, screen_size.y)
    
    var lightFactor = abs(sin(deg2rad(OS.get_ticks_msec()/10)))
    
    $Light2D.energy = lightFactor / 2 + 0.4
    $Light2D.scale.x = (lightFactor / 10) + 0.2
    $Light2D.scale.y = (lightFactor / 10) + 0.2
    $Light2D.rotation_degrees += 1
    
    if velocity.x != 0:
        $AnimatedSprite.animation = "right"
        $AnimatedSprite.flip_v = false
        # See the note below about boolean assignment
        $AnimatedSprite.flip_h = velocity.x < 0
    elif velocity.y != 0:
        $AnimatedSprite.animation = "up"
        $AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body):
    print(body.get_groups())
    if body.get_groups().has("mobs"):
        hide()  # Player disappears after being hit.
        emit_signal("hit")
        # Stop looking for collisions, we dead
        $CollisionShape2D.set_deferred("disabled", true)
    elif body.get_groups().has("coins"):
        body.queue_free()
        emit_signal("collectedCoin")

func start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false
