EventEmitter = require('events').EventEmitter

qualityMode = (features) ->
	counts = {}
	for feature in features
		q = feature.getProperties().quality
		if counts.hasOwnProperty(q)
			counts[q] += 1
		else
			counts[q] = 1

	prevCount = 0
	for quality, count of counts
		if count > prevCount
			max = quality

		prevCount = count

	max
		

createPointLayer = (features) ->
	source = new ol.source.Vector
		features: features

	clusterSource = new ol.source.Cluster
		distance: 10
		source: source

	styleCache = {}
	style = (feature, resolution) ->
		features = feature.getProperties().features
		count = features.length
		quality = qualityMode features

		switch quality
			when 'lead'
				imageColor = '#5e5c59'
				fontColor = '#ffffff'
			when 'iron'
				imageColor = '#80827F'
				fontColor = '#000000'
			when 'bronze'
				imageColor = '#CD7F32'
				fontColor = '#000000'
			when 'silver'
				imageColor = '#E6E8FA'
				fontColor = '#000000'
			when 'gold'
				imageColor = '#CC9900'
				fontColor = '#000000'

		style = styleCache[quality + count]

		unless style?
			if count is 1
				style = new ol.style.Style
					image: new ol.style.Circle
						fill: new ol.style.Fill
							color: 'blue'
						radius: 4
			else
				style = new ol.style.Style
					image: new ol.style.Circle
						fill: new ol.style.Fill
							color: imageColor
						radius: 8
					text: new ol.style.Text
						text: count.toString()
						fill: new ol.style.Fill
							color: fontColor

			styleCache[quality + count] = style
		
		[style]
	# style = new ol.style.Style
	# 	image: new ol.style.Circle
	# 		fill: new ol.style.Fill
	# 			color: 'blue'
	# 		radius: 5

	new ol.layer.Vector
		source: clusterSource,
		style: style

createLineLayer = (markers) ->
	feature = new ol.Feature
		geometry: new ol.geom.LineString(markers, 'XY')

	source = new ol.source.Vector       
		features: [feature]

	style = new ol.style.Style
		stroke: new ol.style.Stroke
			color: 'blue'
			width: 2

	new ol.layer.Vector
		source: source
		style: style


createSelectInteraction = (layer, olMap) ->
	selectInteraction = new ol.interaction.Select
		layers: [layer]
		style: new ol.style.Style
			image: new ol.style.Icon
				anchor: [0.5, 0.9],
				anchorXUnits: 'fraction',
				anchorYUnits: 'fraction',
				opacity: 1,
				src: 'images/boat.png'
				width: '20px'
			# image: new ol.style.Circle
			# 	radius: 8,
			# 	fill: new ol.style.Fill
			# 		color: 'yellow'
			# 	stroke: new ol.style.Stroke
			# 		color: 'red'
			# 		width: 2

	# selectInteraction.getFeatures().on 'add', (ev) =>
	# 	ids = ev.element.getProperties().features.map (feature) ->
	# 		feature.getProperties().id
		
	# 	if ids.length is 1
	# 		olMap.emit 'select', ids[0]
	# 	else
	# 		olMap.emit 'multiple-select', ids
	
	# selectInteraction.getFeatures().on 'remove', (ev) =>
	# 	ids = ev.element.getProperties().features.map (feature) ->
	# 		feature.getProperties().id

	# 	if ids.length is 1
	# 		olMap.emit 'unselect', ids[0]
	# 	else
	# 		olMap.emit 'multiple-unselect', ids

	selectInteraction

createModifyInteraction = (features, olMap) ->
	selectInteraction = new ol.interaction.Modify
		features: features
		style: new ol.style.Style
			image: new ol.style.Circle
				radius: 5,
				fill: new ol.style.Fill
					color: 'yellow'

	selectInteraction

interpolate = require './interpolate-coordinate'


