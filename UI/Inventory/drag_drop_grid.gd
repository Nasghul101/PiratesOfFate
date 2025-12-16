class_name DragDropGrid
extends GridContainer

signal cell_drag_started(cell: DragDropCell)
signal cell_drag_ended(cell: DragDropCell)

@export var cell_scene: PackedScene


func rebuild(items: Array[Item]) -> void:
    clear()
    #needs to wait 2 frames for the gridContainer to queue_free all children for consistency 
    await get_tree().process_frame 
    await get_tree().process_frame
    
    for item in items:
        add_item_to_free_cell(item)


func add_item_to_free_cell(item: Item) -> void:
    var cell : DragDropCell = _get_first_empty_cell()
    if cell == null:
        _add_row()
        cell = _get_first_empty_cell()

    cell.set_item(item)


func _add_row() -> void:
    for i in columns:
        var cell: DragDropCell = cell_scene.instantiate()
        add_child(cell)
        cell.owner = owner

        cell.drag_started.connect(_on_cell_drag_started)
        cell.drag_ended.connect(_on_cell_drag_ended)


func _on_cell_drag_started(cell: DragDropCell) -> void:
    cell_drag_started.emit(cell)


func _on_cell_drag_ended(cell: DragDropCell) -> void:
    cell_drag_ended.emit(cell)


func _get_first_empty_cell() -> DragDropCell:
    for child in get_children():
        if child is DragDropCell and child.cell_data == null:
            return child
    return null


func clear() -> void:
    for child in get_children():
        child.queue_free()
