var exec = require('cordova/exec');

var FloatingWindowPlugin = {
    //悬浮播放视频  
    show: function(
        success,
        error,
        video_url
    ) {
        exec(success, error, 'FloatingWindowPlugin', 'show', [video_url]);
    }, 
    get: function(
        success,
        error,
        video_url
    ) {
        exec(success, error, 'FloatingWindowPlugin', 'get', [video_url]);
    }
}

module.exports = FloatingWindowPlugin