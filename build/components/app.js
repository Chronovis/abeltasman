"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const React = require("react");
const react_router_dom_1 = require("react-router-dom");
const react_redux_1 = require("react-redux");
const react_router_redux_1 = require("react-router-redux");
const store_1 = require("../store");
const history_1 = require("../store/history");
const home_1 = require("./home");
const Wrapper = (props) => React.createElement("div", { style: {
        display: 'grid',
        gridTemplateColumns: '100vw',
        gridTemplateRows: '10vh 90vh',
    } }, props.children);
exports.default = () => (React.createElement(react_redux_1.Provider, { store: store_1.default },
    React.createElement(react_router_redux_1.ConnectedRouter, { history: history_1.default },
        React.createElement(Wrapper, null,
            React.createElement(react_router_dom_1.Route, { component: home_1.default, exact: true, path: "/" })))));
