React = require 'react'
React.initializeTouchEvents true
window.React = React

App = require './components/app'

Router = require 'react-router'
Routes = Router.Routes
Route = Router.Route

routes =
	<Routes location="history">
		<Route name="app" path="/" handler={App}></Route>
	</Routes>

document.addEventListener 'DOMContentLoaded', ->
	React.renderComponent routes, document.body