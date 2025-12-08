class_name PlayerInventoryDialog
extends PanelContainer

@onready var gridContainer:DragDropGrid = %GridContainer

func _ready() -> void:
    CustomSignalBus.connect("inventory_opened", open)

func open(inventory:Inventory) -> void:
    show()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    gridContainer.clear()
    
    #needs to wait 2 frames for the gridContainer to queue_free all children for consistency
    await get_tree().process_frame
    await get_tree().process_frame
    
    
    for item in inventory.get_items():
        gridContainer.add_new_item(item)

func _on_close_button_pressed() -> void:
    hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    

func _on_drop_overlay_drop_received(data: Variant) -> void:
    gridContainer.receive_external_drop(data)
