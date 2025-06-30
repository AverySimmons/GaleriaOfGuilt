extends HSlider

@export var bus_name = ""

var bus_index: int

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value = AudioServer.get_bus_volume_db(bus_index)

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, value)
	for bus : FmodBus in FmodServer.get_all_buses():
		bus.volume = db_to_linear(value)
