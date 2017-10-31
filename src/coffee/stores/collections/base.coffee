Collection = require 'ampersand-collection'

Base = Collection.extend
	initialize: ->
		@prev = null
		@next = null
		@current = null


	###
	@method
	@param {string|number} id
	@param {string} [defaultsTo="first"] - 	If a model with given ID is not found, specify where it should default to.
											* first: default to first model in the colleciton
											* empty: default to an empty version of the model
											* null: default to null
	###
	setCurrent: (id, defaultsTo="first") ->
		return if @length is 0
		
		old = @current
		old.order = null if old?
		
		@current = @get id

		# If no model was found...
		unless @current?
			@current = switch defaultsTo
				when "empty"
					new @model()
				when "null"
					null
				else
					@at 0
		
		@setDirection old

		@setPrev()
		@setNext()

		# Set order to current manuscript last, because otherwise
		# prev or next would override it.
		@current.order = 'current'

		@current

	unsetCurrent: ->
		@prev.order = null if @prev?
		@current.order = null if @current?
		@next.order = null if @next?

		@current = @prev = @next = @direction = null

	# The direction "forward" is defined as going from a low(er) index
	# to a high(er) index.
	# TODO set to stationary if the indexes are equal.
	setDirection: (old) ->
		oldIndex = @indexOf old
		newIndex = @indexOf @current

		@direction = if oldIndex < newIndex then 'forward' else 'backward'

	setPrev: ->
		@prev.order = null if @prev?
		currentIndex = @indexOf @current
		prevIndex = currentIndex - 1
		@prev = @at prevIndex
		@prev.order = 'prev' if @prev?

	setNext: ->
		@next.order = null if @next?
		currentIndex = @indexOf @current
		nextIndex = currentIndex + 1
		@next = @at nextIndex
		@next.order = 'next' if @next?

module.exports = Base