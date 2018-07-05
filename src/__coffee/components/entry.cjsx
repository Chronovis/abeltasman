React = require 'react'

CoordsEditor = require './coords-editor'

entriesActions = require '../actions/entries'

material = require '../util/material-colors'

Entry = React.createClass
	getInitialState: ->
		editor: ''

	getDefaultProps: ->
		entry: {}
		prevEntry: {}
		nextEntry: {}

	render: ->
		pages = @props.entry.pages.map (page) ->
			<li className="page">
				<label>Page {page.pageNumber}</label>
				<div dangerouslySetInnerHTML={{__html: page.html}}></div>
			</li>


		date = @props.entry.date.split('-')
		date = "#{date[2]} #{date[1]} #{date[0]}"

		className = "modal entry"
		className = "#{className} active" if @props.entry._id isnt ''

		editor = switch @state.editor
			when 'coords'
				<CoordsEditor
					geo={@props.entry.geo}
					prevGeo={@props.prevEntry.geo}
					nextGeo={@props.nextEntry.geo} />
			else null

		found = false
		midpoint = 60
		circles = []
		for materialName of material
			unless found
				circles.push <circle fill={material[materialName].imageColor} cx={midpoint} cy="60" r="50"></circle>

			midpoint += 40

			if materialName is @props.entry.geo.quality
				found = true
		
		<div className={className}>
			<ul>
				<li className="date heading">
					<span className="left" onClick={@_handlePrev}><</span>
					<span>{date}</span>
					<span className="right" onClick={@_handleNext}>></span>
				</li>
				<li className="quality">
					<svg viewBox="0 0 280 120">
						{circles}
					</svg>
				</li>
				<li className="coords" onClick={@_handleCoordsClick}>
					<ul>
						<li>
							<label>Longitude</label>
							<span>{@props.entry.geo['epsg-4326'].displayCoordinates[0]}</span>
						</li>
						<li>
							<label>Latitude</label>
							<span>{@props.entry.geo['epsg-4326'].displayCoordinates[1]}</span>
						</li>
					</ul>
				</li>
				<li className="pages">
					<ul>
						{pages}
					</ul>
				</li>
			</ul>
			{editor}
		</div>

	_handlePrev: (ev) ->
		entriesActions.setPrevEntry()

	_handleNext: (ev) ->
		entriesActions.setNextEntry()

	_handleCoordsClick: (ev) ->
		value = if @state.editor is 'coords' then '' else 'coords'
		@setState editor: value


module.exports = Entry