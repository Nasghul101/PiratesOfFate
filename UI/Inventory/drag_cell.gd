class_name DragDropCell
extends Button

func _get_drag_data(_pos: Vector2) -> Variant:
    if not icon:
        return null

    var preview := TextureRect.new()
    preview.texture = icon
    preview.stretch_mode = TextureRect.STRETCH_SCALE
    preview.scale = Vector2(0.1, 0.1)
    set_drag_preview(preview)

    CustomSignalBus.emit_signal("drag_started", self)
    return self

#to check if the drag ended
#https://www.reddit.com/r/godot/comments/17arb3h/how_to_detect_an_unsuccessful_drop_of_drag_data/
func _notification(what: int) -> void:
  if what == NOTIFICATION_DRAG_END:
    # Drag failed
    CustomSignalBus.emit_signal("drag_released", self)
