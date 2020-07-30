package ch.milosz.reactnative;

import android.view.View;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import us.zoom.sdk.MobileRTCVideoUnitAspectMode;
import us.zoom.sdk.MobileRTCVideoUnitRenderInfo;
import us.zoom.sdk.MobileRTCVideoView;

public class ZoomMobileRCTViewManager extends SimpleViewManager<MobileRTCVideoView> {
    public static final String REACT_CLASS = "ZoomMobileRTCVideoView";
    ReactApplicationContext mCallerContext;

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected MobileRTCVideoView createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new MobileRTCVideoView(reactContext);
    }

    @ReactProp(name = "videoAspect")
    public void setVideoAspect(MobileRTCVideoView view, int aspect) {
        // not supported
    }

    @ReactProp(name = "userID")
    public void setUserID(MobileRTCVideoView view, int userID) {
        // not supported
    }

    @ReactProp(name = "renderInfo")
    public void setRenderInformation(MobileRTCVideoView view, ReadableMap json) {
        if (json.hasKey("userID")) {
            int aspect = EnumConverter.toAspect(json.getString("videoAspect"));
            long userID = json.getInt("userID");

            MobileRTCVideoUnitRenderInfo info = new MobileRTCVideoUnitRenderInfo(0, 0, 100, 100);
            info.aspect_mode = aspect;
            view.getVideoViewManager().addAttendeeVideoUnit(userID, info);
        }
    }
}
