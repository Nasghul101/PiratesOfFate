class_name Weapon
extends Item

@export_group("Animations")
@export_subgroup("Idle, Jump, Walk")
@export var idle_animation:String
@export var jump_animation:String
@export var walk_animation:String
@export_subgroup("Attack")
@export var attackAnimations:Array[String] = []  
