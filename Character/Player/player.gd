extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouseSensitivity := 0.25

@export_group("Movement")
@export var moveSpeed := 8.0
@export var acceleration := 20.0
@export var rotationSpeed := 12.0
@export var jumpImpulse := 8.0

@export_group("")
@export var playerBody: Node3D
@export var startWeapon: Weapon

var cameraInputDirection := Vector2.ZERO
var lastMovementDirection := Vector3.BACK
var gravity := -9.81
enum {IDLE,WALK,JUMP,ATTACK}
var inventory:Inventory = Inventory.new()

#AttackComboImplementation
var equippedWeapon: Weapon
var combo_index: int = 0
var can_continue_combo: bool = false
var is_attacking: bool = false


@onready var cameraPivot: Node3D = %Camera_Pivot
@onready var camera: Camera3D = %Camera3D
@onready var anim_tree : AnimationTree = %AnimationTree

func _ready() -> void:
    inventory.add_item(startWeapon)
    CustomSignalBus.connect("update_player_inventory", update_player_inventory)
    equippedWeapon = startWeapon

func _physics_process(delta: float) -> void:
    
    #Camera Controls
    cameraPivot.rotation.x += cameraInputDirection.y * delta
    cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI / 6.0, PI / 3.0)
    cameraPivot.rotation.y -= cameraInputDirection.x * delta
    cameraInputDirection = Vector2.ZERO
    
    # Get the input direction and handle the movement/deceleration.
    var inputDir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var forward := camera.global_basis.z
    var right := camera.global_basis.x
    
    var moveDirection := forward * inputDir.y + right * inputDir.x
    moveDirection.y = 0.0
    moveDirection = moveDirection.normalized()
    
    var velocityY := velocity.y
    velocity.y = 0.0
    velocity = velocity.move_toward(moveDirection * moveSpeed, acceleration + delta)
    velocity.y = velocityY + gravity * delta
    
    var isStartingJump := Input.is_action_just_pressed("jump") and is_on_floor()
    if isStartingJump:
        velocity.y += jumpImpulse
    
    move_and_slide()
    
    if moveDirection.length() > 0.2:
        lastMovementDirection = moveDirection
    var targetAngle := Vector3.BACK.signed_angle_to(lastMovementDirection, Vector3.UP)
    playerBody.global_rotation.y = lerp_angle(playerBody.rotation.y, targetAngle, rotationSpeed * delta)
    
    if not is_on_floor():
            set_current_anim(JUMP)
    elif is_on_floor():
        var groundSpeed := velocity.length()
        if groundSpeed > 0.0:
            set_current_anim(WALK)
        else:
            set_current_anim(IDLE)

    
func _unhandled_input(event: InputEvent) -> void:
    var isCameraMotion := (
        event is InputEventMouseMotion and 
        Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
    )
    if isCameraMotion:
        cameraInputDirection = event.screen_relative * mouseSensitivity

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("left_click"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event.is_action_pressed("inventory"):
        CustomSignalBus.inventory_opened.emit(inventory)
    if event.is_action_pressed("left_click") && Input.MOUSE_MODE_CAPTURED:
        pass

        
func set_current_anim(state : int) -> void:
    match state:
        IDLE:
            anim_tree.set_current_anim(IDLE)
        WALK:            
            anim_tree.set_current_anim(WALK)
        JUMP:
            anim_tree.set_current_anim(JUMP)
        
#function to add or remove items from the player inventory
#connected to the Update_Player_Invetory signal
func update_player_inventory(item:Item, addItem:bool) -> void:
    if addItem:
        inventory.add_item(item)
    else:
        inventory.remove_item(item)
        

#-----------------------------#
#  Attack and Combo Handling  #
#-----------------------------#

#func handle_attack_input() -> void:
    #if is_attacking:
        ## Already attacking → only continue if allowed
        #if can_continue_combo:
            #continue_combo()
        ## Else ignore the press
        #return
#
    ## Not attacking → start from first attack
    #start_combo()
#
#func start_combo() -> void:
    #if equippedWeapon == null:
        #return
#
    #combo_index = 0
    #play_combo_animation()
    #is_attacking = true
#
#
#func continue_combo() -> void:
    ## Advance combo only if next animation exists
    #combo_index += 1
#
    #if combo_index >= equippedWeapon.attack_animations.size():
        ## Combo finished; reset
        #combo_index = 0
        #return
#
    ## Play next attack animation
    #can_continue_combo = false
    #play_combo_animation()
#
#func play_combo_animation() -> void:
    ## Get animation name from weapon resource
    #var anim_name = equippedWeapon.attackAnimations[combo_index]
#
    ## Assign this animation to correct BlendTree input
    #anim_tree.set("parameters/attack" + str(combo_index + 1) + "/animation", anim_name)
#
    ## Select the correct attack animation in BlendTree
    #anim_tree.set("parameters/attack_combo_selector/blend_position", combo_index)
#
#func on_animation_finished(anim_name: String) -> void:
    ## If the finished animation isn’t part of the combo → ignore
    #if not is_attacking:
        #return
#
    ## Combo ended without continuing
    #reset_combo()
#
#
#func reset_combo() -> void:
    #is_attacking = false
    #can_continue_combo = false
    #combo_index = 0
#
#
## Called from AnimationPlayer keyframe (your method)
#func allow_next_attack_window() -> void:
    ## This is your "can attack" timeframe
    #can_continue_combo = true
