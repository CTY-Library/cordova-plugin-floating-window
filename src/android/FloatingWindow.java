import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
 
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
 
 

 

/**
 * This class echoes a string called from JavaScript.
 */
public class FloatingWindow extends CordovaPlugin {
 
  private static Context context_all;
 
  /**
   * Called after plugin construction and fields have been initialized. Prefer to
   * use pluginInitialize instead since there is no value in having parameters on
   * the initialize() function.
   *
   * @param cordova
   * @param webView
   */
  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);
    Context context = this.cordova.getActivity().getApplicationContext();
    context_all = context; 
     

    if (floatClickListener == null) {
        floatClickListener = new FloatClickListener(callbackContext);
        floatWindowAndroid.setOnClickListener(floatClickListener);
    }
    if (SettingsCompat.canDrawOverlays(cordova.getActivity())) {
        //有悬浮窗权限开启服务绑定 绑定权限
        floatWindowAndroid.showFloatButton(content);
    } else {
        try {
            SettingsCompat.manageDrawOverlays(cordova.getActivity());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


      // 悬浮窗显示视图
        LayoutInflater layoutInflater = LayoutInflater.from(activity);
        mShowView = layoutInflater.inflate(R.layout.video_floating_window_layout, null);;
        // 获取系统窗口管理服务
        mWindowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
        // 悬浮窗口参数设置及返回
        mFloatParams = getParams();
        //floatingWindow内部控件实例
        init(view);
        // 设置窗口触摸移动事件
        mShowView.setOnTouchListener(new FloatViewMoveListener());

        // 悬浮窗生成
        mWindowManager.addView(mShowView, mFloatParams);
 
  }

  @Override
  public boolean execute(String action, JSONArray args,final CallbackContext callbackContext) throws JSONException {
    //普通上传
    if (action.equals("show")) {
      
      return true;
    }
     
    return false;
  }
 
 
 
}
