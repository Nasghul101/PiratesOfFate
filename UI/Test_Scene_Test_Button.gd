extends Button

signal fill_inventory(inventory: Inventory)

var inventory:Inventory = Inventory.new()
@export var items: Array[Item] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    for i in items:
        inventory.add_item(i)
    #CustomSignalBus.connect("update_player_inventory", update_inventory)
    print(self.name + " inventory: " + str(inventory.get_items()))


func _on_pressed() -> void:
    #CustomSignalBus.inventory_opened.emit(inventory)
    fill_inventory.emit(inventory)

func update_inventory(item:Item, addItem:bool) -> void:
    if addItem:
        inventory.add_item(item)
        print("items added ")  
        for i in inventory.get_items():
            print(i.name)
    else:
        #inventory.remove_item(item)
        print("items removed ")
        for i in inventory.get_items():
            print(i.name)
