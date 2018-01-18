var _ = require("lodash");
var Promise = require("bluebird");

module.exports = {
    assertEvent: function(contract, filter,callback) {
        return new Promise((resolve, reject) => {
            var event = contract[filter.event]();
            event.watch();
            event.get((error, logs) => {
                var log = _.filter(logs, filter);
                if (!_.isEmpty(log)) {
                    resolve(log);
                    callback(log);
                } else {
                    throw Error("Failed to find filtered event for " + filter.event);
                }
            });
            event.stopWatching();
        });
    },
    toAscii: function(hex) {
        hex = hex.split("00")[0];
        var str = "";
        var i = 0, l = hex.length;
        if (hex.substring(0, 2) === '0x') {
            i = 2;
        }
        for (; i < l; i+=2) {
            var code = parseInt(hex.substr(i, 2), 16);
            str += String.fromCharCode(code);
        }
        return str;
    }
}