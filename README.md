开启悬浮窗播放视频

0.添加插件命令
    
    cordova plugins  add  https://github.com/lounai-chen/cordova-plugin-floating-window.git
    


1.src\main\AndroidManifest.xml 文件 , 需手动添加以下到相应位置
   
<activity android:name="com.plugin.floatv1.floatingwindow.FloatingMainActivity"></activity>


 <service android:name="com.plugin.floatv1.floatingwindow.FloatingVideoService"></service>



2.使用案例

FloatingWindowPlugin.show(
    function(t){
    //alert('成功'+t)
    },
    function(r){
    alert('失败'+r)
    },
    'https://xxx.aliyuncs.com/media/media1.mp4'
);
