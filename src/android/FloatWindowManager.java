import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;
 
 
 
public class FloatWindowManager extends CordovaPlugin {
 
  private static final FloatWindowManager instance = new FloatWindowManager();
  
  public static FloatWindowManager getInstance() {
      return instance;
  }
 
}

 