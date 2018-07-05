"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const React = require("react");
const ReactDOM = require("react-dom");
const react_router_dom_1 = require("react-router-dom");
const app_1 = require("./components/app");
require("./array");
document.addEventListener('DOMContentLoaded', () => {
    const container = document.getElementById('container');
    ReactDOM.render(React.createElement(react_router_dom_1.BrowserRouter, null,
        React.createElement(app_1.default, null)), container);
});
