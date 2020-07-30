package ch.milosz.reactnative;

import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import us.zoom.sdk.InMeetingService;
import us.zoom.sdk.InMeetingShareController;
import us.zoom.sdk.InMeetingVideoController;
import us.zoom.sdk.MobileRTCVideoUnitRenderInfo;
import us.zoom.sdk.MobileRTCVideoView;
import us.zoom.sdk.ZoomSDK;

public class ZoomMobileRCTActiveVideoViewManager extends SimpleViewManager<MobileRTCVideoView> {
    public static final String REACT_CLASS = "ZoomMobileRCTActiveVideoView";
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
        Log.i("RNZoomUs", "ActivedVideo setUserID: " + userID);

        if (userID == 0) return;

        view.getVideoViewManager().removeAttendeeVideoUnit(userID);
        view.getVideoViewManager().addAttendeeVideoUnit(userID, info);
        view.getVideoViewManager().addActiveVideoUnit(info);
    }
}
