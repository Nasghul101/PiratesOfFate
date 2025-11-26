@tool
class_name TreasureChest
extends StaticBody3D

# --- Enums ---
enum ItemFillMode { RANDOM, SPECIFIED, SEMI_RANDOM }
enum {OPEN, CLOSE}

# --- Exported properties ---
var item_fill_mode: ItemFillMode = ItemFillMode.RANDOM:
    set(value):
        item_fill_mode = value
        if Engine.is_editor_hint():
            # Update Inspector dynamically when mode changes in editor
            notify_property_list_changed()

# Using Variant so the array can be dynamic in editor even without export hint
var items: Array[Weapon] = [] 

var looted:bool = false
var inRange:bool = false
var inventory:Inventory = Inventory.new()

@onready var animationPlayer := %AnimationPlayer
@onready var label := %Label3D

func _ready() -> void:
    if Engine.is_editor_hint():
        return  # skip editor processing
    label.visible = false
    
    match item_fill_mode:
        #ItemFillMode.RANDOM:
            #fill_random_items()
        ItemFillMode.SPECIFIED:
            fill_specified_items()
        ItemFillMode.SEMI_RANDOM:
            fill_semi_random_items()

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        return  # skip editor processing
        
    if Input.is_action_just_pressed("interaction") && !looted && inRange:
        label.visible = false
        play_animation(OPEN)

# --- Property list customization ---
func _get_property_list() -> Array[Dictionary]:
    var props: Array[Dictionary] = []

    # Always include fill_mode
    props.append({
        "name": "fill_mode",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "Random,Specified,Semi Random",
        "usage": PROPERTY_USAGE_DEFAULT,
        "hint_tooltip": "Determines how the chest fills items:\n - RANDOM: fills with random loot.\n - SPECIFIED: only chosen items.\n - SEMI_RANDOM: part chosen, part random."

    })

    # Only show items array for SPECIFIED or SEMI_RANDOM
    if item_fill_mode == ItemFillMode.SPECIFIED or item_fill_mode == ItemFillMode.SEMI_RANDOM:
        props.append({
            "name": "items",
            "type": TYPE_ARRAY,
            "hint_string": "Item",
            "usage": PROPERTY_USAGE_DEFAULT,
            "hint_tooltip": "List of specific items to include in the chest."
        })

    return props

# --- Property get/set for editor reflection ---
func _set(property: StringName, value: Variant) -> bool:
    match property:
        "fill_mode":
            item_fill_mode = value
            if Engine.is_editor_hint():
                notify_property_list_changed()
            return true
        "items":
            items = value
            return true
        _:
            return false

func _get(property: StringName) -> Variant:
    match property:
        "fill_mode":
            return item_fill_mode
        "items":
            return items
        _:
            return null

#func fill_random_items() -> void:
    #randomize()
    #var itemAmound:int = randi_range(1, 5)
    #for amound in itemAmound:
        #inventory.add_item()

func fill_specified_items() -> void:
    for i in items:
        inventory.add_item(i)
        
func fill_semi_random_items() -> void:
    pass

func play_animation(animation:int) -> void:
        match animation:
            OPEN:
                animationPlayer.play("Open")
            CLOSE:
                animationPlayer.play("Close")

func close_chest() -> void:
    play_animation(CLOSE)

func call_chest_opened() -> void:
        CustomSignalBus.chest_opened.emit(self, inventory)
    
func _on_area_3d_body_entered(body: Node3D) -> void:
    if "Player" in body.name && !looted:
        label.visible = true
        inRange = true


func _on_area_3d_body_exited(body: Node3D) -> void:
    if "Player" in body.name:
        label.visible = false
        inRange = false
