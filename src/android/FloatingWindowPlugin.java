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

public class FloatingWindowPlugin extends CordovaPlugin {
  private FloatingMainActivity fma;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    fma = new FloatingMainActivity();
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String video_url = args.getString(0);
    //打开悬浮窗
    if (action.equals("show")) {
      Context mActContext = this.cordova.getActivity().getApplicationContext();
      fma.startFloatingVideoService(video_url,this.webView.getView(),mActContext,this.cordova,this);
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
    return false;
  }

}
