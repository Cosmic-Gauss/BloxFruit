extends StaticBody3D

@onready var Collision: CollisionShape3D = $CollisionShape3D
@onready var Vis: MeshInstance3D = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func HitBoxCreation(Width,Hieght,Depth,Damage):
	scale.x = Width
	scale.y = Hieght
	scale.z = Depth
	
