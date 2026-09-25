extends Node3D
var GunName = "GunTemplate"
var Selected = false
@onready var player: CharacterBody3D = $"../../../.."
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Selected:
		visible = true
	if !Selected:
		visible = false
		


func _player_Attack(CurrentEquipped: Variant, EquippedStat: Variant) -> void:
	if CurrentEquipped == GunName:
		print("Bang")



func _on_player_weapon_swap(CurrentEquipped: Variant) -> void:
	if CurrentEquipped == GunName:
		Selected = true

	if CurrentEquipped != GunName:
		Selected = false
