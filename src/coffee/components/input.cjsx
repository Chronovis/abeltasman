React = require 'react'

Input = React.createClass
	getInitialState: ->
		value: @props.value

	getDefaultProps: ->
		value: ''
		label: ''

	render: ->
		<li>
			<label>{@props.label}</label>
			<input type="text" value={@state.value} onChange={@_handleChange} />
		</li>

	_handleChange: (ev) ->
		@setState value: ev.target.value

	getValue: ->
		@state.value

module.exports = Input