package com.plugin.floatv1.floatingwindow;

import android.app.Activity;
import android.app.Service;
import android.arch.lifecycle.Observer;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.provider.Settings;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.zhongzilian.chestnutapp.MainActivity;
import com.zhongzilian.chestnutapp.R;

import org.apache.cordova.CordovaInterface;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Date;

/**
 * Created by noah chen on 2022/1/5.
 */

public class FloatingVideoService extends Service  {
  public static boolean isStarted = false;
  public static String videoUrl;
  public static String videoUrl_old;
  public static long times_old;
  public static int times_cur = 0;
  public static LocalDateTime beginPlayer;
  private WindowManager windowManager;
  public static WindowManager.LayoutParams layoutParams;

  public static MediaPlayer mediaPlayer;
  public static View displayView;
  public static Context this_context;
  public static CordovaInterface this_cordova;
  public static View this_view;
  public static RelativeLayout video_display_relativeLayout;
  public static int  landscape = 1;

  public static int layoutParamsWidth = 255;
  public static int layoutParamsHeight = 146;
  public static int  isUpAdd = 1;
  public static int  iCountViewBigger = 2;
  public static int  iCountViewShow = 1;
  private static final int TOUCH_MOVE = 1;//自定义移动
  private static final int TOUCH_CLICK = 2;//自定义单击
  private static final int TOUCH_DOUBLE_CLICK = 3;//自定义双击
  private static final int  TOUCH_ACTION_DOWN = 4;

  private static final long singleClickDurationTime = 200;//常量200ms，抬按时间差
  private static final long doubleClickDurationTime = 300;//常量300ms，两次点击时间差

  private long touchDownTime = -1;//触点按下时间
  private long lastSingleClickTime = -1;//上次发生点击的时刻

  @Override
  public void onCreate() {
    super.onCreate();
    isStarted = true;
    windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
    layoutParams = new WindowManager.LayoutParams();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      layoutParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
    } else {
      layoutParams.type = WindowManager.LayoutParams.TYPE_PHONE;
    }
    layoutParams.format = PixelFormat.RGBA_8888;
    layoutParams.gravity = Gravity.LEFT | Gravity.TOP;
    layoutParams.flags = WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL | WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;

    layoutParams.x = 100;
    layoutParams.y = 100;

    if(landscape==1){
      layoutParams.width = layoutParamsWidth*iCountViewBigger;
      layoutParams.height = layoutParamsHeight*iCountViewBigger;
    }else{
      layoutParams.width = layoutParamsHeight*iCountViewBigger;
      layoutParams.height = layoutParamsWidth*iCountViewBigger;
    }

