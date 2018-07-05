export const dummy = null;

declare global {
	interface Array<T> {
		first(): T;
		last(): T;
		pickRandom(): T;
	}
}

Array.prototype.first = function () {
	return this[0];
};

Array.prototype.last = function () {
	return this[this.length - 1];
};

Array.prototype.pickRandom = function () {
	return this[Math.floor(Math.random() * this.length)];
};
