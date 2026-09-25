extends CharacterBody3D
@onready var Hitbox = preload("res://Scenes/HitBoxTest.tscn")

@export_group("Camera")
@export_range(0.1,1.0) var mouse_sens := 0.25

@export_group("Movement")
@export var Move_speed := 8.0
@export var Acceleration := 20.0
@export var rotation_speed = 12

@export_group("Stats")
@export var health := 100
@export var energy := 100
@export var level := 0
@export var experience := 0
@export var MeleeDmg := 1
@export var FruitDmg := 1
@export var SwordDmg := 1
@export var GunDmg := 1
@export var SelectedTool = "Melee" #The Current Object you are using

@export_group("SelectedWeapons")
@export var FightingStyle = "Basic" 
@export var Fruit = "NoFruit"
@export var Sword = "SwordTemplate"
@export var Gun = "GunTemplate"
@export var CurrentEquipped = "Basic" # Current equipped specific item
@export var EquippedStat = 1
@export var WeaponSwapCd = false

@export_group("StatBolean")
@export var Attacking = false
@export var Dashing = false
@export var Stunned = false
@export var MovementLock = false
@export var Menu = false

signal AttackInfo(CurrentEquipped, EquippedStat)
signal WeaponSwap(CurrentEquipped)


var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK

@onready var Pivot: Node3D = %CamOrigin
@onready var Camera: Camera3D = %Camera3D
@onready var body: MeshInstance3D = %Body

func _input(event: InputEvent):
	
	if event.is_action_pressed("LeftClick"):
		if !Attacking and !Stunned and !Menu:
			emit_signal("AttackInfo", CurrentEquipped, EquippedStat)
	if event.is_action_pressed("ui_cancel"):
		Menu = !Menu

	
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sens
		
func _physics_process(delta: float) -> void:
	if Menu:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if !Menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	if SelectedTool == "Melee":
		CurrentEquipped = FightingStyle
		EquippedStat = MeleeDmg
		
	if SelectedTool == "Fruit":
		CurrentEquipped = Fruit
		EquippedStat = FruitDmg
		
	if SelectedTool == "Sword":
		CurrentEquipped = Sword
		EquippedStat = SwordDmg
		
	if SelectedTool == "Gun":
		CurrentEquipped = Gun
		EquippedStat = GunDmg


	if Input.is_action_just_pressed("SwapLeft") and !WeaponSwapCd: # swaps weapons going Melee, Gun, Sword, Fruit and then Melee
	
		WeaponSwapCd = true
		
		if SelectedTool == "Melee" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Gun"
			
		if SelectedTool == "Gun" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Sword"
			
		if SelectedTool == "Sword"and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Fruit"
			
		if SelectedTool == "Fruit" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Melee"

		await get_tree().create_timer(0.1).timeout
		emit_signal("WeaponSwap",CurrentEquipped)
			
	if Input.is_action_just_pressed("SwapRight") and !WeaponSwapCd: # swaps weapons going Melee, Fruit, Sword, Gun and then Melee
		WeaponSwapCd = true
		
		if SelectedTool == "Melee" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Fruit"

			
		if SelectedTool == "Fruit" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Sword"

		if SelectedTool == "Sword" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Gun"

		if SelectedTool == "Gun" and WeaponSwapCd:
			WeaponSwapCd = false
			SelectedTool = "Melee"

		await get_tree().create_timer(0.1).timeout
		emit_signal("WeaponSwap",CurrentEquipped)
		
	if Input.is_action_just_pressed("Dash"):
		if energy >= 0 and !Attacking and !Dashing and !Stunned and !MovementLock:
			Dashing = true
			Move_speed += 10
			await get_tree().create_timer(0.2).timeout
			Move_speed -= 10
			Dashing = false
			
	Pivot.rotation.x -= _camera_input_direction.y * delta
	Pivot.rotation.x = clamp(Pivot.rotation.x,-PI / 6.0, PI /3.0)
	Pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Back")
	var forward := Camera.global_basis.z
	var right := Camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	
	move_direction = move_direction.normalized()
	
	if !Stunned and !Attacking and !MovementLock and !Menu:
		velocity = velocity.move_toward(move_direction * Move_speed, Acceleration * delta)
		move_and_slide()
		
	if !Stunned and !Attacking and !MovementLock and !Menu:
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		body.global_rotation.y = lerp(body.rotation.y, target_angle, rotation_speed*delta)

func CreateHitbox():
	var AttackHitbox = Hitbox.instantiate()
	add_child(AttackHitbox)
