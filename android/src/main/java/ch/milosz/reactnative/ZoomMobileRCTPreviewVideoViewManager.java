package ch.milosz.reactnative;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import us.zoom.sdk.MobileRTCVideoUnitRenderInfo;
import us.zoom.sdk.MobileRTCVideoView;

public class ZoomMobileRCTPreviewVideoViewManager extends SimpleViewManager<MobileRTCVideoView> {
    public static final String REACT_CLASS = "ZoomMobileRCTPreviewVideoView";
    ReactApplicationContext mCallerContext;

    @NonNull
    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @NonNull
    @Override
    protected us.zoom.sdk.MobileRTCVideoView createViewInstance(@NonNull ThemedReactContext reactContext) {
        return new us.zoom.sdk.MobileRTCVideoView(reactContext);
    }

    @ReactProp(name = "videoAspect")
    public void setVideoAspect(us.zoom.sdk.MobileRTCVideoView view, int aspect) {
        view.getVideoViewManager().removePreviewVideoUnit();

        MobileRTCVideoUnitRenderInfo info = new MobileRTCVideoUnitRenderInfo(0, 0, 100, 100);
        info.aspect_mode = aspect;
        view.getVideoViewManager().addPreviewVideoUnit(info);
    }

    @ReactProp(name = "userID")
    public void setUserID(us.zoom.sdk.MobileRTCVideoView view, int userID) {
        // not supported
    }

    @ReactProp(name = "renderInfo")
    public void setRenderInformation(us.zoom.sdk.MobileRTCVideoView view, ReadableMap json) {
        view.getVideoViewManager().removePreviewVideoUnit();

        if (json.hasKey("userID")) {
            int aspect = EnumConverter.toAspect(json.getString("videoAspect"));
            long userID = json.getInt("userID");

            MobileRTCVideoUnitRenderInfo info = new MobileRTCVideoUnitRenderInfo(0, 0, 100, 100);
            info.aspect_mode = aspect;
            view.getVideoViewManager().addPreviewVideoUnit(info);
        }
    }
}
