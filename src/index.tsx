import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { BrowserRouter } from 'react-router-dom';
import App from './components/app';
import './array';

declare global {
	interface Window {
		DEBUG: boolean;
	}
}

document.addEventListener('DOMContentLoaded', () => {
	const container = document.getElementById('container');
	ReactDOM.render(
		<BrowserRouter>
			<App />
		</BrowserRouter>,
		container
	);
});
