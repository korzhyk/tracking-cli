L.Polyline = L.Polyline.extend
	distance: ->
		total = 0
		for i, point of @_latlngs
			curr = point
			next = @_latlngs[i + 1]

			total += curr.distanceTo next if next

		total