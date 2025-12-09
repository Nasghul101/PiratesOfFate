class_name Weapon
extends Item

@export_group("Animations")
@export_subgroup("Idle, Jump, Walk")
@export var idleAnimation:String
@export var jumpAnimation:String
@export var walkAnimation:String
@export_subgroup("Attack")
@export var attackAnimations:Array[String] = []  

@export_group("Stats")
@export var attackDamage:int
@export_enum("HAND") var equipmentSlot: String
