extends RigidBody2D

export var min_speed = 100  # Minimum speed range.
export var max_speed = 200  # Maximum speed range.
var mob_types = ["walk", "swim", "fly"]

func _ready():
    add_to_group("mobs")
    $AnimatedSprite.animation = mob_types[randi() % mob_types.size()]

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()

func _on_start_game():
    queue_free()
