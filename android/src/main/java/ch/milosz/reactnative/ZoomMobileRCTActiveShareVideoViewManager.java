package ch.milosz.reactnative;

import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import us.zoom.sdk.MobileRTCVideoUnitRenderInfo;
import us.zoom.sdk.MobileRTCVideoView;

public class ZoomMobileRCTActiveShareVideoViewManager extends SimpleViewManager<MobileRTCVideoView> {
    public static final String TAG = "RNZoomUs";
    public static final String REACT_CLASS = "ZoomMobileRCTActiveShareVideoView";
    ThemedReactContext mCallerContext;
    MobileRTCVideoUnitRenderInfo info = new MobileRTCVideoUnitRenderInfo(0, 0, 100, 100);
    boolean isRendered = false;

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected MobileRTCVideoView createViewInstance(@NonNull ThemedReactContext reactContext) {
        mCallerContext = reactContext;
        return new MobileRTCVideoView(reactContext.getCurrentActivity());
    }

    @ReactProp(name = "videoAspect")
    public void setVideoAspect(MobileRTCVideoView view, String videoAspect) {
        int aspect = EnumConverter.toAspect(videoAspect);
        info.aspect_mode = aspect;
    }

    @ReactProp(name = "userID")
    public void setUserID(MobileRTCVideoView view, int userID) {
        Log.i("RNZoomUs", "SharedVideo setUserID: " + userID);
        if (userID == 0) return;

        view.getVideoViewManager().removeAttendeeVideoUnit(userID);
        view.getVideoViewManager().addAttendeeVideoUnit(userID, info);
        view.getVideoViewManager().addActiveVideoUnit(info);
        view.getVideoViewManager().addPreviewVideoUnit(info);
    }
}