    mediaPlayer = new MediaPlayer();
  }

  @Nullable
  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  @Override
  public int onStartCommand(Intent intent, int flags, int startId) {
    showFloatingWindow();
    return super.onStartCommand(intent, flags, startId);
  }

  //合成自定义的事件类型
  private int customTouchType(MotionEvent event){
    //要返回的自定义事件类型值
    int touchType = -1;
    //得到原始触屏事件动作
    int action = event.getAction();
    //若发生触屏移动原始动作
    if(action == MotionEvent.ACTION_MOVE){
      //得到当前时刻与上一次按下时刻时间差
      long deltaTime = System.currentTimeMillis() - touchDownTime;
      //只有当抬起和按下时间差大于200ms才被认定为自定义触屏事件
      if(deltaTime > singleClickDurationTime){
        //自定义触屏移动事件
        touchType = TOUCH_MOVE;
      }
     // touchType = TOUCH_MOVE;
    }
    //若发生按下原始事件
    else if(action == MotionEvent.ACTION_DOWN){
      //记录下按下时间
      touchDownTime = System.currentTimeMillis();
      touchType = TOUCH_ACTION_DOWN;
    }
    //若发生抬起原始事件
    else if(action == MotionEvent.ACTION_UP){
      //记录下抬起时间
      long touchUpTime = System.currentTimeMillis();
      //抬起按下的时间差
      long downUpDurationTime = touchUpTime - touchDownTime;
      //若抬起按下时间差小于200ms则表示发生点击事件
      Log.println( Log.ERROR ,"","1:"+downUpDurationTime);
      if(downUpDurationTime <= singleClickDurationTime){
        touchType = TOUCH_CLICK;
        //计算这次抬起事件距离上次点击的时间差
        long twoClickDurationTime = touchUpTime - lastSingleClickTime;
        //若两次点击事件时间差小于300ms则表示发生双击事件
        if(twoClickDurationTime <=  doubleClickDurationTime){
          //自定义双击事件
          touchType = TOUCH_DOUBLE_CLICK;
          //由于已经确定最近的上一次点击事件的类型，可以重置变量
          lastSingleClickTime = -1;
          touchDownTime = -1;
        }
        //若两次点击事件时间差大于300ms，则之前那次的点击一定是单击，
        //而这次触屏点击需要经过300ms后才能判断类型到底是不是双击
        else{
          //保存本次点击事件时刻
          lastSingleClickTime = touchUpTime;
        }
      }
    }
    //返回自定义事件类型
    return touchType;
  }


  @RequiresApi(api = Build.VERSION_CODES.M)
  public static void hideVideo()
  {
    long cur_times = mediaPlayer.getTimestamp().getAnchorMediaTimeUs();

    videoUrl = "-1";
    times_old = mediaPlayer.getTimestamp().getAnchorMediaTimeUs();
    mediaPlayer.pause();
    mediaPlayer.reset();

    displayView.setVisibility(View.GONE);    // 隐藏 view
    displayView.destroyDrawingCache();
    displayView.clearAnimation();
    displayView.cancelLongPress();
    displayView.clearFocus();

    isStarted = false;

    FloatingWindowPlugin.callJS(""+cur_times);

    Intent it = new Intent(this_cordova.getActivity().getBaseContext(), FloatingVideoService.class);
    this_cordova.getActivity().getBaseContext().stopService(it);
  }

  public  static   void closeVideo() {
    video_display_relativeLayout.postInvalidate();
    video_display_relativeLayout.post(new Runnable(){
      @RequiresApi(api = Build.VERSION_CODES.M)
      @Override
      public void run() {
        Intent it = new Intent(this_cordova.getActivity().getBaseContext(), FloatingVideoService.class);
        this_cordova.getActivity().getBaseContext().stopService(it);
        video_display_relativeLayout.setVisibility(View.GONE);    // 隐藏 view
        isStarted = false;
        long cur_times = mediaPlayer.getTimestamp().getAnchorMediaTimeUs();
        FloatingWindowPlugin.callJS(""+cur_times);
        videoUrl = "-1";
        mediaPlayer.pause();
        mediaPlayer.reset();
      }
    });

  }

  public static void showVideo(){
    try {

      isStarted = true;
      videoUrl_old = videoUrl;
      mediaPlayer.reset();
      mediaPlayer.setDataSource(this_context, Uri.parse(videoUrl));
      mediaPlayer.prepare(); //.prepareAsync(); //
      mediaPlayer.start();
      mediaPlayer.seekTo(times_cur); //毫秒,跳到当前时间播放
      FloatingWindowPlugin.callJS("-1");
      //this_cordova.getActivity().finish();//关闭主窗口,回到手机的首页

    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  // @RequiresApi(api = Build.VERSION_CODES.O)
  private void showFloatingWindow() {
    if (Settings.canDrawOverlays(this)) {
      LayoutInflater layoutInflater = LayoutInflater.from(this);
      displayView = layoutInflater.inflate(R.layout.video_display, null);
      video_display_relativeLayout = displayView.findViewById(R.id.video_display_relativeLayout);

      displayView.setVisibility(View.VISIBLE); // 显示 view
      displayView.setOnTouchListener(new FloatingOnTouchListener());
      mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
      SurfaceView surfaceView = displayView.findViewById(R.id.video_display_surfaceview);
      final SurfaceHolder surfaceHolder = surfaceView.getHolder();
      surfaceHolder.addCallback(new SurfaceHolder.Callback() {
        @Override
        public void surfaceCreated(SurfaceHolder holder) {
          mediaPlayer.setDisplay(surfaceHolder);
          showVideo();
        }

        @Override
        public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

        }

        @Override
        public void surfaceDestroyed(SurfaceHolder holder) {

        }
      });
      mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
        @Override
        public void onPrepared(MediaPlayer mp) {

        }
      });

      ImageView closeImageView =   displayView.findViewById(R.id.iv_close_window);
      closeImageView.setOnClickListener(  new  ImageView.OnClickListener() {
        @Override
        public void onClick(View v) {
          // 关闭悬浮窗事件
          hideVideo();
        }
      });


      // 关闭悬浮窗并且回到主窗口事件
      ImageView  goMainImageView =   displayView.findViewById(R.id.iv_zoom_main_btn);
      goMainImageView.setOnClickListener(  new  ImageView.OnClickListener() {
        @Override
        public void onClick(View v) {

          /**将被挤压到后台的本应用重新置顶到最前端
           * 当自己的应用在后台时，将它切换到前台来*/
          FloatingSystemHelper.setTopApp(this_cordova.getActivity().getBaseContext());
          FloatingWindowPlugin.callJS("-2");
        }
      });

//      surfaceView.setOnClickListener( new  ImageView.OnClickListener() {
//        @Override
//        public void onClick(View v) {
//          iCountViewShow++;
//          // 显示,隐藏 按钮
//          if(iCountViewShow % 2 == 0) {
//            closeImageView.setVisibility(View.VISIBLE);
//            goMainImageView.setVisibility(View.VISIBLE);
//          }else{
//            closeImageView.setVisibility(View.GONE);
//            goMainImageView.setVisibility(View.GONE);
//          }
//        }
//      });

      windowManager.addView(displayView, layoutParams);
    }
  }


  private class FloatingOnTouchListener implements View.OnTouchListener {
    private int x;
    private int y;

    @Override
    public boolean onTouch(View view, MotionEvent event) {
      ImageView  goMainImageView =   displayView.findViewById(R.id.iv_zoom_main_btn);
      ImageView closeImageView =   displayView.findViewById(R.id.iv_close_window);

      //通过调用customTouchType方法，得到我们自定义的事件类型
      int touchType = customTouchType(event);
      //若自定义触屏事件是触屏移动
      if(touchType == TOUCH_ACTION_DOWN) {
        //当发生触屏移动事件，执行某方法
        x = (int) event.getRawX();
        y = (int) event.getRawY();
      }
      else if(touchType == TOUCH_MOVE) {
        //当发生触屏移动事件，执行某方法
        int nowX = (int) event.getRawX();
        int nowY = (int) event.getRawY();
        int movedX = nowX - x;
        int movedY = nowY - y;
        x = nowX;
        y = nowY;
        layoutParams.x = layoutParams.x + movedX;
        layoutParams.y = layoutParams.y + movedY;
        windowManager.updateViewLayout(view, layoutParams);

      }
      //若自定义触屏事件为双击事件
      else if(touchType == TOUCH_DOUBLE_CLICK){
        //changViewHeightWidth();
        //当发生双击事件，执行某方法
        if( iCountViewBigger == 4){
          isUpAdd = 0; //减
        }
        if (iCountViewBigger == 2 ){
          isUpAdd = 1; //加
        }

        if(isUpAdd == 1){
          iCountViewBigger++;
        }else{
          iCountViewBigger--;
        }
        if(landscape==1){
          layoutParams.width = layoutParamsWidth*iCountViewBigger;
          layoutParams.height = layoutParamsHeight*iCountViewBigger;
        }else{
          layoutParams.width = layoutParamsHeight*iCountViewBigger;
          layoutParams.height = layoutParamsWidth*iCountViewBigger;
        }
        windowManager.updateViewLayout(view, layoutParams);
       // Log.println( Log.ERROR,"","TOUCH_DOUBLE_CLICK:"+iCountViewBigger+",width:"+layoutParams.width+",height:"+layoutParams.height);
      }
      else if( touchType == TOUCH_CLICK){
        iCountViewShow++;
        // 显示,隐藏 按钮
        if(iCountViewShow % 2 == 0) {
          closeImageView.setVisibility(View.VISIBLE);
          goMainImageView.setVisibility(View.VISIBLE);
        }else{
          closeImageView.setVisibility(View.GONE);
          goMainImageView.setVisibility(View.GONE);
        }
      }

      return true;

    }
  }
}
