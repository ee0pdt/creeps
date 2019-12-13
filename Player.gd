extends Area2D

signal hit
signal collectedCoin

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var flashing = false

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
    
    var pulseGap = 10
    var lightColor = '#eeeeff'
    var lightEnergyOffset = 0.4
    
    if flashing:
        pulseGap = 1
        lightColor = '#ff0000'
        lightEnergyOffset = 0.6
        
    var lightFactor = abs(sin(deg2rad(OS.get_ticks_msec()/pulseGap)))
    
    $Light2D.energy = lightFactor / 2 + lightEnergyOffset
    $Light2D.scale.x = (lightFactor / 10) + 0.2
    $Light2D.scale.y = (lightFactor / 10) + 0.2
    $Light2D.rotation_degrees += 1
    #$Light2D.color = lightColor
    
    if velocity.x != 0:
        $AnimatedSprite.animation = "right"
        $AnimatedSprite.flip_v = false
        # See the note below about boolean assignment
        $AnimatedSprite.flip_h = velocity.x < 0
    elif velocity.y != 0:
        $AnimatedSprite.animation = "up"
        $AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body):
    var parent = get_parent()
    if body.get_groups().has("mobs"):
        $PlayerHitTimer.start()
        flashing = true
        emit_signal("hit")
        # Stop looking for collisions, we dead
        $CollisionShape2D.set_deferred("disabled", true)
    elif body.get_groups().has("coins"):
        body.queue_free()
        $CoinCollectTimer.start()
        flashing = true
        emit_signal("collectedCoin")

func start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false

func _on_PlayerHitTimer_timeout():
    flashing = false
    $CollisionShape2D.disabled = false

func _on_CoinCollectTimer_timeout():
    flashing = false
