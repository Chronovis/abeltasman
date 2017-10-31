React = require 'react'

entriesActions = require '../actions/entries'

Coordinates = require './coordinates'
EditCoordinatesOptions = require './edit-coordinates-options'
FoundInText = require './found-in-text'

CoordsEditor = React.createClass
	getInitialState: ->
		lon: @props.geo['epsg-4326'].displayCoordinates[0]
		lat: @props.geo['epsg-4326'].displayCoordinates[1]
		note: ''
		messages: []

	componentWillReceiveProps: (nextProps) ->
		@setState 
			lon: @props.geo['epsg-4326'].displayCoordinates[0]
			lat: @props.geo['epsg-4326'].displayCoordinates[1]
			note: ''

	render: ->
		revisions = @props.geo.revisions.map (rev) ->
			<li key={rev.date.toString()+rev.attribute}>
				<div>{rev.date.toString()}</div>
				<div>{rev.attribute}</div>
				<div>{rev.value}</div>
				<div>{rev.note}</div>
			</li>

		console.log revisions
			
		if revisions.length > 0
			revisions = 
				<li className="revisions">
					<ul>
						{revisions}
					</ul>
				</li>

		for message in @state.messages
			if message.el is 'note'
				noteError = 
					<div className={message.type}>
						{message.text}
					</div>
			else if message.el is 'lat'
				latError = 
					<div className={message.type}>
						{message.text}
					</div>
			else if message.el is 'lon'
				lonError = 
					<div className={message.type}>
						{message.text}
					</div>

		if @props.geo['epsg-3857']?
			epsg3857 =
				<li className="epsg-3857">
					<h3>EPSG-3857 projection</h3>
					<Coordinates
						lon={@props.geo['epsg-3857'][0]}
						lat={@props.geo['epsg-3857'][1]} />
				</li>

		<div className="modal editor coords-editor">
			<ul>
				<li>
					<h2>Coordinates</h2>
				</li>
				<li className="form">
					<div className="heading">
						<h3>Edit coordinates</h3>
						<EditCoordinatesOptions
							prevGeo={@props.prevGeo}
							nextGeo={@props.nextGeo}
							setCoordinates={@_setCoordinates} />	
					</div>
					<Coordinates
						lon={@props.prevGeo['epsg-4326'].displayCoordinates[0]}
						lat={@props.prevGeo['epsg-4326'].displayCoordinates[1]} 
						labels={false} />
					<ul className="current coordinates">
						<li>
							<label>Longitude</label>
							<input ref="lon" value={@state.lon} onChange={@_handleInputChange} />
							{lonError}
						</li>
						<li>
							<label>Latitude</label>
							<input ref="lat" value={@state.lat} onChange={@_handleInputChange} />
							{latError}
						</li>
						<li>
							<textarea
								ref="note"
								value={@state.note}
								onChange={@_handleInputChange}
								placeholder="Leave a note for reference."></textarea>
							{noteError}
						</li>
						<li>
							<button onClick={@_handleSaveButtonClick}>Save</button>
						</li>
					</ul>
					<Coordinates
						lon={@props.nextGeo['epsg-4326'].displayCoordinates[0]}
						lat={@props.nextGeo['epsg-4326'].displayCoordinates[1]}
						labels={false} />
				</li>
				{revisions}
				<li className="found-in-text">
					<FoundInText 
						longitude={@props.geo['found-in-text'].longitude} 
						latitude={@props.geo['found-in-text'].latitude}/>
				</li>
				{epsg3857}
			</ul>
		</div>

	_handleInputChange: (ev) ->
		@setState
			lat: @refs.lat.getDOMNode().value
			lon: @refs.lon.getDOMNode().value
			note: @refs.note.getDOMNode().value

	_handleSaveButtonClick: (ev) ->
		[lon, lat] = [+@state.lon, +@state.lat]
		messages = []
		
		lonEqual = @props.geo['epsg-4326'].coordinates[0] is lon
		latEqual = @props.geo['epsg-4326'].coordinates[1] is lat

		if lonEqual and latEqual
			messages.push
				el: 'lat'
				type: 'error'
				text: 'Lon and lat have not changed.'

		if (not lonEqual or not latEqual) and @state.note is ''
			messages.push
				el: 'note'
				type: 'error'
				text: 'Please leave a note.'

		unless -180 <= lon <= 180
			messages.push
				el: 'lon'
				type: 'error'
				text: 'Lon must be between -180 and 180'

		unless -90 <= lat <= 90
			messages.push
				el: 'lat'
				type: 'error'
				text: 'Lat must be between -90 and 90'

		if messages.length is 0
			@_saveCoordinates()
		else
			@setState messages: messages

	_setCoordinates: (coordinates, note) ->
		@setState
			lon: coordinates[0]
			lat: coordinates[1]
			note: note

	_saveCoordinates: ->
		[lon, lat] = [+@state.lon, +@state.lat]

		entriesActions.updateCoordinates lon, lat, @state.note
		
		@setState 
			note: ''
			messages: []

		



module.exports = CoordsEditor