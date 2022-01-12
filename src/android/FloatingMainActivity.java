package com.plugin.floatv1.floatingwindow;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Toast;


import com.zhongzilian.chestnutapp.MainActivity;
import com.zhongzilian.chestnutapp.R;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;

/**
 * Created by noah chen on 2022/1/5.
 */

public  class FloatingMainActivity extends CordovaActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Intent intent2 = this.getPackageManager().getLaunchIntentForPackage(this.getPackageName());
    this.startActivity(intent2);
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data) {

    if (!Settings.canDrawOverlays(this)) {
      Toast.makeText(this, "授权失败", Toast.LENGTH_SHORT).show();
    } else {
      Toast.makeText(this, "授权成功", Toast.LENGTH_SHORT).show();
      startService(new Intent(FloatingMainActivity.this, FloatingVideoService.class));
    }

  }



  @RequiresApi(api = Build.VERSION_CODES.M)
  public long getVideoDuration(){
    return FloatingVideoService.mediaPlayer.getTimestamp().getAnchorMediaTimeUs();
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  public  void initStartFloatingVideoService(int landscape ,String video_url,int times_cur, View view, Context context, CordovaInterface cordova,CordovaPlugin plg) {

    FloatingVideoService.videoUrl = video_url;
    FloatingVideoService.this_context = context;
    FloatingVideoService.this_cordova = cordova;
    FloatingVideoService.this_view = view;
    FloatingVideoService.times_cur = times_cur;
    FloatingVideoService.landscape = landscape;

    if (FloatingVideoService.isStarted) {
      FloatingVideoService.showVideo();
      return;
    }

    if (!Settings.canDrawOverlays(context)) {
      Toast.makeText(context, "当前无权限，请授权", Toast.LENGTH_SHORT);
      Intent it_power = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + context.getPackageName()));
      cordova.startActivityForResult(plg, it_power, 2);
    } else {
      Intent it = new Intent(cordova.getActivity().getBaseContext(), FloatingVideoService.class);
      cordova.getActivity().getBaseContext().startService(it);
    }



  }

}
