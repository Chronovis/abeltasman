Model = require 'ampersand-state'

Geo = require './entry.geo'

Entry = Model.extend
	idAttribute: '_id'

	props:
		_id: 'string'
		date: 
			type: 'string'
			default: "00-00-0000"
		pages:
			type: 'array'
			default: -> []
		wind: 
			type: 'string'
			default: ''

	children:
		geo: Geo

	session:
		full: ['boolean', true, false]

module.exports = Entry