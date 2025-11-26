class_name Inventory

var content:Array[Item] = []


func add_item(item:Item) -> void:
    content.append(item)
    
func remove_item(item:Item) -> void:
    content.erase(item)
    
func get_items() -> Array[Item]:
    return content
    
    
