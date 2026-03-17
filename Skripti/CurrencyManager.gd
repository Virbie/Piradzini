extends Node

signal currency_changed(new_value)
signal currency_added(amount)

var currency: int = 0

func add_currency(amount: int):
	currency += amount
	emit_signal("currency_added", amount)
	emit_signal("currency_changed", currency)

func get_currency() -> int:
	return currency
