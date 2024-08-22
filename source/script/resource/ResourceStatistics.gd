class_name ResourceStatistics
extends Resource

export var max_health: int = 3
export var health: int = 3

export var currency: int = 0
export var keys: int = 0
export var boss_key: bool = false

export var items: Array = [null, null]

export var strength: int = 5
export var speed: int = 10
export var jump: int = 65

func set_max_health(amount: int) -> void:
	max_health = amount

func get_max_health() -> int:
	return max_health

func set_health(amount: int) -> void:
	health = amount

func get_health() -> int:
	return health

func set_currency(amount: int) -> void:
	currency = amount

func get_currency() -> int:
	return currency

func set_keys(amount: int) -> void:
	keys = amount

func get_keys() -> int:
	return keys

func set_boss_key(has: bool) -> void:
	boss_key = has

func get_boss_key() -> bool:
	return boss_key

func set_items(inventory: Array) -> void:
	items = inventory

func get_items() -> Array:
	return items

func set_strength(inventory: int) -> void:
	strength = inventory

func get_strength() -> int:
	return strength

func set_speed(inventory: int) -> void:
	speed = inventory

func get_speed() -> int:
	return speed

func set_jump(inventory: int) -> void:
	jump = inventory

func get_jump() -> int:
	return jump
