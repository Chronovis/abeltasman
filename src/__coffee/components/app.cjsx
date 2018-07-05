React = require 'react'
req = require 'funcky.req'

OpenLayers3Map = require '../util/map'

Entry = require './entry'
MultipleSelect = require './multiple-select'
Facsimiles = require './facsimiles'


entriesStore = require '../stores/collections/entries'
entriesActions = require '../actions/entries'
StoreWatchMixin = require '../util/store-watch'

# TODO think of something better than a flag!
didUpdate = false

App = React.createClass

	mixins: [StoreWatchMixin(entriesStore)]

	getInitialState: ->
		'selected-ids': null
	
	componentDidMount: ->
		entriesActions.getAllEntries()

		@map = new OpenLayers3Map @refs.map.getDOMNode()

		@map.map.on 'click', (ev) =>
			clickedCluster = []

			@map.map.forEachFeatureAtPixel ev.pixel, (feature) =>
				clickedCluster.push feature

			if clickedCluster.length is 1
				# console.log clickedCluster
				cluster = clickedCluster[0]
				clickedFeatures = cluster.getProperties().features

				if clickedFeatures.length is 1
					feature = clickedFeatures[0]
					style = new ol.style.Style
						image: new ol.style.Circle
							radius: 5,
							fill: new ol.style.Fill
								color: 'green'
					feature.setStyle style
					entriesActions.setEntry feature.getProperties().id
				else
					ids = (feature.getProperties().id for feature in clickedFeatures)
					@setState 'selected-ids': ids
			else
				@setState 'selected-ids': null
				entriesActions.unsetEntry()

		# setInterval (=> entriesActions.setNextEntry()), 1000


	componentWillUpdate: (nextProps, nextState) ->
		unless didUpdate
			@map.addFeatures nextState.entries
		didUpdate = true

		# console.log @state.entry, nextState.entry
		if @state.entry? and nextState.entry? and @state.entry isnt nextState.entry
			@map.selectInteraction.getFeatures().clear()
			index = entriesStore.indexOf nextState.entry
			feature = @map.features[index]
			# console.log 'feat', feat
			@map.selectInteraction.getFeatures().push feature

			coords = feature.getGeometry().getCoordinates()
			@map.panTo coords

		if nextState.entryHasChanged
			@map.addFeatures nextState.entries

	render: ->
		if @state['selected-ids']?
			multipleSelect =
				<MultipleSelect ids={@state['selected-ids']} />

		if @state.entry?
			entryDetail =
				<Entry
					entry={@state.entry}
					prevEntry={@state.prevEntry}
					nextEntry={@state.nextEntry} />

		<div className="app">
			<div ref="map" className="map" ></div>
			<Facsimiles />
			{entryDetail}
			{multipleSelect}
		</div>

module.exports = App