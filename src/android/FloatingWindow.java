package com.plugin.testforfloatingwindow;

import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;

import com.zhongzilian.chestnutapp.FloatingMainActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

public class FloatingWindow extends CordovaPlugin {
  private FloatingMainActivity fma;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    fma = new FloatingMainActivity();
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
    //打开悬浮窗
    if (action.equals("show")) {
      Context mActContext = this.cordova.getActivity().getApplicationContext();
      fma.startFloatingVideoService(this.webView.getView(),mActContext,this.cordova);
      return true;
    }

    return false;
  }

}
