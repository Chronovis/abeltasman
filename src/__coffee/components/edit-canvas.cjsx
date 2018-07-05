React = require 'react'

canvasRectTopLeft = null
canvasRectBottomRight = null
rectangles = []

EditCanvas = React.createClass

	componentDidMount: ->
		rect = @getDOMNode().parentNode.getBoundingClientRect()

		@getDOMNode().width = rect.width
		@getDOMNode().height = rect.height

		window.addEventListener 'mouseup', @_handleMouseUp
		window.addEventListener 'mousemove', @_handleMouseMove

	componentWillUnmount: ->
		window.removeEventListener 'mouseup', @_handleMouseUp
		window.removeEventListener 'mousemove', @_handleMouseMove 	

	render: ->
		<canvas
			width={@props.width}
			height={@props.height}
			onMouseDown={@_onMouseDown}
			onMouseMove={@_onMouseMove}
			onMouseUp={@_onMouseUp}></canvas>

	_onMouseDown: (ev) ->
		canvas = @getDOMNode()
		rect = @getDOMNode().getBoundingClientRect()
		
		canvasRectTopLeft =
			x: ev.clientX - rect.left
			y: ev.clientY - rect.top

	_onMouseMove: (ev) ->
		if canvasRectTopLeft?
			canvas = @getDOMNode()
			rect = @getDOMNode().getBoundingClientRect()
			
			canvasRectBottomRight =
				x: ev.clientX - rect.left
				y: ev.clientY - rect.top

			# ctx = canvas.getContext('2d')
			# ctx.clearRect(0, 0, canvas.width, canvas.height)
			# ctx.lineWidth = 2
			# ctx.strokeStyle = "rgba(255, 128, 0, 0.3)"
			# ctx.fillStyle = "rgba(255, 255, 0, 0.3)"
			# ctx.strokeRect(canvasRectTopLeft.x, canvasRectTopLeft.y, canvasRectBottomRight.x - canvasRectTopLeft.x, canvasRectBottomRight.y - canvasRectTopLeft.y)
			# ctx.fillRect(canvasRectTopLeft.x, canvasRectTopLeft.y, canvasRectBottomRight.x - canvasRectTopLeft.x, canvasRectBottomRight.y - canvasRectTopLeft.y)
			@_clear()
			@_drawRectangle()
			@_drawRectangles()

	_onMouseUp: (ev) ->
		rectangles.push [canvasRectTopLeft, canvasRectBottomRight]
		
		@_drawRectangle()

		canvasRectTopLeft = null
		canvasRectBottomRight = null

	_drawRectangle: (topleft, bottomright) ->
		topleft = canvasRectTopLeft unless topleft?
		bottomright = canvasRectBottomRight unless bottomright?

		ctx = @getDOMNode().getContext('2d')
		ctx.beginPath()
		ctx.moveTo topleft.x, topleft.y
		ctx.lineTo bottomright.x, topleft.y
		ctx.lineTo bottomright.x, bottomright.y
		ctx.lineTo topleft.x, bottomright.y
		ctx.closePath()
		ctx.stroke()

	_drawRectangles: ->
		for rectangle in rectangles
			@_drawRectangle rectangle[0], rectangle[1]

	_clear: ->
		canvas = @getDOMNode()
		ctx = canvas.getContext('2d')
		ctx.clearRect(0, 0, canvas.width, canvas.height)


module.exports = EditCanvas