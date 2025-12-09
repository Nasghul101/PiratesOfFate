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
enum {IDLE,WALK,JUMP,ATTACK1,ATTACK2,ATTACK3}

# Inventory/Equipment
var inventory:Inventory = Inventory.new()
var equipment:Equipment = Equipment.new()

# Attack/Combo Implementation
var equippedWeapon: Weapon
var comboIndex: int = 0
var canContinueCombo: bool = false
var isAttacking: bool = false
var maxComboAttacks: int

@onready var cameraPivot: Node3D = %Camera_Pivot
@onready var camera: Camera3D = %Camera3D
@onready var animTree : AnimationTree = %AnimationTree
@onready var weaponAttachement : Node3D = %weapon_pos_offset

func _ready() -> void:
    inventory.add_item(startWeapon)
    CustomSignalBus.connect("update_player_inventory", update_player_inventory)
    CustomSignalBus.connect("equipped", on_equipped)
    
    #needs to be changed when implementing the equipment dialog
    equippedWeapon = startWeapon
    animTree.apply_weapon_animation_set(startWeapon)
    setup_weapon_combo(startWeapon)
    print("startWeapon equipmentSlot: " + startWeapon.equipmentSlot)
    
func _physics_process(delta: float) -> void:

    # -----------------------------#
    #       Camera controls        #
    # -----------------------------#
    cameraPivot.rotation.x += cameraInputDirection.y * delta
    cameraPivot.rotation.x = clamp(cameraPivot.rotation.x, -PI / 6.0, PI / 3.0)
    cameraPivot.rotation.y -= cameraInputDirection.x * delta
    cameraInputDirection = Vector2.ZERO

    # -----------------------------#
    #        Movement input        #
    # -----------------------------#
    var inputDir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var forward := camera.global_basis.z
    var right := camera.global_basis.x
    
    var moveDirection := forward * inputDir.y + right * inputDir.x
    moveDirection.y = 0.0
    moveDirection = moveDirection.normalized()
    
    # -----------------------------#
    # BLOCK MOVEMENT DURING ATTACK #
    # -----------------------------#
    if isAttacking:
        moveDirection = Vector3.ZERO   ### NEW (no movement)
        inputDir = Vector2.ZERO       ### NEW (no rotation influence)

    # -----------------------------#
    #       Velocity Handling      #
    # -----------------------------#
    var velocityY : float = velocity.y
    velocity.y = 0.0
    velocity = velocity.move_toward(moveDirection * moveSpeed, acceleration + delta)
    velocity.y = velocityY + gravity * delta

    # -----------------------------#
    #   BLOCK JUMP DURING ATTACK   #
    # -----------------------------#
    var isStartingJump : bool = Input.is_action_just_pressed("jump") and is_on_floor() and not isAttacking
    if isStartingJump:
        velocity.y += jumpImpulse

    move_and_slide()
    
    # -----------------------------#
    #           Rotation           #
    # -----------------------------#
    if moveDirection.length() > 0.2:
        lastMovementDirection = moveDirection

    var targetAngle := Vector3.BACK.signed_angle_to(lastMovementDirection, Vector3.UP)

    if not isAttacking:
        playerBody.global_rotation.y = lerp_angle(playerBody.rotation.y, targetAngle, rotationSpeed * delta)

    # -----------------------------#
    #       Animation State        #
    # -----------------------------#
    if not isAttacking:
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
        
    # -----------------------------#
    #            Inputs            #
    # -----------------------------#
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("inventory"):
        CustomSignalBus.inventory_opened.emit(inventory)
    if event.is_action_pressed("left_click") && Input.MOUSE_MODE_CAPTURED && is_on_floor():
        handle_attack_input()
    if event.is_action_pressed("right_click"):
        equipment.equip(startWeapon)

    # -----------------------------#
    #      Animation Setting       #
    # -----------------------------#
func set_current_anim(state : int) -> void:
    match state:
        IDLE:
            animTree.set_current_anim(IDLE)
        WALK:            
            animTree.set_current_anim(WALK)
        JUMP:
            animTree.set_current_anim(JUMP)
        ATTACK1:
            animTree.set_current_anim(ATTACK1)
        ATTACK2:
            animTree.set_current_anim(ATTACK2)
        ATTACK3:
            animTree.set_current_anim(ATTACK3)

    # -----------------------------#
    #        Item Management       #
    # -----------------------------#

#function to add or remove items from the player inventory
#connected to the Update_Player_Invetory signal
func update_player_inventory(item:Item, addItem:bool) -> void:
    if addItem:
        inventory.add_item(item)
    else:
        inventory.remove_item(item)
        

func on_equipped(item: Variant, slot: Equipment.Slot) -> void:
    update_player_inventory(item, false)
    print("Equipment: " + str(equipment.get_equipped_items()))
    print("Inventory: " + str(inventory.get_items()))
    

func on_unequipped(item: Variant, slot: Equipment.Slot) -> void:
    update_player_inventory(item, true)
    print("Equipment: " + str(equipment.get_equipped_items()))
    print("Inventory: " + str(inventory.get_items()))


    # -----------------------------#
    #  Attack and Combo Handling   #
    # -----------------------------#

# Called when attack button is pressed
func handle_attack_input() -> void:
    if canContinueCombo:
        continue_combo()

    if not isAttacking:
        start_combo()
        return

func start_combo() -> void:
    comboIndex = 0
    isAttacking = true
    canContinueCombo = false

    # Play the first attack
    set_current_anim(ATTACK1)


func continue_combo() -> void:
    comboIndex += 1

    if comboIndex >= maxComboAttacks:
        reset_combo()
        return

    canContinueCombo = false

    # Dynamically determine the ATTACK state to play
    match comboIndex:
        1:
            set_current_anim(ATTACK2)
        2:
            set_current_anim(ATTACK3)
        _:
            # For more than 3 attacks, dynamically call set_current_anim with integers above 3
            set_current_anim(comboIndex + 1)  # assumes your set_current_anim can handle >3 if needed


# Called by AnimationPlayer when attack animation finishes
func on_animation_finished() -> void:
    if not isAttacking:
        return

    reset_combo()

func reset_combo() -> void:
    isAttacking = false
    canContinueCombo = false
    comboIndex = 0
    animTree.set("parameters/attack/transition_request", "no_attack")

# Called by AnimationPlayer keyframes to open/close combo window
func set_canContinueCombo(value: bool) -> void:
    canContinueCombo = value

# Call this whenever you equip a weapon
func setup_weapon_combo(weapon: Weapon) -> void:
    maxComboAttacks = weapon.attackAnimations.size()
    print("Max Combo Attacks: " + str(maxComboAttacks))
    reset_combo()
