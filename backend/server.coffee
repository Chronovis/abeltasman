mongo = require 'mongodb'
MongoClient = mongo.MongoClient
ObjectID = mongo.ObjectID 
express = require 'express'
bodyParser = require 'body-parser'
app = express()
app.use bodyParser.json(extended: true)
collection = null

sendResponse = (res, response) ->
	res.setHeader 'Content-Type', 'application/json'
	res.end JSON.stringify response

MongoClient.connect 'mongodb://127.0.0.1:27017/chronovis', (err, db) ->
	throw err if err?

	collection = db.collection 'abeltasman'
	
	app.listen 3000, -> console.log 'Listening on 3000'


app.get '/entries', (req, res) ->
	# criteria =
	# 	geo:
	# 		$exists: true
	# 	'geo.epsg-3857':
	# 		$exists: true
	criteria = {}

	projection =
		'geo': true
		'date': true

	collection.find(criteria, projection).toArray (err, response) ->
		throw err if err?
		sendResponse res, response

app.get '/entries/:id', (req, res) ->
	id = req.param('id')
	criteria =
		_id: new ObjectID(id)

	projection =
		'pages': true

	collection.findOne criteria, projection, (err, response) ->
		throw err if err?
		sendResponse res, response

# app.put '/journal-entries/:id', (req, res) ->
# 	id = req.param 'id'
# 	console.log id, req.body.colspan, req.body

# 	# collection.update {_id: new ObjectID(id)}
# 	res.send 200