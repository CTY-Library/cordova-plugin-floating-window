开启悬浮窗播放视频

0.添加插件命令  
`cordova plugins  add  https://github.com/lounai-chen/cordova-plugin-floating-window.git`  

    


1. 安卓 src\main\AndroidManifest.xml 文件 , 需手动添加以下到相应位置  

 ```
 <activity android:name="com.plugin.floatv1.floatingwindow.FloatingMainActivity"></activity>  
 

 <service android:name="com.plugin.floatv1.floatingwindow.FloatingVideoService"></service>  
```  
IOS 需手动 Signing & Capabilities 面板， 添加 Background Modes ,并选中第一个复选框 Audio, AirPlay, And Picture in Picture  




2.1 使用案例 (android)
```
FloatingWindowPlugin.show(
    function(t){
        alert('成功'+t) // 点击关闭按钮,就会触发这个回调 (返回的是 microseconds. 以微秒为单位的锚的媒体播放时间 )
    },
    function(r){
        alert('失败'+r)
    },
    'https://xxx.aliyuncs.com/media/media1.mp4',
    300 //毫秒,跳到当前时间播放
);
```


2.2 使用案例 (ios)
```
FloatingWindowPlugin.show(
    function(re){ 
        setTimeout(() => {
            FloatingWindowPlugin.get( function(t){
                alert('成功'+t) // 点击关闭按钮,就会触发这个回调 (返回的是 microseconds. 以微秒为单位的锚的媒体播放时间 )
            },
            function(r){
                alert('失败'+r)
            },'') ;
        }, 300); //定时器300毫秒
    },
    function(r){
        alert('失败'+r)
    },
    'https://xxx.aliyuncs.com/media/media1.mp4',
    300 //毫秒,跳到当前时间播放
);
```
如果是同一个URL，第二次打开可直接调用 FloatingWindowPlugin.get 方法  
