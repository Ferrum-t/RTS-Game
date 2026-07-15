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
	spacing: float = 2.5,
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


# =====================================================
# Square Formation
# =====================================================

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


# =====================================================
# Line Formation
# =====================================================

static func _generate_line(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	# TODO
	return _generate_square(center, count, spacing)


# =====================================================
# Column Formation
# =====================================================

static func _generate_column(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	# TODO
	return _generate_square(center, count, spacing)


# =====================================================
# Wedge Formation
# =====================================================

static func _generate_wedge(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	# TODO
	return _generate_square(center, count, spacing)


# =====================================================
# Circle Formation
# =====================================================

static func _generate_circle(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	# TODO
	return _generate_square(center, count, spacing)
