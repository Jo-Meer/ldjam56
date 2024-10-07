extends Control

func _ready() -> void:
	run_intro();

func run_intro():
	$ColorRect.visible = true;
	$Button.modulate = Color.TRANSPARENT;
	
	var fade_tween = create_tween();
	fade_tween.tween_property($ColorRect, "modulate", Color.TRANSPARENT, 2);
	await fade_tween.finished;
	await get_tree().create_timer(0.5).timeout;
	var tween = create_tween();
	tween.tween_property($Button, "modulate", Color.WHITE, 2);

func start_game():
	SceneManager.start()
