class_name ChestInventoryDialog
extends PanelContainer

var currentChest:TreasureChest
var temporalInventory:Inventory

@onready var gridContainer:GridContainer = %GridContainer

func _ready() -> void:
    CustomSignalBus.connect("chest_opened", open)

func open(chest:TreasureChest, inventory:Inventory) -> void:
    temporalInventory = inventory
    show()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    gridContainer.clear()
    
    #needs to wait 2 frames for the gridContainer to queue_free all children for consistency
    await get_tree().process_frame
    await get_tree().process_frame
    
    
    for item in inventory.get_items():
        gridContainer.add_new_item(item)

    
    currentChest = chest

func _on_close_button_pressed() -> void:
    hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    currentChest.close_chest()

func _on_take_all_button_pressed() -> void:
    hide()
    if currentChest:
        for item in temporalInventory.get_items():
            currentChest.inventory.remove_item(item)
            CustomSignalBus.update_player_inventory.emit(item, true)
        currentChest.looted = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
