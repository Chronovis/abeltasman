React = require 'react'

draggingOffset = null
canvasRectTopLeft = null
canvasRectBottomRight = null

EditCanvas = require './edit-canvas'

Facsimiles = React.createClass

	getInitialState: ->
		facsimile: null

	componentDidMount: ->
		window.addEventListener 'mouseup', @_handleMouseUp
		window.addEventListener 'mousemove', @_handleMouseMove

	componentWillUnmount: ->
		window.removeEventListener 'mouseup', @_handleMouseUp
		window.removeEventListener 'mousemove', @_handleMouseMove 

	# componentDidUpdate: (prevProps, prevState) ->
	# 	if @state.facsimile?
	# 		canvas = @refs.canvas.getDOMNode()
	# 		console.log getComputedStyle(@refs.versorecto.getDOMNode()).width
	# 		canvas.width = parseInt getComputedStyle(@refs.versorecto.getDOMNode()).width
	# 		canvas.height = parseInt getComputedStyle(@refs.versorecto.getDOMNode()).height
	

	render: ->
		facsimiles = []
		for n in [0..193]
			facsimile =
				<li onClick={@_onClickFacsimile.bind(@, n)}>
					<img draggable="false" src={"/images/facsimiles/thumbnails/tasman-#{n}.jpg"} />
				</li>
			facsimiles.push facsimile

		if @state.facsimile?
			if @state.facsimile % 2 is 0
				versoNumber = @state.facsimile - 1
				rectoNumber = @state.facsimile
			else
				versoNumber = @state.facsimile
				rectoNumber = @state.facsimile + 1
			versorecto =
				<div ref="versorecto" className="verso-recto">
					<EditCanvas />
					<img src="/images/facsimiles/tasman-#{versoNumber}.jpg" />
					<img src="/images/facsimiles/tasman-#{rectoNumber}.jpg" />
				</div>

		<div className="facsimiles-container">
			{versorecto}
			<ul className="facsimiles"
				ref="facsimiles"
				onMouseDown={@_handleMouseDown}
				onMouseMove={@_handleMouseMove}
				onMouseUp={@_handleMouseUp}
				onWheel={@_handleWheel}>
				{facsimiles}
			</ul>
		</div>

	_handleMouseDown: (ev) ->
		ev.preventDefault()

		nodeLeft = +(window.getComputedStyle(@refs.facsimiles.getDOMNode()).left.slice(0, -2))
		draggingOffset = ev.clientX - nodeLeft
			
	_handleMouseMove: (ev) ->
		ev.preventDefault()

		if draggingOffset?
			@_moveFacsimiles ev.clientX - draggingOffset

	_handleMouseUp: (ev) ->
		ev.preventDefault()

		if draggingOffset?
			draggingOffset = null

	_handleWheel: (ev) ->
		ev.preventDefault()

		left = parseInt(@refs.facsimiles.getDOMNode().style.left, 10) or 0
		@_moveFacsimiles left-(ev.deltaY*10)

	_moveFacsimiles: (left) ->
		if left <= 0 and (@refs.facsimiles.getDOMNode().offsetWidth + left) >= window.innerWidth
			@refs.facsimiles.getDOMNode().style.left = left + 'px'

	_onClickFacsimile: (n, ev) ->
		@setState facsimile: n

module.exports = Facsimiles