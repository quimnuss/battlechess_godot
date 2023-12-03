extends Object

class_name Set

var elements : Array[Variant] = [] : get = get_elements

var _dict := {}


func _init(elems: Array[Variant] = []) -> void:
    add_all(elems)


func add(el) -> void:
    _dict[el] = el


func add_all(elems: Array[Variant]) -> void:
    for el in elems:
        add(el)


func get_elements() -> Array[Variant]:
    return _dict.values()