module.exports =
	class OpenLayers3Map extends EventEmitter
		constructor: (el) ->
			tileLayer = new ol.layer.Tile
				source: new ol.source.Stamen layer: 'watercolor'

			@map = new ol.Map
				layers: [tileLayer]
				target: el
				controls: []
				view: new ol.View
					center: ol.proj.transform([120, -30], 'EPSG:4326', 'EPSG:3857')
					zoom: 3

		addFeatures: (entries) ->
			@markers = []

			@features = entries.map (entry, index) =>
				coords = if entry.geo['epsg-3857']? then entry.geo['epsg-3857'] else @_interpolateCoords(entries, index)

				@markers.push coords

				new ol.Feature
					geometry: new ol.geom.Point(coords),
					date: entry.date
					id: entry._id
					quality: entry.geo.quality

			@_createLayers()
			# @lineLayer = createLineLayer(@markers)
			# @pointLayer = createPointLayer(@features)
			# @selectInteraction = createSelectInteraction(@pointLayer, @emit)

			# @map.addLayer @lineLayer
			# @map.addLayer @pointLayer
			# @map.addInteraction @selectInteraction

		# updateFeatureCoordinates: (index, coordinates) ->
		# 	coordinates = ol.proj.transform(coordinates, 'EPSG:4326', 'EPSG:3857')
		# 	# TODO check if coordinates where transformed OK, otherwise throw error
		# 	feature = @features[index]
		# 	feature.setGeometry new ol.geom.Point(coordinates)

		# 	@markers[index] = coordinates

		# 	@_createLayers()
		# 	# @map.removeLayer @lineLayer
		# 	# @lineLayer = createLineLayer(@markers)

		# 	# Pan to new coordinate
		# 	view = @map.getView()
		# 	pan = ol.animation.pan
		# 		duration: 500,
		# 		source: view.getCenter()

		# 	@map.beforeRender(pan)
		# 	view.setCenter(coordinates)

		# 	# Select coordinate
		# 	@selectInteraction.getFeatures().clear()
		# 	@selectInteraction.getFeatures().push(feature)

		panTo: (coordinates) ->
			view = @map.getView()
			pan = ol.animation.pan
				duration: 500,
				source: view.getCenter()

			@map.beforeRender(pan)
			view.setCenter(coordinates)



		_createLayers: ->
			@map.removeLayer @lineLayer if @lineLayer?
			@map.removeLayer @pointLayer if @pointLayer?
			@map.removeInteraction @selectInteraction if @selectInteraction?

			@lineLayer = createLineLayer(@markers)
			@pointLayer = createPointLayer(@features)
			@selectInteraction = createSelectInteraction(@pointLayer, @)
			# @modifyInteraction = createModifyInteraction(@selectInteraction.getFeatures(), @)

			@map.addLayer @lineLayer
			@map.addLayer @pointLayer
			@map.addInteraction @selectInteraction
			# @map.addInteraction @modifyInteraction

		_interpolateCoords: (entries, index) ->
			prevIndex = index - 1
			prevEntry = entries.at prevIndex 

			while prevEntry? and not prevEntry.geo['epsg-3857']?
				prevIndex -= 1
				prevEntry = entries.at prevIndex

			nextIndex = index + 1
			nextEntry = entries.at nextIndex

			while nextEntry? and not nextEntry.geo['epsg-3857']?
				nextIndex += 1
				nextEntry = entries.at nextIndex

			if prevIndex isnt -1 and nextIndex isnt -1
				point1 = ol.proj.transform(prevEntry.geo['epsg-3857'], 'EPSG:3857', 'EPSG:4326')
				point2 = ol.proj.transform(nextEntry.geo['epsg-3857'], 'EPSG:3857', 'EPSG:4326')

				midpoint = interpolate point1, point2
				
				return ol.proj.transform(midpoint, 'EPSG:4326', 'EPSG:3857')
				

			ol.proj.transform([0, 0], 'EPSG:4326', 'EPSG:3857')





	