extends CanvasLayer

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# -----------------------------#
#  Escape Menu and UI Cancel   #
# -----------------------------#
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        var visibleChildren : int = 0
        #checks if there is at least one visible ui element
        for child in get_children():
            if child.visible:
                visibleChildren += 1
            child.visible = false
            
        #if no other ui element is visible either show EscapeMenu or hide it
        if %EscapeMenu.visible:
            %EscapeMenu.visible = false
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        elif visibleChildren > 0:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
        else:
            %EscapeMenu.visible = true
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
