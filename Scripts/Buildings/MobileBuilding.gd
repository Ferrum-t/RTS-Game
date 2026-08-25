extends BaseBuilding

class_name MobileBuilding

## CharacterBody3D building that can pack / move / unpack via DeploymentComponent.
## Phase 4 production path (TownCenter).

@export var pack_time: float = 2.0
@export var unpack_time: float = 2.0
@export var mobile_move_speed: float = 3.0
@export var mobile_arrival_distance: float = 0.55

var deployment: DeploymentComponent = null


func _ready() -> void:
	super()
	deployment = DeploymentComponent.new(self)
	deployment.pack_time = pack_time
	deployment.unpack_time = unpack_time
	deployment.mobile_move_speed = mobile_move_speed
	deployment.mobile_arrival_distance = mobile_arrival_distance


func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
	if deployment:
		deployment.update(delta)


func request_pack() -> bool:
	return deployment != null and deployment.request_pack()


func request_move_to(world_pos: Vector3) -> bool:
	return deployment != null and deployment.request_move_to(world_pos)


func request_unpack() -> bool:
	return deployment != null and deployment.request_unpack()


func cancel_move() -> void:
	if deployment:
		deployment.cancel_move()


func get_deployment_state() -> int:
	return deployment_state


func is_deployed() -> bool:
	return deployment_state == DeploymentState.State.DEPLOYED
