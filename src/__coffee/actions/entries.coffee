dispatcher = require '../util/dispatcher'

store = require '../stores/collections/entries'

API = require '../util/api'

entriesActions =
	getAllEntries: ->
		API.getAllEntries()

	setEntry: (id) ->
		dispatcher.handleViewAction
			actionType: "SET_ENTRY"
			id: id

		# If the entry is not fully loaded yet, do it now.
		unless store.get(id).full
			API.getEntry id

	unsetEntry: ->
		dispatcher.handleViewAction
			actionType: "UNSET_ENTRY"

	setNextEntry: ->
		console.log store.next
		if store.next?
			@setEntry store.next._id

	setPrevEntry: ->
		if store.prev?
			@setEntry store.prev._id

	updateCoordinates: (lon, lat, note) ->
		dispatcher.handleViewAction
			actionType: "UPDATE_ENTRY_COORDINATES"
			lon: lon
			lat: lat
			note: note

	updateFoundInText: (lon, lat, note) ->
		dispatcher.handleViewAction
			actionType: "UPDATE_ENTRY_FOUND_IN_TEXT"
			lon: lon
			lat: lat
			note: note

module.exports = entriesActions