package ch.milosz.reactnative;

import us.zoom.sdk.MobileRTCVideoUnitAspectMode;

public class EnumConverter {
    static int toAspect(String aspect) {
        switch(aspect) {
            case "letterBox": return MobileRTCVideoUnitAspectMode.VIDEO_ASPECT_LETTER_BOX;
            case "panAndScan": return MobileRTCVideoUnitAspectMode.VIDEO_ASPECT_PAN_AND_SCAN;
            case "fullFilled": return MobileRTCVideoUnitAspectMode.VIDEO_ASPECT_FULL_FILLED;
            case "original":
            default: return MobileRTCVideoUnitAspectMode.VIDEO_ASPECT_ORIGINAL;
        }
    }

    static int toUserType(String type) {
        switch(type) {
            case "facebook": return 0;
            case "google": return 2;
            case "device": return 97;
            case "api": return 99;
            case "zoom": return 100;
            case "sso": return 101;
            case "unknown":
            default: return 102;
        }
    }
}
