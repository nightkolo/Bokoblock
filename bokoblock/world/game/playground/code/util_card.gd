## @experimental
extends CenterContainer
class_name TestUICard

@export var card_type: TestCardUI.CardType
@export_group("Assets")
@export var card_texture_remove: Texture = preload("res://assets/interface/card-ui-remove.png")
@export var card_texture_recolor_body: Texture = preload("res://assets/interface/card-ui-recolor-body.png")
@export var card_texture_recolor_block: Texture = preload("res://assets/interface/card-ui-recolor-block.png")

@onready var node_sprite: Node2D = $Node2D
@onready var sprite: Sprite2D = $Node2D/Texture

@onready var hover: Node2D = $Aud/Hover

@onready var audio_swich_down: AudioStreamPlayer2D = $Aud/Swiches/Down
@onready var audio_swich_down_2: AudioStreamPlayer2D = $Aud/Swiches/Down2

@onready var audio_swich_up: AudioStreamPlayer2D = $Aud/Swiches/Up


@onready var audio_select: AudioStreamPlayer2D = $Aud/Select/Select
@onready var audio_put_down: AudioStreamPlayer2D = $Aud/Select/PutDown

var _hover_sounds: Array[Node]

var is_highlighted: bool = false ## @experimental
var is_activate: bool = false: ## TODO: "is_activated"
	get:
		return is_activate
	set(value):
		if value:
			GameMgr.current_card_ui.set_card_type(card_type)
			if _tween_c:
				_tween_c.kill()
			modulate = Color(Color.WHITE/2)
			_tween_c = create_tween()
			_tween_c.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			_tween_c.tween_property(self,"modulate",Color(Color.WHITE*1.25),0.3)
			#modulate = Color(Color.WHITE*1.25)
		else:
			if _tween_c:
				_tween_c.kill()
			_tween_c = create_tween()
			_tween_c.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			_tween_c.tween_property(self,"modulate",Color(Color.WHITE),0.3)
			#modulate = Color(Color.WHITE)
		is_activate = value

var _texture_node_pos: float
var _tween_a: Tween
var _tween_b: Tween
var _tween_c: Tween
var _last_card_type: TestCardUI.CardType


func _ready() -> void:
	_texture_node_pos = node_sprite.position.y
	
	_hover_sounds = hover.get_children()
	
	match card_type:
		
		TestCardUI.CardType.Remove:
			sprite.texture = card_texture_remove
			
		TestCardUI.CardType.Recolor:
			sprite.texture = card_texture_recolor_body
			
		TestCardUI.CardType.Misc:
			sprite.texture = card_texture_recolor_block
	
	mouse_entered.connect(func():
		var aud := _hover_sounds[randi() % _hover_sounds.size()]
		aud.play(0.025)
		
		audio_swich_up.play() # thanks godot devs for making life so easy
		
		anim_entered()
		)
	mouse_exited.connect(func():
		anim_exited()
		
		await get_tree().create_timer(0.2).timeout
		audio_swich_down.play()
		
		print(_last_card_type == card_type)
		
		if !is_activate && _last_card_type == card_type:
			audio_swich_down_2.play(0.14)
		)
	
	gui_input.connect(func(event: InputEvent):
		if event.is_action_pressed("clicky"):
			is_activate = !is_activate
			print(is_activate)
			
			if is_activate:
				audio_select.play()
			else:
				_last_card_type = GameMgr.current_card_ui.current_card_type
				
				GameMgr.current_card_ui.set_card_type(TestCardUI.CardType.None)
				audio_put_down.play()
			
			anim_pressed()
		)
		
	await GameMgr.process_waittime()
	GameMgr.current_card_ui.card_type_set.connect(func(is_type: TestCardUI.CardType):
		if is_type != card_type:
			is_activate = false
		)
	

func anim_pressed() -> void:
	if _tween_b:
		_tween_b.kill()
		
	_tween_b = create_tween()
	_tween_b.set_ease(Tween.EASE_OUT)
	
	sprite.scale = Vector2(1.175,0.825)/2
	_tween_b.tween_property(sprite,"scale",Vector2.ONE/2,1.5).set_trans(Tween.TRANS_ELASTIC)


func anim_entered() -> void:
	var dur := 0.65
	var scale_to := 1.04
	var move_to := -30.0
	
	if _tween_a:
		_tween_a.kill()
		
	_tween_a = create_tween().set_parallel(true)
	_tween_a.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	node_sprite.scale = Vector2.ONE * 0.92
	node_sprite.position.y -= move_to
	
	_tween_a.tween_property(node_sprite,"position:y",_texture_node_pos+move_to,dur/4).set_trans(Tween.TRANS_BACK)
	_tween_a.tween_property(node_sprite,"scale:y",scale_to,dur)
	_tween_a.tween_property(node_sprite,"scale:x",scale_to,dur).set_delay(dur/13.33)
	
	
func anim_exited() -> void:
	var dur := 0.15
	
	if _tween_a:
		_tween_a.kill()
		
	_tween_a = create_tween()
	_tween_a.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	_tween_a.tween_property(node_sprite,"scale",Vector2.ONE,dur)
	_tween_a.tween_property(node_sprite,"position:y",_texture_node_pos,dur*2).set_delay(dur/4)
