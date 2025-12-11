class_name Equipment
extends Node

# --------------------------#
#  ENUM OF EQUIPMENT SLOTS  #
# --------------------------#
enum Slot {
    HEAD,
    TORSO,
    LEGS,
    HAND,
    ARM,
    ACCESSORY
}

# -------------------------#
# CURRENTLY EQUIPPED ITEMS #
# -------------------------#
var slots : Dictionary[Slot, Variant] = {
    Slot.HEAD: null,
    Slot.TORSO: null,
    Slot.LEGS: null,
    Slot.HAND: null,
    Slot.ARM: null,
    Slot.ACCESSORY: null
}

func equip(item: Variant) -> void:
    if item == null:
        return

    # Only items with equipmentSlot can be equipped
    if not ("equipmentSlot" in item):
        return

    var validSlot := find_valid_slot(item)
    if validSlot == -1:
        return

    equip_to_slot(item, validSlot)


func equip_to_slot(item: Variant, slot: Slot) -> void:
    if not slots.has(slot):
        return

    if not ("equipmentSlot" in item):
        return

    var itemSlot := slot_from_string(item.equipmentSlot)
    if itemSlot != slot:
        return

    var oldItem: Variant = slots[slot]

    # remove old item
    if oldItem:
        CustomSignalBus.emit_signal("unequipped", oldItem, slot)

    # insert new item
    slots[slot] = item
    CustomSignalBus.emit_signal("equipped", item, slot)


func unequip(slot: Slot) -> Variant:
    if not slots.has(slot):
        return null

    var item: Variant = slots[slot]
    if item:
        slots[slot] = null
        CustomSignalBus.emit_signal("unequipped", item, slot)
        return item

    return null

func get_equipped_items() -> Dictionary:
    return slots.duplicate()

# Convert string → enum safely
func slot_from_string(slotName: String) -> int:
    # Normalize: allow lowercase input like "head"
    slotName = slotName.to_upper()

    # Check if enum contains it
    if Slot.has(slotName):
        return Slot[slotName]

    return -1


# Find the one allowed slot for an item
func find_valid_slot(item: Variant) -> int:
    var slotName: Variant = item.equipmentSlot          # string, e.g. "HEAD"
    var slotEnum := slot_from_string(slotName) # int or -1

    if slotEnum != -1 and slots.has(slotEnum):
        return slotEnum

    return -1
