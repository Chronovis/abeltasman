React = require 'react'

entriesStore = require '../stores/collections/entries'
entriesActions = require '../actions/entries'

MultipleSelect = React.createClass
	render: ->
		entries = @props.ids.map (id) =>
			<li key={id} onClick={@_handleClick.bind(@, id)}>{entriesStore.get(id).date}</li>

		<div className="multiple-select modal">
			<ul>
				<li key="heading" className="heading">Multiple entries at selected location</li>
			</ul>
			<ul className="entries">
				{entries}
			</ul>
		</div>

	_handleClick: (id, ev) ->
		entriesActions.setEntry id


module.exports = MultipleSelect