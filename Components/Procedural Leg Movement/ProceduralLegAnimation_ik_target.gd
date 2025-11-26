extends Marker3D

@export var stepTarget: Node3D
@export var stepDistance: float = 3.0

@export var adjacentTarget : Node3D

var isStepping : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if !isStepping && !adjacentTarget.isStepping && abs(global_position.distance_to(stepTarget.global_position)) > stepDistance:
        step()
    
    
func step() -> void:
    var targetPos : Vector3 = stepTarget.global_position
    var halfWay : Vector3 = (global_position + stepTarget.global_position) / 2
    isStepping = true
    
    var tween := get_tree().create_tween()
    tween.tween_property(self, "global_position", halfWay + owner.basis.y, 0.1)
    tween.tween_property(self, "global_position", targetPos, 0.1)
    tween.tween_callback(func() -> void: isStepping = false)
    
