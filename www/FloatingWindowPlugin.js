var exec = require('cordova/exec');

var FloatingWindowPlugin = {
    //悬浮播放视频  
    show: function(
        success,
        error,
        video_url,
        times_cur,
        landscape,
        is_speed
    ) {
        cordova.require('cordova/channel').onCordovaReady.subscribe(function(){
            exec(success, error, 'FloatingWindowPlugin', 'show', [video_url,times_cur,landscape,is_speed]);
        });
    }, 
    get: function(
        success,
        error,
        video_url
    ) {
        exec(success, error, 'FloatingWindowPlugin', 'get', [video_url]);
    },
    close: function(
        success,
        error        
    ) {
        exec(success, error, 'FloatingWindowPlugin', 'close', ['']);
    } 
}

module.exports = FloatingWindowPlugin