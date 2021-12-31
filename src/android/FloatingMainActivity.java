package com.zhongzilian.chestnutapp;

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

import com.plugin.aliyun.FileUpload;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;

public  class FloatingMainActivity extends CordovaActivity {
  
    @Override
    public void onCreate(Bundle savedInstanceState) {
       super.onCreate(savedInstanceState);
       setContentView(R.layout.activity_main);
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == 0) {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(this, "授权失败", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "授权成功", Toast.LENGTH_SHORT).show();
                startService(new Intent(FloatingMainActivity.this, FloatingButtonService.class));
            }
        } else if (requestCode == 1) {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(this, "授权失败", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "授权成功", Toast.LENGTH_SHORT).show();
                startService(new Intent(FloatingMainActivity.this, FloatingImageDisplayService.class));
            }
        } else if (requestCode == 2) {
            if (!Settings.canDrawOverlays(this)) {
                Toast.makeText(this, "授权失败", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(this, "授权成功", Toast.LENGTH_SHORT).show();
                startService(new Intent(FloatingMainActivity.this, FloatingVideoService.class));
            }
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public void startFloatingButtonService(View view) {
        if (FloatingButtonService.isStarted) {
            return;
        }
        if (!Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "当前无权限，请授权", Toast.LENGTH_SHORT);
            startActivityForResult(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getPackageName())), 0);
        } else {
            startService(new Intent(FloatingMainActivity.this, FloatingButtonService.class));
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.M)
    public void startFloatingImageDisplayService(View view) {
        if (FloatingImageDisplayService.isStarted) {
            return;
        }
        if (!Settings.canDrawOverlays(this)) {
            Toast.makeText(this, "当前无权限，请授权", Toast.LENGTH_SHORT);
            startActivityForResult(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getPackageName())), 1);
        } else {
            startService(new Intent(FloatingMainActivity.this, FloatingImageDisplayService.class));
        }
    }


  @RequiresApi(api = Build.VERSION_CODES.M)
  public  void startFloatingVideoService(View view, Context context, CordovaInterface cordova) {
    if (FloatingVideoService.isStarted) {
      return;
    }
    if (!Settings.canDrawOverlays(context)) {
      Toast.makeText(context, "当前无权限，请授权", Toast.LENGTH_SHORT);
      startActivityForResult(new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getPackageName())), 2);
    } else {
      Intent it = new Intent(context, FloatingVideoService.class);
      cordova.getActivity().startService(it);
    }
  }

}
