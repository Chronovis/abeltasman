"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const redux_1 = require("redux");
const react_router_redux_1 = require("react-router-redux");
const redux_thunk_1 = require("redux-thunk");
const history_1 = require("./history");
const reducers_1 = require("../reducers");
const logger = () => next => action => {
    if (window.DEBUG && action.hasOwnProperty('type')) {
        console.log('[REDUX]', action.type, action);
    }
    return next(action);
};
const middleware = react_router_redux_1.routerMiddleware(history_1.default);
const store = redux_1.createStore(reducers_1.default, redux_1.applyMiddleware(middleware, redux_thunk_1.default, logger));
exports.default = store;
