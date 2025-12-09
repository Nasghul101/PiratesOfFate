extends AnimationTree

enum {IDLE, WALK,JUMP,ATTACK1,ATTACK2,ATTACK3}
var walkVal : float = 0
var jumpVal : float = 0
var currentAnim : int = IDLE

@export var animBlendSpeed : float = 15
@export var animPlayerNode: AnimationPlayer

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
            walkVal = lerpf(walkVal,0,animBlendSpeed*delta)
            jumpVal = lerpf(jumpVal,0,animBlendSpeed*delta)
            
            
        WALK:
            walkVal = lerpf(walkVal,1,animBlendSpeed*delta)
            jumpVal = lerpf(jumpVal,0,animBlendSpeed*delta)
        JUMP:
            walkVal = lerpf(walkVal,0,animBlendSpeed*delta)            
            jumpVal = lerpf(jumpVal,1,animBlendSpeed*delta)
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
    if weapon.idleAnimation != "" and animTreeRoot.has_node("Anim_Idle"):
        var idle_node: AnimationNode = animTreeRoot.get_node("Anim_Idle")
        if animPlayerNode.has_animation(weapon.idleAnimation):
            idle_node.animation = weapon.idleAnimation
            print("Idle: " + idle_node.animation)

    # --- WALK ---
    if weapon.walkAnimation != "" and animTreeRoot.has_node("Anim_Walking"):
        var walk_node: AnimationNode = animTreeRoot.get_node("Anim_Walking")
        if animPlayerNode.has_animation(weapon.walkAnimation):
            walk_node.animation = weapon.walkAnimation
            print("walk: " + walk_node.animation)

    # --- JUMP ---
    if weapon.jumpAnimation != "" and animTreeRoot.has_node("Anim_Jump"):
        var jump_node: AnimationNode = animTreeRoot.get_node("Anim_Jump")
        if animPlayerNode.has_animation(weapon.jumpAnimation):
            jump_node.animation = weapon.jumpAnimation
            print("Jump: " + jump_node.animation)

    # --- ATTACKS ---
    for i in weapon.attackAnimations.size():
        var animName: String = weapon.attackAnimations[i]

        if animName == "":
            continue  # skip empty entries

        var nodeName: String = "Anim_Attack" + str(i + 1)

        if not animTreeRoot.has_node(nodeName):
            continue  # no such attack slot → ignore safely

        if animPlayerNode.has_animation(animName):
            var attackNode: AnimationNode = animTreeRoot.get_node(nodeName)
            attackNode.animation = animName
            print("attack"+ str(i + 1) + ": " + attackNode.animation)
