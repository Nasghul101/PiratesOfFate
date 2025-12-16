class_name DropOverlay
extends Control

signal drop_received(cell: DragDropCell)

func _ready() -> void:
    CustomSignalBus.connect("drag_started", enable)
    CustomSignalBus.connect("drag_released", disable)

func enable() -> void:
    visible = true


func disable() -> void:
    visible = false


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
    if data is DragDropCell:
        return true
    else:
        return false

func _drop_data(_pos: Vector2, data: Variant) -> void:
    disable()
    drop_received.emit(data)
