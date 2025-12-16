class_name DragDropCell
extends Button

signal drag_started(cell: DragDropCell)
signal drag_ended(cell: DragDropCell)

var cell_data: Item = null


func set_item(item: Item) -> void:
    cell_data = item
    if item:
        icon = item.icon


func clear_item() -> void:
    cell_data = null
    icon = null


func _get_drag_data(_pos: Vector2) -> Variant:
    if cell_data == null:
        return null

    var preview := TextureRect.new()
    preview.texture = icon
    preview.stretch_mode = TextureRect.STRETCH_SCALE
    preview.scale = Vector2(0.1, 0.1)
    set_drag_preview(preview)

    drag_started.emit(self)
    return self


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        drag_ended.emit(self)
