dispatcher = require '../util/dispatcher'

dispatchJSON = (type, data) ->
	dispatcher.handleServerAction
		actionType: type
		data: data

serverActions =
	receiveAllEntries: (data) ->
		dispatchJSON "RECEIVE_ALL_ENTRIES", data

	receiveEntry: (data) ->
		dispatchJSON "RECEIVE_ENTRY", data

module.exports = serverActions