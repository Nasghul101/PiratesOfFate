extends PanelContainer

@onready var textureRect:TextureRect = %TextureRect

func display(item:Item) -> void:
    textureRect.texture = item.icon
