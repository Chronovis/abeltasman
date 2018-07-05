xhr = require 'funcky.req'

dispatcher = require '../util/dispatcher'

serverActions = require '../actions/server'

getJSON = (url, done) ->
	req = xhr.get url
	req.done (xhr) ->
		json = JSON.parse xhr.response
		done json

module.exports =
	getAllEntries: (done) ->
		getJSON '/api/entries', (data) =>
			serverActions.receiveAllEntries data
			done() if done?

	getEntry: (id, done) ->
		getJSON "/api/entries/#{id}", (data) =>
			serverActions.receiveEntry data
			done() if done?

	