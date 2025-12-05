class_name DragDropGrid
extends GridContainer

@export var cell_scene: PackedScene   # assign drag_drop_cell.tscn in Inspector

var cells: Array[DragDropCell] = []   # flat array instead of 2D (much easier)

func _ready() -> void:
    # Convert existing children into cells array and connect their drag_started
    for child in get_children():
        if child is DragDropCell:
            cells.append(child)

func receive_external_drop(data: DragDropCell) -> void:
    if data == null:
        return

    var icon_tex := data.icon
    if icon_tex == null:
        return

    # remove from old slot
    data.icon = null

    # find free cell
    var cell := get_first_empty_cell()
    if cell == null:
        add_new_row()
        cell = get_first_empty_cell()

    # drop item
    cell.icon = icon_tex


func get_first_empty_cell() -> DragDropCell:
    for cell in cells:
        if cell.icon == null:
            return cell
    return null

func add_new_row() -> void:
    for i in range(columns):
        var new_cell: DragDropCell = cell_scene.instantiate()
        add_child(new_cell)
        cells.append(new_cell)
