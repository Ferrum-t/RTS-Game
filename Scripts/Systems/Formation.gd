class_name Formation

enum FormationType
{
	SQUARE,
	LINE,
	COLUMN,
	WEDGE,
	CIRCLE
}


static func generate_positions(
	center: Vector3,
	count: int,
	spacing: float = 3.4,
	formation: FormationType = FormationType.SQUARE
) -> Array[Vector3]:

	match formation:

		FormationType.SQUARE:
			return _generate_square(center, count, spacing)

		FormationType.LINE:
			return _generate_line(center, count, spacing)

		FormationType.COLUMN:
			return _generate_column(center, count, spacing)

		FormationType.WEDGE:
			return _generate_wedge(center, count, spacing)

		FormationType.CIRCLE:
			return _generate_circle(center, count, spacing)

	return []


static func _generate_square(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	var positions: Array[Vector3] = []

	if count <= 0:
		return positions

	var columns: int = int(ceil(sqrt(float(count))))
	var rows: int = int(ceil(float(count) / float(columns)))

	var start_x: float = -(float(columns - 1) * spacing * 0.5)
	var start_z: float = -(float(rows - 1) * spacing * 0.5)

	for i: int in range(count):

		@warning_ignore("integer_division")
		var row: int = i / columns
		var column: int = i % columns

		var offset: Vector3 = Vector3(
			start_x + float(column) * spacing,
			0.0,
			start_z + float(row) * spacing
		)

		positions.append(center + offset)

	return positions


static func _generate_line(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:
	return _generate_square(center, count, spacing)


static func _generate_column(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:
	return _generate_square(center, count, spacing)


static func _generate_wedge(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:
	return _generate_square(center, count, spacing)


static func _generate_circle(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:
	var positions: Array[Vector3] = []
	if count <= 0:
		return positions
	if count == 1:
		positions.append(center)
		return positions
	var radius: float = spacing * 0.6 * float(count) / TAU
	radius = maxf(radius, spacing)
	for i: int in range(count):
		var a: float = float(i) * TAU / float(count)
		positions.append(center + Vector3(cos(a) * radius, 0.0, sin(a) * radius))
	return positions
