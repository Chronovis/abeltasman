React = require 'react'

Coordinates = React.createClass
	getDefaultProps: ->
		labels: true
		lon: ''
		lat: ''

	render: ->
		if @props.labels
			lonLabel = <label>Longitude</label>
			latLabel = <label>Latitude</label>

		<ul className="coordinates">
			<li>
				{lonLabel}
				<span>{@props.lon}</span>
			</li>
			<li>
				{latLabel}
				<span>{@props.lat}</span>
			</li>
		</ul>

module.exports = Coordinates