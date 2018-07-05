React = require 'react'

entriesActions = require '../actions/entries'

Input = require './input'
Textarea = require './textarea'

FoundInText = React.createClass
	getInitialState: ->
		error: null

	getDefaultProps: ->
		longitude: ''
		latitude: ''

	render: ->
		if @state.error?
			error = <div className="error">{@state.error}</div>

		<h3>Found in journal</h3>
		<ul>
			<Input ref="lon" label="Longitude" value={@props.longitude} />
			<Input ref="lat" label="Latitude" value={@props.latitude} />
			<Textarea ref="note" label="Note" />
			{error}
			<button onClick={@_handleSave}>Save</button>
		</ul>

	_handleSave: (ev) ->
		lon = @refs['lon'].getValue()
		lat = @refs['lat'].getValue()
		note = @refs['note'].getValue()

		if @_validate(lon, lat, note)
			entriesActions.updateFoundInText lon, lat, note
			@refs['note'].clearValue()

	_validate: (lon, lat, note) ->
		if lon is @props.longitude and lat is @props.latitude
			error = "Longitude and latitude haven't changed."
		else if note.trim() is ''
			error = "Please leave a note for reference."

		@setState 'error': error
		
		# Return valid. Valid is true when there are no errors.
		# When there are errors, the values aren't valid.
		valid = not error?

		valid
		

module.exports = FoundInText

