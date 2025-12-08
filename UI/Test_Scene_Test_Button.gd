extends Button

var inventory:Inventory = Inventory.new()
@export var items: Array[Item] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for i in items:
        inventory.add_item(i)


func _on_pressed() -> void:
    CustomSignalBus.inventory_opened.emit(inventory)
