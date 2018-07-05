React = require 'react'
merge = require 'react/lib/merge'

StoreWatchMixin = (stores) ->
	# Turn stores into an array if only one store was given.
	stores = [stores] if not Array.isArray stores

	_getStates: ->
		if stores.length is 1
			state = stores[0].getState()
		else
			state = {}
			state = merge state, store.getState() for store in stores
			state

		state

	getInitialState: ->
		@_getStates()

	componentDidMount: ->
		for store in stores
			store.on 'update', @_onUpdate

	componentWillUnmount: (nextProps, nextState) ->
		for store in stores
			store.off 'update', @_onUpdate
	
	_onUpdate: ->
		@setState @_getStates()

module.exports = StoreWatchMixin