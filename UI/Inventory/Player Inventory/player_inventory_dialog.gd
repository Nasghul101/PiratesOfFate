class_name PlayerInventoryDialog
extends PanelContainer

signal inventory_changed(inventory: Inventory)

@export var grid: DragDropGrid
@export var drop_overlay: DropOverlay

var active_inventory: Inventory
var dragged_cell: DragDropCell = null


func _ready() -> void:
    grid.connect("cell_drag_started", _on_drag_started)
    grid.connect("cell_drag_ended", _on_drag_ended)
    drop_overlay.connect("drop_received", _on_drop_received)

    drop_overlay.disable()
    CustomSignalBus.connect("inventory_opened", open)

func open(inventory: Inventory) -> void:
    active_inventory = inventory
    show()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    grid.rebuild(active_inventory.get_items())


func _on_drag_started(cell: DragDropCell) -> void:
    dragged_cell = cell
    # used for the drag overlay to activate globally
    CustomSignalBus.drag_started.emit()


func _on_drag_ended(_cell: DragDropCell) -> void:
    dragged_cell = null
    # used for the drag overlay to activate globally
    CustomSignalBus.drag_released.emit()

func _on_drop_received(cell: DragDropCell) -> void:
    if cell == null or cell.cell_data == null:
        return

    var item := cell.cell_data

    # DATA mutation happens ONLY here
    active_inventory.remove_item(item)
    active_inventory.add_item(item)

    inventory_changed.emit(active_inventory)
    grid.rebuild(active_inventory.get_items())
    
    # clears the item from the dragged cell and out of the source inventory
    cell.clear_item()
    if not cell.owner.active_inventory == null && not cell.owner == self:
        cell.owner.active_inventory.remove_item(item)
        
    dragged_cell = null


func _on_close_button_pressed() -> void:
    hide()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
