Model = require 'ampersand-state'

Epsg4326 = Model.extend
	props:
		type: 'Point'
		coordinates:
			type: 'array'
			default: -> []

	derived:
		displayCoordinates:
			deps: ['coordinates']
			fn: ->
				coords = @coordinates.slice(0)

				coords[0] = if coords[0]? then coords[0].toFixed(2) else 'NA'
				coords[1] = if coords[1]? then coords[1].toFixed(2) else 'NA'

				coords
			cache: false


module.exports = Epsg4326