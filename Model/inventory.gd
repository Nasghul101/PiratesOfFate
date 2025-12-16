class_name Inventory
extends Resource

## Emitted when an item is successfully added
signal item_added(item: Item)

## Emitted when an item is removed
signal item_removed(item: Item)

## Emitted when add_item fails because item already exists
signal item_already_present(item: Item)

var content: Array[Item] = []


func add_item(item: Item) -> bool:
    if item == null:
        return false

    # no duplicates allowed
    if content.has(item):
        item_already_present.emit(item)
        return false

    content.append(item)
    item_added.emit(item)
    return true

func remove_item(item: Item) -> bool:
    if not content.has(item):
        return false

    content.erase(item)
    item_removed.emit(item)
    return true


func get_items() -> Array[Item]:
    # Return a copy to protect internal state
    return content.duplicate()
