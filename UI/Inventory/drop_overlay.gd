extends Control

@export var grid: GridContainer

#disable by default 
func _ready() -> void:
    CustomSignalBus.connect("drag_started", on_drag_started)
    CustomSignalBus.connect("drag_released", on_drag_released)
    visible = false

#enable if a cell is grapped
func on_drag_started(_cell: DragDropCell) -> void:
    visible = true

func on_drag_released(_cell: DragDropCell) -> void:
    visible = false

# When dragging over overlay
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    if data is DragDropCell:
        return true
    return false

# When dropping
func _drop_data(_at_position: Vector2, data: Variant) -> void:
    visible = false
    grid.receive_external_drop(data)
