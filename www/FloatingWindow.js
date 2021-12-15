var exec = require('cordova/exec');

var thisFloatingWindow = {
    //上传  
    show: function(
        success,
        error,
        data,
    ) {
        exec(success, error, 'FloatingWindow', 'show', data);
    } 
}

module.exports = thisFloatingWindow