gulp = require 'gulp'
gutil = require 'gulp-util'
concat = require 'gulp-concat'
rimraf = require 'rimraf'
jade = require 'gulp-jade'
stylus = require 'gulp-stylus'
nodemon = require 'gulp-nodemon'

async = require 'async'
exec = require('child_process').exec
source = require 'vinyl-source-stream'
browserify = require 'browserify'
watchify = require 'watchify'
nib = require 'nib'
browserSync = require 'browser-sync'
modRewrite = require 'connect-modrewrite'
rsync = require('rsyncwrapper').rsync
url = require('url')
proxy = require('proxy-middleware')
pkg = require './package.json'
cfg = require './config.json'

gulp.task 'server', ->
	nodemon
		script: './backend/server.coffee'
		watch: './backend'


gulp.task 'reload', ['jade', 'stylus', 'watch', 'browserify-libs', 'watchify', 'server'], ->
	proxyOptions = url.parse('http://localhost:3000')
	proxyOptions.route = '/api'
	
	browserSync.init null,
		notify: false
		server:
			baseDir: "./compiled"
			middleware: [
				proxy(proxyOptions),
				modRewrite([
					'^[^\\.]*$ /index.html [L]'
				])
			]

gulp.task 'link', (done) ->
	removeModules = (cb) ->
		modulePaths = cfg['local-modules'].map (module) -> "./node_modules/#{module}"
		async.each modulePaths , rimraf, (err) -> cb()

	linkModules = (cb) ->
		moduleCommands = cfg['local-modules'].map (module) -> "npm link #{module}"
		async.each moduleCommands, exec, (err) -> cb()

	async.series [removeModules, linkModules], (err) ->
		return gutil.log err if err?
		done()

gulp.task 'unlink', (done) ->
	unlinkModules = (cb) ->
		moduleCommands = cfg['local-modules'].map (module) -> "npm unlink #{module}"
		async.each moduleCommands, exec, (err) -> cb()

	installModules = (cb) ->
		exec 'npm i', cb

	async.series [unlinkModules, installModules], (err) ->
		return gutil.log err if err?
		done()

gulp.task 'stylus', ->
	gulp.src("./src/stylus/main.styl")
		.pipe(stylus(
			use: [nib()]
		))
		.pipe(concat("main.css"))
		.pipe(gulp.dest("./compiled/css"))
		.pipe(browserSync.reload(stream: true))

gulp.task 'empty-compiled', (done) -> rimraf("./compiled", done)

gulp.task 'copy-static', -> 
	gulp.src('./static/**/*')
		.pipe(gulp.dest("./compiled"))

gulp.task 'copy-facsimiles', -> 
	gulp.src('./backend/journaal/**/*')
		.pipe(gulp.dest("./static/images/facsimiles"))

gulp.task 'compile', ['empty-compiled'], ->
	gulp.start 'copy-static', 'browserify', 'browserify-libs', 'jade', 'stylus', 

gulp.task 'jade', ->
	gulp.src('./src/index.jade')
		.pipe(jade())
		.pipe(gulp.dest("./compiled"))
		.pipe(browserSync.reload(stream: true))

gulp.task 'watch', ->
	gulp.watch ['./src/index.jade'], ['jade']
	gulp.watch ['./src/stylus/**/*.styl'], ['stylus']
	# gulp.watch ['./static/**/*'], ['copy-static']

createBundle = (watch=false) ->
	args =
		entries: './src/coffee/index.cjsx'
		extensions: ['.cjsx', '.coffee']
		debug: true

	bundler = if watch then watchify(args) else browserify(args)

	bundler.transform('coffee-reactify')

	for lib in Object.keys(cfg['exclude-libs'])
		bundler.exclude lib

	rebundle = ->
		gutil.log('Watchify rebundling') if watch
		bundler.bundle()
			.on('error', ((err) -> gutil.log("Bundling error ::: "+err)))
			.pipe(source("src.js"))
			.pipe(gulp.dest("./compiled/js"))
			.pipe(browserSync.reload({stream:true, once: true}))
			.on('error', gutil.log)

	bundler.on('update', rebundle)

	rebundle()

gulp.task 'browserify', -> createBundle false
gulp.task 'watchify', -> createBundle true

gulp.task 'browserify-libs', ->
	paths = Object.keys(cfg['exclude-libs']).map (key) -> cfg['exclude-libs'][key]

	bundler = browserify paths

	for own id, path of cfg['exclude-libs']
		bundler.require path, expose: id

	gutil.log('Browserify: bundling libs')
	bundler.bundle()
		.pipe(source("libs.js"))
		.pipe(gulp.dest("./compiled/js"))

gulp.task 'default', ['reload']