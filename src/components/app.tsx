import * as React from 'react';
import {Route} from 'react-router-dom';
import { Provider } from 'react-redux';
import { ConnectedRouter } from 'react-router-redux'
import store from "../store";
import history from '../store/history';
import Home from './home';

const Wrapper: React.SFC = (props) =>
	<div
		style={{
			display: 'grid',
			gridTemplateColumns: '100vw',
			gridTemplateRows: '10vh 90vh',
		}}
	>
		{props.children}
	</div>

export default () => (
	<Provider store={store}>
		<ConnectedRouter history={history}>
			<Wrapper>
				<Route
					component={Home}
					exact
					path="/"
				/>
			</Wrapper>
		</ConnectedRouter>
	</Provider>
);
