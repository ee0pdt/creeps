extends Node

export (PackedScene) var Mob
export (PackedScene) var Coin

const INITIAL_LIVES = 3

var highscore
export var score = 0
export var lives = INITIAL_LIVES
const MAX_MOBS = 5;
const WIN_TARGET = 10

var savegame = File.new() #file
var save_path = "user://savegame.save" #place of the file
var save_data = {"highscore": 0} #variable to store data

func create_save():
   savegame.open(save_path, File.WRITE)
   savegame.store_var(save_data)
   savegame.close()

func _ready():
    if not savegame.file_exists(save_path):
        create_save()
    highscore = get_highscore()
    $MenuMusic.play()
    randomize()

func player_hit():
    lives = lives - 1
    $HUD.update_lives(lives)
    if lives < 1:
        game_over()
    else:
        $AlertSound.play()

func game_over():
    $Music.stop()
    $DeathSound.play()
    $Player.hide()
    $MobTimer.stop()
    $HUD.show_game_over()
    save_high_score(score)
    
func get_highscore():
   savegame.open(save_path, File.READ) #open the file
   save_data = savegame.get_var() #get the value
   savegame.close() #close the file
   return save_data["highscore"] #return the value

func save_high_score(high_score):    
   save_data["highscore"] = high_score #data to save
   savegame.open(save_path, File.WRITE) #open file to write
   savegame.store_var(save_data) #store the data
   savegame.close() # close the file

func new_game():
    $MenuMusic.stop()
    $Music.play()
    lives = INITIAL_LIVES
    print(lives)
    score = 0
    $MobTimer.wait_time = 3
    $Player.start($StartPosition.position)
    $Player.flashing = false
    $StartTimer.start()
    $HUD.update_score(score)
    $HUD.update_lives(lives)
    $HUD.show_message("Get Ready")

func _on_StartTimer_timeout():
    $MobTimer.start()
    $CoinTimer.start()

func _on_MobTimer_timeout():
    var mobs = get_tree().get_nodes_in_group("mobs")
    if mobs != null && mobs.size() < MAX_MOBS:
        # Choose a random location on Path2D.
        $MobPath/MobSpawnLocation.set_offset(randi())
        # Create a Mob instance and add it to the scene.
        var mob = Mob.instance()
        add_child(mob)
        # Set the mob's direction perpendicular to the path direction.
        var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
        # Set the mob's position to a random location.
        mob.position = $MobPath/MobSpawnLocation.position
        # Add some randomness to the direction.
        direction += rand_range(-PI / 4, PI / 4)
        mob.rotation = direction
        # Set the velocity (speed & direction).
        mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
        mob.linear_velocity = mob.linear_velocity.rotated(direction)
        $HUD.connect("start_game", mob, "_on_start_game")
        $MobTimer.wait_time = $MobTimer.wait_time * 0.95

func _on_Player_collectedCoin():
    $CoinSound.play()
    score = score + 1
    $HUD.update_score(score)
    if score >= WIN_TARGET:
        $Player/CollisionShape2D.set_deferred("disabled", true)
        $CoinTimer.stop()
        win()

func _on_CoinTimer_timeout():
    var coin = Coin.instance()
    $CoinAppearSound.play()
    add_child(coin)
    coin.position = Vector2(rand_range(10, 400), 0)
    $CoinTimer.wait_time = rand_range(3,6)
    $CoinTimer.start()

func win():
    for mobs in get_tree().get_nodes_in_group("mobs"):
        mobs.queue_free()
    
    $CoinAppearSound.stop()
    $WinSound.play()
    $Music.stop()
    $Player.hide()
    $MobTimer.stop()
    $HUD.show_win()
    