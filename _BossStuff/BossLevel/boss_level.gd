extends Node2D

@onready var entities: Node2D = $Entities
@onready var attack_indicators: Node2D = $AttackIndicators

@onready var boss_lightning_module: BossLightningModule = $BossLightningModule

var timer = 10

func _ready() -> void:
	boss_lightning_module.indicator_node = attack_indicators
	GameData.player.global_position = $PlayerSpawn.global_position
	entities.add_child(GameData.player)
	boss_lightning_module.add_lightning(2)

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		timer = 10
		boss_lightning_module.activate(3)
