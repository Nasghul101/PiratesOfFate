extends AnimationTree

enum {IDLE, WALK,JUMP}
var walk_val : float = 0
var jump_val : float = 0
var current_anim : int = IDLE
@export var anim_blend_speed : float = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self["parameters/Walk/blend_amount"] = 0
    self["parameters/Jump/blend_amount"] = 0

func _physics_process(delta : float) -> void:
    handle_animations(delta)

func set_current_anim(anim: int) -> void:
    current_anim = anim
    
func handle_animations(delta:float) -> void:
    match current_anim:
        IDLE:
            walk_val = lerpf(walk_val,0,anim_blend_speed*delta)
            jump_val = lerpf(jump_val,0,anim_blend_speed*delta)
            
        WALK:
            walk_val = lerpf(walk_val,1,anim_blend_speed*delta)
            jump_val = lerpf(jump_val,0,anim_blend_speed*delta)
        JUMP:
            walk_val = lerpf(walk_val,0,anim_blend_speed*delta)            
            jump_val = lerpf(jump_val,1,anim_blend_speed*delta)
    update_anim_tree()

func update_anim_tree() -> void:
    self["parameters/Walk/blend_amount"] = walk_val
    self["parameters/Jump/blend_amount"] = jump_val
