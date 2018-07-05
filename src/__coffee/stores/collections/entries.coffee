dispatcher = require '../../util/dispatcher'
Base = require './base'
Entry = require '../models/entry'

Entries = Base.extend
	model: Entry

	initialize: ->
		@entryHasChanged = false

	getState: ->
		entries: @
		prevEntry: @prev
		entry: @current
		nextEntry: @next
		entryHasChanged: @entryHasChanged

	# Can't use "change" as an event, because it is used by ampersand-collection.
	_triggerUpdate: ->
		@trigger 'update'

	_onReceiveAll: (data) ->
		@add data
		# @setCurrent()

	_onReceiveEntry: (data) ->
		@get(data._id).set data

	_onUpdateCoordinates: (lon, lat, note) ->
		# TODO move to validation (and create validation ;))
		lon = +lon
		lat = +lat

		@current.geo.changeEpsg4326 lon, lat, note

		@entryHasChanged = true

	_onUpdateFoundInText: (lon, lat, note) ->
		@current.geo.changeFoundInText lon, lat, note

		@entryHasChanged = true

dispatcherCallback = (payload) ->
	entries.entryHasChanged = false

	switch payload.action.actionType
		when 'RECEIVE_ALL_ENTRIES'
			entries._onReceiveAll payload.action.data
		when 'RECEIVE_ENTRY'
			entries._onReceiveEntry payload.action.data
		when 'SET_ENTRY'
			entries.setCurrent payload.action.id
		when 'UNSET_ENTRY'
			entries.unsetCurrent()
		when 'UPDATE_ENTRY_COORDINATES'
			entries._onUpdateCoordinates payload.action.lon, payload.action.lat, payload.action.note
		when 'UPDATE_ENTRY_FOUND_IN_TEXT'
			entries._onUpdateFoundInText payload.action.lon, payload.action.lat, payload.action.note
		else
			return

	entries._triggerUpdate()

entries = new Entries()
entries.dispatcherIndex = dispatcher.register dispatcherCallback

window.entries = entries
module.exports = entries