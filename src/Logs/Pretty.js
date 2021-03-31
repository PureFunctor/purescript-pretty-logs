"use strict";

exports.logPretty_ = function (message) {
    return function (styling) {
	return function () {
	    console.log(message, ...styling);
	}
    }
}
