class_name DragDropGrid
extends GridContainer

@export var cell_scene: PackedScene   # assign drag_drop_cell.tscn in Inspector


func receive_external_drop(dragDropCell: DragDropCell) -> void:
    if dragDropCell == null:
        return

    var cellData : Item = dragDropCell.cellData
    if cellData == null:
        return

    # remove from old slot
    dragDropCell.remove_data()
    add_new_item(cellData)

func add_new_item(cellData: Item) ->void:
    
    # find free cell
    var emptyCell := get_first_empty_cell()
    if emptyCell == null:
        add_new_row()
        emptyCell = get_first_empty_cell()

    # drop item
    emptyCell.add_data(cellData)

func get_first_empty_cell() -> DragDropCell:
    for cell in get_children():
        if cell:
            if cell.icon == null:
                return cell
    return null

func add_new_row() -> void:
    for i in range(columns):
        var new_cell: DragDropCell = cell_scene.instantiate()
        add_child(new_cell)

func clear() -> void:
    for child in get_children():
        child.queue_free()
