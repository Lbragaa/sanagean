extends Node2D

#Texture
const PLAYER_ALIVE_TEXTURE = preload("res://assets/characters/Sexo2_player.png")
const PLAYER_DEAD_TEXTURE = preload("res://assets/characters/heroicaido.png")
const ENEMY_ALIVE_TEXTURE = preload("res://assets/characters/Sexo2_enemy.png")
const ENEMY_DEAD_TEXTURE = preload("res://assets/characters/enemy_cuiado.png")

const PLAYER_ATTACK_DAMAGE := 3
const ENEMY_ATTACK_DAMAGE := 3
const GUARDED_DAMAGE := 1
const STARTING_HP := 10
const STARTING_MANA := 10
const FIREBAll_DAMAGE := 5
const FIREBALL_MANA_COST := 2

var player_hp: int = STARTING_HP
var enemy_hp: int = 10
var player_guarding: bool = false
var battle_over: bool = false
var player_mana: int = 10

@onready var player_hp_label = $UI/PlayerHPLabel
@onready var enemy_hp_label = $UI/EnemyHPLabel
@onready var status_label = $UI/StatusLabel
@onready var mana_label = $UI/ManaLabel
@onready var attack_button = $UI/AttackButton
@onready var guard_button = $UI/GuardButton
@onready var reset_button = $UI/ResetButton
@onready var skill_button = $UI/SkillButton
@onready var player_sprite = $UI/PlayerSprite
@onready var enemy_sprite = $UI/EnemySprite
@onready var fireball_sprite = $UI/FireballSprite

# Functions to change the current sprite texture
func set_player_alive() -> void:
	player_sprite.texture = PLAYER_ALIVE_TEXTURE

func set_player_dead() -> void:
	player_sprite.texture = PLAYER_DEAD_TEXTURE

func set_enemy_alive() -> void:
	enemy_sprite.texture = ENEMY_ALIVE_TEXTURE

func set_enemy_dead() -> void:
	enemy_sprite.texture = ENEMY_DEAD_TEXTURE

func _ready() -> void:
	reset_battle()

func update_ui() -> void:
	player_hp_label.text = "Player HP: " + str(player_hp)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
	mana_label.text = "Mana: " + str(player_mana)

func player_attack() -> void:
	if battle_over:
		return

	enemy_hp -= PLAYER_ATTACK_DAMAGE
	enemy_hp = max(enemy_hp, 0)

	status_label.text = "You attacked!"
	update_ui()

	if enemy_hp <= 0:
		set_enemy_dead()
		end_battle("Victory!")
		
		return

	enemy_turn()
	
func player_skill_fireball() -> void:
	
	if battle_over:
		return
		
	if player_mana < 2:
		status_label.text = "You don't have enough mana!"
		return
	
	#Skill went through
	enemy_hp -= FIREBAll_DAMAGE
	enemy_hp = max(enemy_hp, 0)
	player_mana -= FIREBALL_MANA_COST
	
	status_label.text = "You used your skill!"
	
	update_ui()
	
	#Await, espera acabar a funcao ai blabla
	await play_fireball_animation()
	
	if enemy_hp <= 0:
		set_enemy_dead()
		end_battle("Blazing Victory!")
		
		return
	
func play_fireball_animation() -> void:
	fireball_sprite.visible = true
	fireball_sprite.global_position = player_sprite.global_position

	var tween = create_tween()
	tween.tween_property(fireball_sprite, "global_position", enemy_sprite.global_position, 0.8)

	await tween.finished
	fireball_sprite.visible = false

func player_guard() -> void:
	if battle_over:
		return

	player_guarding = true
	status_label.text = "You guarded!"
	enemy_turn()

func enemy_turn() -> void:
	if battle_over:
		return

	var damage: int = ENEMY_ATTACK_DAMAGE

	if player_guarding:
		damage = GUARDED_DAMAGE
		player_guarding = false

	player_hp -= damage
	player_hp = max(player_hp, 0)

	status_label.text = "Enemy attacked for " + str(damage) + " damage!"
	update_ui()

	if player_hp <= 0:
		
		set_player_dead()
		end_battle("Defeat!")
		return

	status_label.text = "Player Turn"

func end_battle(result_text: String) -> void:
	battle_over = true
	status_label.text = result_text
	attack_button.disabled = true
	guard_button.disabled = true
	skill_button.disabled = true

func reset_battle() -> void:
	player_hp = STARTING_HP
	enemy_hp = 10
	player_mana = STARTING_MANA
	
	player_guarding = false
	battle_over = false

	status_label.text = "Player Turn"
	attack_button.disabled = false
	guard_button.disabled = false
	skill_button.disabled = false
	fireball_sprite.visible = false
	
	
	set_player_alive()
	set_enemy_alive()
	
	update_ui()

func _on_attack_button_pressed() -> void:
	print("Attack button pressed")
	player_attack()

func _on_guard_button_pressed() -> void:
	print("Guard button pressed")
	player_guard()

func _on_reset_button_pressed() -> void:
	reset_battle()
	
func _on_skill_button_pressed() -> void:
	player_skill_fireball()
