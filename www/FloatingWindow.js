var exec = require('cordova/exec');

var FloatingWindow = {
    //悬浮播放视频  
    show: function(
        success,
        error,
        video_url
    ) {
        exec(success, error, 'FloatingWindow', 'show', video_url);
    } 
}

module.exports = FloatingWindow