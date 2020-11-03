package im.zego.express.example.screencapture.zego_express_screen_capture;

import android.content.res.Resources;
import android.media.projection.MediaProjection;
import android.os.Bundle;

import androidx.annotation.Nullable;

import im.zego.media_projection_creator.MediaProjectionCreatorCallback;
import im.zego.media_projection_creator.RequestMediaProjectionPermissionManager;

import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;
import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        /// Example: developers should call this method to set callback,
        /// when dart call `createMediaProjection`, it would be return a MediaProjection through this callback
        RequestMediaProjectionPermissionManager.getInstance().setRequestPermissionCallback(mediaProjectionCreatorCallback);

        ZegoCustomVideoCaptureManager.getInstance().setCustomVideoCaptureHandler(ScreenCaptureManager.getInstance());
    }

    private final MediaProjectionCreatorCallback mediaProjectionCreatorCallback = new MediaProjectionCreatorCallback() {

        @Override
        public void onMediaProjectionCreated(MediaProjection projection, int errorCode) {
            if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_SUCCEED) {
                Log.i("ZEGO", "Create media projection succeeded!");
                ScreenCaptureManager.getInstance().setScreenCaptureInfo(projection, getScreenWidth(), getScreenHeight());
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_USER_CANCELED) {
                Log.e("ZEGO", "Create media projection failed because can not get permission");
            } else if (errorCode == RequestMediaProjectionPermissionManager.ERROR_CODE_FAILED_SYSTEM_VERSION_TOO_LOW) {
                Log.e("ZEGO", "Create media projection failed because system api level is lower than 21");
            }
        }
    };

    private int getScreenWidth() {
        return Resources.getSystem().getDisplayMetrics().widthPixels;
    }

    private int getScreenHeight() {
        return Resources.getSystem().getDisplayMetrics().heightPixels;
    }
}
