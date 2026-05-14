cordova插件,开启悬浮窗播放视频,画中画

0.添加插件命令 
``` 
cordova plugins  add  https://github.com/lounai-chen/cordova-plugin-floating-window.git  

```

    


1.1 安卓 src\main\AndroidManifest.xml 文件 , 需手动添加以下到相应位置  

 ```
 <activity android:name="com.plugin.floatv1.floatingwindow.FloatingMainActivity"></activity>  
 

 <service android:name="com.plugin.floatv1.floatingwindow.FloatingVideoService"></service>  
```  
1.2 iOS 必要配置

- 在 Xcode 的 Signing & Capabilities 面板，添加 Background Modes，并勾选 Audio, AirPlay, and Picture in Picture。
- 宿主工程需要支持横竖屏（否则 iOS 16+ 的主动旋转会失败）。建议在宿主 `config.xml` 增加：

```
<platform name="ios">
    <preference name="Orientation" value="all" />
</platform>
```

- 插件已在 iOS 端使用 `UIWindowScene requestGeometryUpdate`（iOS 16+）主动请求方向切换；低版本自动使用 `attemptRotationToDeviceOrientation` 兜底。




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
    300, //毫秒,跳到当前时间播放
    1    //可以快进
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
    300,1 //毫秒,跳到当前时间播放
);
```
如果是同一个URL，第二次打开可直接调用 FloatingWindowPlugin.get 方法  

![avatar](/demo/picture/1.jpg)
![avatar](/demo/picture/2.png)

