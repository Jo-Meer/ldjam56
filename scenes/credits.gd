extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	do_credits();


func do_credits():
	$ColorRect.visible = true;
	$Button.modulate = Color.TRANSPARENT;
	$ENDTEXT.modulate = Color.TRANSPARENT;
	$SCROLLER.modulate = Color.TRANSPARENT;
	$Logo.modulate = Color.TRANSPARENT;
	
	var fade_tween = create_tween();
	fade_tween.tween_property($ColorRect, "modulate", Color.TRANSPARENT, 2);
	await fade_tween.finished;
	
	var endtext_tween = create_tween();
	$ENDTEXT.show();
	endtext_tween.tween_property($ENDTEXT, "modulate", Color.WHITE, 2);
	await endtext_tween.finished;
	
	await get_tree().create_timer(2).timeout;
	
	var button_tween = create_tween();
	button_tween.tween_property($Button, "modulate", Color.WHITE, 1);
	
	await get_tree().create_timer(1).timeout;
	
	var endtext_tween2 = create_tween();
	endtext_tween2.tween_property($ENDTEXT, "modulate", Color.TRANSPARENT, 2);
	await endtext_tween2.finished;
	
	var scoller_tween = create_tween();
	$SCROLLER.show();
	scoller_tween.tween_property($SCROLLER, "modulate", Color.WHITE, 2);
	await scoller_tween.finished;
	
	await get_tree().create_timer(2).timeout;
	
	var scoll_tween = create_tween();
	scoll_tween.tween_property($SCROLLER, "position", $SCROLLER.position - Vector2(0, 2400), 40);
	await scoll_tween.finished;
	
	$Logo.show();
	
	var logo_tween = create_tween();
	logo_tween.tween_property($Logo, "modulate", Color.WHITE, 2);
	await logo_tween.finished;


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenue.tscn");
