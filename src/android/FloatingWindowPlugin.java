package com.plugin.floatv1.floatingwindow;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;

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
  private FloatingMainActivity fma;
  private Context mActContext;
  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    fma = new FloatingMainActivity();
    mActContext = this.cordova.getActivity().getApplicationContext();
    //初始化
    fma.initStartFloatingVideoService(this.webView.getView(),mActContext,this.cordova,this);
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String video_url = args.getString(0);
    //打开悬浮窗
    if (action.equals("show")) {
      FloatingVideoService.showVideo(video_url, mActContext);
      return true;
    }
    //获取悬浮信息
    else if (action.equals("get")) {
      String v_url = FloatingVideoService.videoUrl_old;
      long v_times =  fma.getVideoDuration(); //microseconds. 以微秒为单位的锚的媒体时间
      PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "url:" + v_url+",times:" + v_times);
      pluginResult.setKeepCallback(true);
      callbackContext.sendPluginResult(pluginResult);
      return true;
    }
    //关闭当前悬浮窗
    else if (action.equals("close")) {
      FloatingVideoService.hideVideo();
    }
    return false;
  }

}
