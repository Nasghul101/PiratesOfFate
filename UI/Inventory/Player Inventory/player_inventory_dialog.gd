class_name PlayerInventoryDialog
extends PanelContainer

@export var slotScene:PackedScene

@onready var gridContainer:GridContainer = %GridContainer

func _ready() -> void:
    CustomSignalBus.connect("inventory_opened", open)

func open(inventory:Inventory) -> void:
    show()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
    for child in gridContainer.get_children():
        child.queue_free()
    
    for item in inventory.get_items():
        var slot := slotScene.instantiate()
        gridContainer.add_child(slot)
        slot.display(item)

func _on_close_button_pressed() -> void:
    hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
