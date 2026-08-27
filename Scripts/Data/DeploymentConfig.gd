extends Resource

class_name DeploymentConfig

## Phase 8.2 — data-driven mobility timings + transit vulnerability.
## Attach via MobileBuilding.deployment_config or use class presets.

@export var pack_duration: float = 2.0
@export var unpack_duration: float = 2.0
@export var mobile_move_speed: float = 1.5
@export var mobile_arrival_distance: float = 0.55
## Incoming damage multiplier while PACKING / MOBILE / UNPACKING (1.0 = no extra).
@export var vulnerability_multiplier: float = 1.0
## Used by range ring UI for towers (0 = no ring).
@export var attack_range_display: float = 0.0


static func preset_town_center() -> DeploymentConfig:
	var c := DeploymentConfig.new()
	c.pack_duration = 5.0
	c.unpack_duration = 5.0
	c.mobile_move_speed = 2.5
	c.vulnerability_multiplier = 1.5
	c.attack_range_display = 0.0
	return c


static func preset_watchtower() -> DeploymentConfig:
	var c := DeploymentConfig.new()
	c.pack_duration = 2.0
	c.unpack_duration = 2.0
	c.mobile_move_speed = 4.0
	c.vulnerability_multiplier = 1.3
	c.attack_range_display = 14.0
	return c
