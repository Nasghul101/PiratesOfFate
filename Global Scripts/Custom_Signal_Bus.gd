extends Node

#for opening the chest inventory dialog 
signal chest_opened(chestInventory:Inventory)

#opens player inventory when pressing the inventory key
signal inventory_opened(playerInventory:Inventory)

#called to add or remove items from the player inventory
signal update_player_inventory(item:Item, addItem:bool)

#emitted when a cell starts dragging, used for the drag overlay to activate globally
signal drag_started()

#emiited when a cell gets dropped, used for the drag overlay to activate globally
signal drag_released()

signal equipped(item: Variant, slot: Equipment.Slot)

signal unequipped(item: Variant, slot:  Equipment.Slot)
