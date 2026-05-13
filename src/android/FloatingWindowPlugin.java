package com.plugin.floatv1.floatingwindow;

import android.content.Context;
import android.util.Log;
import android.os.Build;
import android.view.ViewGroup;


import androidx.annotation.RequiresApi;

import com.plugin.floatv1.floatingwindow.FloatingMainActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * Created by noah chen on 2022/1/5.
 */

public class FloatingWindowPlugin extends CordovaPlugin {
  private Context mActContext;
  private static CallbackContext mCallbackContext;

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    mActContext = this.cordova.getActivity().getApplicationContext();
    Log.i("FloatingWindowPlugin", "initialize: appContext=" + (mActContext==null?"null":"ok"));
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String video_url = args.getString(0);
    Log.i("FloatingWindowPlugin", "execute: action=" + action + ", video_url=" + (video_url==null?"null":video_url));

    //打开悬浮窗
    if (action.equals("show")) {
      mCallbackContext = callbackContext;    //拿到回调对象并保存
      final int times_cur = Integer.parseInt(args.getString(1)); //毫秒,跳到当前时间播放
      final int landscape = Integer.parseInt(args.getString(2)); // 1横屏,0竖屏
      final int is_speed = Integer.parseInt(args.getString(3)); // 1可以快进
      Log.i("FloatingWindowPlugin", "show -> scheduling initStartFloatingVideoService: is_speed="+is_speed+" landscape="+landscape+" times_cur="+times_cur);
      this.cordova.getThreadPool().execute(new Runnable() {
        @Override
        public void run() {
          try{
            Log.i("FloatingWindowPlugin", "(bg) initStartFloatingVideoService: is_speed="+is_speed+" landscape="+landscape+" times_cur="+times_cur);
            FloatingMainActivity.initStartFloatingVideoService(is_speed,landscape,video_url,times_cur,webView.getView(),mActContext,cordova,FloatingWindowPlugin.this);
          }catch(Throwable t){
            Log.e("FloatingWindowPlugin","(bg) initStartFloatingVideoService failed", t);
          }
        }
      });
      return true;
    }
    //获取悬浮信息
    else if (action.equals("get")) {
      String o_url = FloatingVideoService.videoUrl_old;
      String n_url = FloatingVideoService.videoUrl;
      long n_times =  FloatingMainActivity.getVideoDuration(); //microseconds. 以微秒为单位的锚的媒体时间
      Log.i("FloatingWindowPlugin", "get -> n_url="+n_url+" o_url="+o_url+" n_times="+n_times);
      if(n_url.compareTo("-1") == 0){
        //播放被关闭
        n_times = FloatingVideoService.times_old;
        n_url = o_url;
      }
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "|url:" + n_url+",times:" + n_times);
      pluginResult.setKeepCallback(true);
      callbackContext.sendPluginResult(pluginResult);
      return true;
    }
    else if (action.equals("close")) {
      FloatingVideoService.closeVideo();
      return true;
    }
    return false;
  }

  public static void callJS(String message) {
      if (mCallbackContext != null) {
          PluginResult dataResult = new PluginResult(PluginResult.Status.OK, message);
          dataResult.setKeepCallback(true);// 非常重要
          mCallbackContext.sendPluginResult(dataResult);
      }
  }




}
