Dispatcher = require('flux').Dispatcher

class AppDispatcher extends Dispatcher
	handleViewAction: (action) ->
		console.log '  VIEW ACTION: ', action
		@dispatch
			source: 'VIEW_ACTION'
			action: action
			
	handleServerAction: (action) ->
		console.log 'SERVER ACTION: ', action
		@dispatch
			source: 'SERVER_ACTION'
			action: action

module.exports = new AppDispatcher()