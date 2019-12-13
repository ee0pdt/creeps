extends CanvasLayer

signal start_game

func show_message(text):
    $MessageLabel.text = text
    $MessageLabel.show()
    $MessageTimer.start()

func show_game_over():
    var coin_target = get_parent().WIN_TARGET;
    show_message("Game Over")
    yield($MessageTimer, "timeout")
    $MessageLabel.text = "Collect %s Coins" % coin_target
    $MessageLabel.show()
    yield(get_tree().create_timer(1), 'timeout')
    $StartButton.show()

func update_score(score):
    $ScoreLabel.text = str(score)

func update_lives(lives):
    if lives == 3:
        $Heart3.show()
        $Heart2.show()
        $Heart1.show()
    if lives < 3:
        $Heart3.hide()
    if lives < 2:
        $Heart2.hide()
    if lives < 1:
        $Heart1.hide()

func _on_StartButton_pressed():
    $StartButton.hide()
    emit_signal("start_game")

func _on_MessageTimer_timeout():
    $MessageLabel.hide()

func show_win():
    var coin_target = get_parent().WIN_TARGET;
    show_message("You won!")
    yield($MessageTimer, "timeout")
    $MessageLabel.text = "Collect %s Coins" % coin_target
    $MessageLabel.show()
    yield(get_tree().create_timer(1), 'timeout')
    $StartButton.show()
