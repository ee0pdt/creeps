extends RigidBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
    add_to_group("coins")
    $Sprite/AnimationPlayer.play("Spin")

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()

func _on_start_game():
    queue_free()

func _process(delta):
    $Light2D.rotation_degrees = randi()
