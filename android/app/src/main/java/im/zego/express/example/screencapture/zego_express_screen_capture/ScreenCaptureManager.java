package im.zego.express.example.screencapture.zego_express_screen_capture;

import android.annotation.SuppressLint;
import android.content.res.Resources;
import android.graphics.SurfaceTexture;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.projection.MediaProjection;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.Surface;

import androidx.annotation.RequiresApi;
import im.zego.zego_express_engine.IZegoFlutterCustomVideoCaptureHandler;
import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;
import io.flutter.Log;

public class ScreenCaptureManager implements IZegoFlutterCustomVideoCaptureHandler {

    @SuppressLint("StaticFieldLeak")
    private static ScreenCaptureManager instance;

    private MediaProjection mMediaProjection = null;

    private volatile VirtualDisplay mVirtualDisplay = null;

    private volatile int mCaptureWidth;

    private volatile int mCaptureHeight;

    private HandlerThread mHandlerThread = null;

    private Handler mHandler = null;

    private volatile Surface mSurface = null;

    private boolean isCapturing = false;

    public static ScreenCaptureManager getInstance() {
        if (instance == null) {
            synchronized (ScreenCaptureManager.class) {
                if (instance == null) {
                    instance = new ScreenCaptureManager();
                }
            }
        }
        return instance;
    }

    public void setScreenCaptureInfo(MediaProjection mediaProjection, int captureWidth, int captureHeight) {
        mMediaProjection = mediaProjection;
        mCaptureWidth = captureWidth;
        mCaptureHeight = captureHeight;
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startCapture() {
        if (mMediaProjection == null) {
            Log.e("ZEGO", "The MediaProjection instance does not exist, please call MediaProjectionCreator.createMediaProjection() function on the dart side to create an instance");
            return;
        }

        if (isCapturing) {
            Log.w("ZEGO", "Screen capture has started, skip");
            return;
        }

        mVirtualDisplay = mMediaProjection.createVirtualDisplay("ScreenCapture",
                                                                mCaptureWidth,
                                                                mCaptureHeight,
                                                                1,
                                                                DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC,
                                                                mSurface,
                                                                null,
                                                                mHandler);
        isCapturing = true;
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    public void stopCapture() {
        if(!isCapturing)
            return;

        isCapturing = false;

        if (mVirtualDisplay != null) {
            mVirtualDisplay.release();
            mVirtualDisplay = null;
        }

        if (mSurface != null) {
            mSurface.release();
            mSurface = null;
        }
    }

    @Override
    public void onStart(int channel) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            SurfaceTexture texture = ZegoCustomVideoCaptureManager.getInstance().getSurfaceTexture(channel);
            texture.setDefaultBufferSize(mCaptureWidth, mCaptureHeight);
            mSurface = new Surface(texture);

            mHandlerThread = new HandlerThread("ZegoScreenCapture");
            mHandlerThread.start();
            mHandler = new Handler(mHandlerThread.getLooper());

            startCapture();
        } else {
            Log.w("ZEGO", "The minimum system API level required for screen capture is 21");
        }
    }

    @Override
    public void onStop(int channel) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            stopCapture();

            if (mHandlerThread != null) {
                mHandlerThread.quit();
                mHandlerThread = null;
                mHandler = null;
            }

            mMediaProjection = null;
        } else {
            Log.w("ZEGO", "The minimum system API level required for screen capture is 21");
        }
    }
}
