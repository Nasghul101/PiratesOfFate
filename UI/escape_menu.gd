extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    visible = false
    

func _on_resume_button_pressed() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    visible = false
    
func _on_options_button_pressed() -> void:
    pass # Replace with function body.


func _on_quit_button_pressed() -> void:
    pass # Replace with function body.
