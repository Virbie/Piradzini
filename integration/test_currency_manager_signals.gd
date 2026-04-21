# Šis tests pārbauda, ka valūtas menedžeris ne tikai palielina summu,
# bet arī izsūta abus svarīgos signālus citiem sistēmas gabaliem.
extends GutTest

const CURRENCY_MANAGER_SCRIPT = preload("res://Skripti/CurrencyManager.gd")

func test_add_currency_updates_total_and_emits_both_signals() -> void:
	var manager = CURRENCY_MANAGER_SCRIPT.new()
	var added_amount := -1
	var changed_total := -1

	manager.currency_added.connect(func(amount: int): added_amount = amount)
	manager.currency_changed.connect(func(total: int): changed_total = total)

	manager.add_currency(7)

	assert_eq(manager.get_currency(), 7)
	assert_eq(added_amount, 7)
	assert_eq(changed_total, 7)
