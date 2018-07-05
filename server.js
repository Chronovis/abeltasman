#!/usr/bin/env node

const browserSync = require('browser-sync').create();
const modRewrite = require('connect-modrewrite');
const debounce = require('lodash.debounce');
const proxy = require('proxy-middleware');
const url = require('url');

const baseDir = './';
const watchFiles = [
	baseDir + 'build/**/*.js',
	baseDir + 'build/**/*.css',
	'./index.html'
];

const onFilesChanged = (event, file) => {
	if (event === 'change') {
		browserSync.reload(file);
	}
};

browserSync.watch(watchFiles, debounce(onFilesChanged, 300));

const proxyOptions = url.parse('http://janus:8080');
proxyOptions.route = '/api';

const proxyOptions2 = url.parse('http://elasticsearch:9200');
proxyOptions2.route = '/es';

browserSync.init({
	server: {
		baseDir: [baseDir],
		middleware: [
			proxy(proxyOptions),
			proxy(proxyOptions2),
			modRewrite([
				'^/css/(.*)$ /css/$1 [L]',
				'^/js/(.*)$ /js/$1 [L]',
				'^/images/(.*)$ /images/$1 [L]',
				'^/fonts/(.*)$ /fonts/$1 [L]',
				'^[^\\.]*$ /index.html [L]'
			])
		]
	}
});
