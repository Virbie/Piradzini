extends Control

@onready var amount_label = $"depozits pievienots"
@onready var total_label = $"depozits kopa"

var tween: Tween
var display_time := 1.2

func _ready():
	visible = false
	modulate.a = 0.0
	CurrencyManager.currency_added.connect(_on_currency_added)

func _on_currency_added(amount: int):
	show_popup(amount)

func show_popup(amount: int):
	visible = true
	modulate.a = 1.0
	
	amount_label.text = "+" + str(amount)

	animate_total(CurrencyManager.get_currency() - amount,
				  CurrencyManager.get_currency())

	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_interval(display_time)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(hide)

func animate_total(from_value: int, to_value: int):
	var duration := 0.4  # fast like Fallout
	
	var count_tween = create_tween()
	count_tween.tween_method(
		func(value):
			total_label.text = str(int(value)),
		from_value,
		to_value,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _input(event):
		if event.is_action_pressed("add_currency_test"):
			CurrencyManager.add_currency(10)
