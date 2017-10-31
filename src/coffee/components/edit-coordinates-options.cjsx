React = require 'react'

interpolate = require '../util/interpolate-coordinate'

EditCoordinatesOptions = React.createClass
	propTypes:
		prevGeo: React.PropTypes.object
		nextGeo: React.PropTypes.object
		setCoordinates: React.PropTypes.func

	render: ->
		<ul className="edit-coordinates-options">
			<li onClick={@_handlePrev}>
				<img src="/svg/edit-coordinates-option-prev.svg" />
			</li>
			<li onClick={@_handleInterpolate}>
				<img src="/svg/edit-coordinates-option-interpolate.svg" />
			</li>
			<li onClick={@_handleNext}>
				<img src="/svg/edit-coordinates-option-next.svg" />
			</li>
		</ul>

	_handlePrev: (ev) ->
		@props.setCoordinates @props.prevGeo['epsg-4326'].displayCoordinates, "Copied from prev entry."

	_handleInterpolate: (ev) ->
		point1 = @props.prevGeo['epsg-4326'].coordinates
		point2 = @props.nextGeo['epsg-4326'].coordinates

		interpolatedPoint = interpolate point1, point2
		interpolatedPoint = interpolatedPoint.map (coordinate) -> coordinate.toFixed(2)

		@props.setCoordinates interpolatedPoint, "Interpolated from previous and next entry."

	_handleNext: (ev) ->
		@props.setCoordinates @props.nextGeo['epsg-4326'].displayCoordinates, "Copied from next entry."


module.exports = EditCoordinatesOptions			
			