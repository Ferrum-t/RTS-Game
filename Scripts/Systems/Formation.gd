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

	var positions: Array[Vector3] = []

	if count <= 0:
		return positions

	var max_cols: int = 10
	var columns: int = min(count, max_cols)
	var rows: int = int(ceil(float(count) / float(columns)))

	var start_x: float = -(float(columns - 1) * spacing * 0.5)
	var start_z: float = -(float(rows - 1) * spacing * 0.5)

	for i: int in range(count):

		var row: int = i / columns
		var col: int = i % columns

		var current_row_cols: int = columns
		if row == rows - 1:
			current_row_cols = count - (row * columns)

		var row_start_x: float = -(float(current_row_cols - 1) * spacing * 0.5)
		var offset := Vector3(
			row_start_x + float(col) * spacing,
			0.0,
			start_z + float(row) * spacing
		)

		positions.append(center + offset)

	return positions


# =====================================================
# Column Formation
# =====================================================

static func _generate_column(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	var positions: Array[Vector3] = []

	if count <= 0:
		return positions

	var max_rows: int = 10
	var rows: int = min(count, max_rows)
	var columns: int = int(ceil(float(count) / float(rows)))

	var start_x: float = -(float(columns - 1) * spacing * 0.5)
	var start_z: float = -(float(rows - 1) * spacing * 0.5)

	for i: int in range(count):

		var col: int = i / rows
		var row: int = i % rows

		var current_col_rows: int = rows
		if col == columns - 1:
			current_col_rows = count - (col * rows)

		var col_start_z: float = -(float(current_col_rows - 1) * spacing * 0.5)
		var offset := Vector3(
			start_x + float(col) * spacing,
			0.0,
			col_start_z + float(row) * spacing
		)

		positions.append(center + offset)

	return positions


# =====================================================
# Wedge Formation
# =====================================================

static func _generate_wedge(
	center: Vector3,
	count: int,
	spacing: float
) -> Array[Vector3]:

	var positions: Array[Vector3] = []

	if count <= 0:
		return positions

	positions.append(center)
	if count == 1:
		return positions

	for i in range(1, count):

		var side: float = -1.0 if i % 2 == 1 else 1.0
		var depth: int = int(ceil(float(i) / 2.0))

		var offset := Vector3(
			side * float(depth) * spacing * 0.8,
			0.0,
			float(depth) * spacing * 0.8
		)

		positions.append(center + offset)

	return positions


# =====================================================
# Circle Formation
# =====================================================

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

	var remaining: int = count
	var ring_index: int = 0
	var current_radius: float = 0.0

	while remaining > 0:

		if ring_index == 0:

			if count < 6:
				var radius: float = (count * spacing) / (2.0 * PI)
				radius = max(radius, spacing)
				for i in range(count):
					var angle: float = float(i) * (2.0 * PI) / float(count)
					positions.append(center + Vector3(cos(angle), 0.0, sin(angle)) * radius)
				break
			else:
				positions.append(center)
				remaining -= 1
				ring_index += 1
				current_radius = spacing
		else:

			var circumference: float = 2.0 * PI * current_radius
			var ring_capacity: int = int(floor(circumference / spacing))
			ring_capacity = max(ring_capacity, 3)

			var ring_units: int = min(remaining, ring_capacity)
			for i in range(ring_units):
				var angle: float = float(i) * (2.0 * PI) / float(ring_units)
				positions.append(center + Vector3(cos(angle), 0.0, sin(angle)) * current_radius)

			remaining -= ring_units
			current_radius += spacing
			ring_index += 1

	return positions
