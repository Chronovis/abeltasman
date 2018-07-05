Model = require 'ampersand-state'

Revision = Model.extend
	props:
		attribute: 'string'
		value: 'any'
		note: 'string'
		date: 'object'

	# derived:
	# 	displayCoordinates:
	# 		deps: ['coordinates']
	# 		fn: ->
	# 			coords = @coordinates

	# 			coords[0] = if coords[0]? then coords[0].toFixed(2) else 'NA'
	# 			coords[1] = if coords[1]? then coords[1].toFixed(2) else 'NA'

	# 			coords

module.exports = Revision