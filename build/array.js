"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dummy = null;
Array.prototype.first = function () {
    return this[0];
};
Array.prototype.last = function () {
    return this[this.length - 1];
};
Array.prototype.pickRandom = function () {
    return this[Math.floor(Math.random() * this.length)];
};
