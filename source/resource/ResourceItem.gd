class_name ResourceItem
extends Resource

export var item_name : String = ""
export var description : String = ""

export var mesh : Mesh
export var sprite : Texture #gui sprite only

export var amount = 1 #amount on first acquirement
export var max_amount = 0 #0 is for infinite stacks
export var stackable : bool
export var depletable : bool
