package com.plugin.floatv1.floatingwindow;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;

import android.view.Display;
import android.util.Log;
import android.view.View;
import android.widget.Toast;


import androidx.annotation.RequiresApi;

import com.zhongzilian.chestnutapp.MainActivity;
import com.zhongzilian.chestnutapp.R;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;

import static com.plugin.floatv1.floatingwindow.FloatingVideoService.mediaPlayer;

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
      Log.w("FloatingMainActivity", "onActivityResult: overlay permission NOT granted");
    } else {
      Log.i("FloatingMainActivity", "onActivityResult: overlay permission granted, starting service");
      Intent it = new Intent(FloatingMainActivity.this, FloatingVideoService.class);
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
        startForegroundService(it);
      } else {
        startService(it);
      }
    }

  }



  @RequiresApi(api = Build.VERSION_CODES.M)
  public static long getVideoDuration(){
    try{
      long t = mediaPlayer.getTimestamp().getAnchorMediaTimeUs();
      Log.d("FloatingMainActivity","getVideoDuration: " + t);
      return t;
    }catch(Exception e){
      Log.w("FloatingMainActivity","getVideoDuration failed", e);
      return 0;
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  public static void initStartFloatingVideoService(int is_speed,int landscape ,String video_url,int times_cur, View view, Context context, CordovaInterface cordova,CordovaPlugin plg) {
    try{
      Log.i("FloatingMainActivity","initStartFloatingVideoService: video_url="+video_url+" is_speed="+is_speed+" landscape="+landscape+" times_cur="+times_cur);
      FloatingVideoService.videoUrl = video_url;
      FloatingVideoService.this_context = context;
      FloatingVideoService.this_cordova = cordova;
      FloatingVideoService.this_view = view;
      FloatingVideoService.times_cur = times_cur;
      FloatingVideoService.landscape = landscape;
      FloatingVideoService.is_speed = is_speed;

      if (FloatingVideoService.isStarted) {
        Log.i("FloatingMainActivity","initStartFloatingVideoService: service already started, calling showVideo");
        FloatingVideoService.showVideo();
        return;
      }

      if (!Settings.canDrawOverlays(context)) {
        Log.w("FloatingMainActivity","initStartFloatingVideoService: overlay permission missing, requesting");
        final Intent it_power = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + context.getPackageName()));
        // startActivityForResult must run on UI thread
        try {
          cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
              cordova.startActivityForResult(plg, it_power, 2);
            }
          });
        } catch (Exception e) {
          Log.w("FloatingMainActivity","failed to request overlay permission on UI thread, calling directly", e);
          try { cordova.startActivityForResult(plg, it_power, 2); } catch (Exception ex) { Log.e("FloatingMainActivity","startActivityForResult failed", ex); }
        }
      } else {
        Log.i("FloatingMainActivity","initStartFloatingVideoService: permission present, starting service");
        Intent it = new Intent(cordova.getActivity().getBaseContext(), FloatingVideoService.class);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
          cordova.getActivity().getBaseContext().startForegroundService(it);
        } else {
          cordova.getActivity().getBaseContext().startService(it);
        }
      }
    }catch(Throwable t){
      Log.e("FloatingMainActivity","initStartFloatingVideoService failed", t);
    }



  }

}
