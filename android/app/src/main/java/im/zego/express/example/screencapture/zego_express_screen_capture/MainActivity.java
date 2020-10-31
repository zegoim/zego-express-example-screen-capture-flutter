package im.zego.express.example.screencapture.zego_express_screen_capture;
import android.content.res.Resources;
import android.graphics.SurfaceTexture;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.projection.MediaProjection;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.Surface;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import im.zego.media_projection_creator.MediaProjectionCreatorCallback;
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager;
import im.zego.zego_express_engine.IZegoFlutterCustomVideoCaptureHandler;
import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    private HandlerThread handlerThread;

    private Handler handler;

    private MediaProjection mediaProjection;

    private VirtualDisplay virtualDisplay;

    private Surface surface;

    private boolean isCapturing = false;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        /// Example: developers should call this method to set callback,
        /// when dart call `createMediaProjection`, it would be return a MediaProjection through this callback
        RequestMediaProjectionPermissionManager.getInstance().setRequestPermissionCallback(mediaProjectionCreatorCallback);

        ZegoCustomVideoCaptureManager.getInstance().setCustomVideoCaptureHandler(customVideoCaptureHandler);
    }

    private final MediaProjectionCreatorCallback mediaProjectionCreatorCallback = new MediaProjectionCreatorCallback() {

        @Override
        public void onMediaProjectionCreated(MediaProjection projection, int errorCode) {
            if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_SUCCEED) {
                Log.i("ZEGO", "Create media projection succeeded!");
                mediaProjection = projection;
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_USER_CANCELED) {
                Log.e("ZEGO", "Create media projection failed because can not get permission");
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW) {
                Log.e("ZEGO", "Create media projection failed because system api level is lower than 21");
            }
        }
    };

    private final IZegoFlutterCustomVideoCaptureHandler customVideoCaptureHandler = new IZegoFlutterCustomVideoCaptureHandler() {
        @Override
        public void onStart(int channel) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                startCapture();
            } else {
                Log.w("ZEGO", "The minimum system API level required for screen capture is 21");
            }
        }

        @Override
        public void onStop(int channel) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                stopCapture();
            } else {
                Log.w("ZEGO", "The minimum system API level required for screen capture is 21");
            }
        }
    };

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void startCapture() {
        if (isCapturing) {
            Log.w("ZEGO", "Screen capture has started, skip");
            return;
        }

        if (mediaProjection == null) {
            Log.e("ZEGO", "The MediaProjection instance does not exist, please call MediaProjectionCreator.createMediaProjection() function on the dart side to create an instance");
            return;
        }

        isCapturing = true;

        handlerThread = new HandlerThread("ZegoExpressFlutterScreenCapture");
        handlerThread.start();
        handler = new Handler(handlerThread.getLooper());

        SurfaceTexture texture = ZegoCustomVideoCaptureManager.getInstance().getSurfaceTexture(0);
        texture.setDefaultBufferSize(getScreenWidth(), getScreenHeight());
        surface = new Surface(texture);

        virtualDisplay = mediaProjection.createVirtualDisplay(
                "ScreenCapture", getScreenWidth(), getScreenHeight(), 1,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC, surface, null, handler);
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    private void stopCapture() {

        if (!isCapturing) {
            Log.w("ZEGO", "Screen capture has stopped, skip");
            return;
        }

        isCapturing = false;

        if (virtualDisplay != null) {
            virtualDisplay.release();
            virtualDisplay = null;
        }

        mediaProjection = null;

        if (surface != null) {
            surface.release();
            surface = null;
        }

        if (handlerThread != null) {
            handlerThread.quit();
            handlerThread = null;
            handler = null;
        }
    }

    private int getScreenWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    private int getScreenHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }
}
