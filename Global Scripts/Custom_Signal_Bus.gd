extends Node

#for opening the chest inventory dialog 
signal chest_opened(chestInventory:Inventory)

#opens player inventory when pressing the inventory key
signal inventory_opened(playerInventory:Inventory)

#called to add or remove items from the player inventory
signal update_player_inventory(item:Item, addItem:bool)
