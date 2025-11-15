extends Resource
class_name EnemyArchetype

@export var id = ""
@export var display_name = ""
@export var type = "basic"
@export var stats: StatBlock
@export var movement_profile: MovementProfile
@export var ai_controller: EnemyAIController
@export var animations: AnimationProfile
@export var weapon_slots: Array = []
@export var scene: PackedScene
