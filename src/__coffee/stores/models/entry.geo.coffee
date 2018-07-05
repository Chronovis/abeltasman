Model = require 'ampersand-state'
Collection = require 'ampersand-collection'

Epsg4326 = require './entry.geo.epsg-4326'
Revision = require './entry.geo.revision'

Revisions = Collection.extend
	model: Revision

Geo = Model.extend
	props:
		'epsg-3857': 'array'
		'found-in-text':
			type: 'object'
			default: ->
				longitude: 'NA'
				latitude: 'NA'

	children:
		'epsg-4326': Epsg4326

	collections:
		revisions: Revisions

	derived:
		quality:
			deps: ['epsg-3857', 'found-in-text', 'epsg-4326']
			fn: ->
				q = 'lead'

				if @['found-in-text'].longitude isnt @['found-in-text'].latitude
					q = 'iron'

					if @['epsg-4326'].coordinates.length isnt 0
						q = 'bronze'
						
						if @['epsg-3857']? and @['epsg-3857'].length isnt 0
							q = 'silver'

				q

	changeEpsg4326: (lon, lat, note) ->
		@['epsg-4326'].coordinates[0] = lon
		@['epsg-4326'].coordinates[1] = lat

		@['epsg-3857'] = ol.proj.transform(@['epsg-4326'].coordinates, 'EPSG:4326', 'EPSG:3857')

		@_addRevision 'Coordinates', "Longitude: #{lon.toFixed(2)}, latitude: #{lat.toFixed(2)}", note

	changeFoundInText: (lonStr, latStr, note) ->
		@['found-in-text'] =
			longitude: lonStr
			latitude: latStr

		splitLon = lonStr.split('°')
		lonDegrees = splitLon[0]
		lonMinutes = splitLon[1].substr(1, (splitLon[1].length - 2)) or 0

		splitLat = latStr.split('°')
		latDegrees = splitLat[0]
		latMinutes = splitLat[1].substr(1, (splitLat[1].length - 2)) or 0

		lon = parseInt(lonDegrees) + parseInt(lonMinutes)/60
		lat = parseInt(latDegrees) + parseInt(latMinutes)/60

		@changeEpsg4326 (lon - 18), (lat * -1), "'Found in text'-attribute changed."

		@_addRevision 'Found in text', "Longitude: #{lonStr}, latitude: #{latStr}", note

	_addRevision: (attribute, value, note) ->
		@revisions.add
			attribute: attribute
			value: value
			note: note
			date: new Date()


module.exports = Geo