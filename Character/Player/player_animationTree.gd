extends AnimationTree

enum {IDLE, WALK,JUMP,ATTACK1,ATTACK2,ATTACK3}
var walkVal : float = 0
var jumpVal : float = 0
var currentAnim : int = IDLE

@export var anim_blend_speed : float = 15
@export var anim_player_node: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    self["parameters/Walk/blend_amount"] = 0
    self["parameters/Jump/blend_amount"] = 0

func _physics_process(delta : float) -> void:
    handle_animations(delta)

func set_current_anim(anim: int) -> void:
    currentAnim = anim
    
func handle_animations(delta:float) -> void:
    match currentAnim:
        IDLE:
            walkVal = lerpf(walkVal,0,anim_blend_speed*delta)
            jumpVal = lerpf(jumpVal,0,anim_blend_speed*delta)
            
            
        WALK:
            walkVal = lerpf(walkVal,1,anim_blend_speed*delta)
            jumpVal = lerpf(jumpVal,0,anim_blend_speed*delta)
        JUMP:
            walkVal = lerpf(walkVal,0,anim_blend_speed*delta)            
            jumpVal = lerpf(jumpVal,1,anim_blend_speed*delta)
        ATTACK1:
            self.set("parameters/attack/transition_request", "attack1")
        ATTACK2:
            self.set("parameters/attack/transition_request", "attack2")
        ATTACK3:
            self.set("parameters/attack/transition_request", "attack3")
    update_anim_tree()

func update_anim_tree() -> void:
    self["parameters/Walk/blend_amount"] = walkVal
    self["parameters/Jump/blend_amount"] = jumpVal

func apply_weapon_animation_set(weapon: Weapon) -> void:
    var animTreeRoot: AnimationNodeBlendTree = self.get("tree_root")

    # --- IDLE ---
    if weapon.idle_animation != "" and animTreeRoot.has_node("Anim_Idle"):
        var idle_node: AnimationNode = animTreeRoot.get_node("Anim_Idle")
        if anim_player_node.has_animation(weapon.idle_animation):
            idle_node.animation = weapon.idle_animation
            print("Idle: " + idle_node.animation)

    # --- WALK ---
    if weapon.walk_animation != "" and animTreeRoot.has_node("Anim_Walking"):
        var walk_node: AnimationNode = animTreeRoot.get_node("Anim_Walking")
        if anim_player_node.has_animation(weapon.walk_animation):
            walk_node.animation = weapon.walk_animation
            print("walk: " + walk_node.animation)

    # --- JUMP ---
    if weapon.jump_animation != "" and animTreeRoot.has_node("Anim_Jump"):
        var jump_node: AnimationNode = animTreeRoot.get_node("Anim_Jump")
        if anim_player_node.has_animation(weapon.jump_animation):
            jump_node.animation = weapon.jump_animation
            print("Jump: " + jump_node.animation)

    # --- ATTACKS ---
    for i in weapon.attackAnimations.size():
        var anim_name: String = weapon.attackAnimations[i]

        if anim_name == "":
            continue  # skip empty entries

        var node_name: String = "Anim_Attack" + str(i + 1)

        if not animTreeRoot.has_node(node_name):
            continue  # no such attack slot → ignore safely

        if anim_player_node.has_animation(anim_name):
            var attack_node: AnimationNode = animTreeRoot.get_node(node_name)
            attack_node.animation = anim_name
            print("attack"+ str(i + 1) + ": " + attack_node.animation)
