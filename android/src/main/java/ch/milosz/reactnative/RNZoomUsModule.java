package ch.milosz.reactnative;

import android.Manifest;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.List;

import us.zoom.sdk.InMeetingAudioController;
import us.zoom.sdk.InMeetingChatController;
import us.zoom.sdk.InMeetingChatMessage;
import us.zoom.sdk.InMeetingEventHandler;
import us.zoom.sdk.InMeetingService;
import us.zoom.sdk.InMeetingServiceListener;
import us.zoom.sdk.InMeetingShareController;
import us.zoom.sdk.InMeetingVideoController;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingEndReason;
import us.zoom.sdk.MeetingError;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingServiceListener;
import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.StartMeetingOptions;
import us.zoom.sdk.StartMeetingParamsWithoutLogin;
import us.zoom.sdk.ZoomError;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomSDKInitParams;
import us.zoom.sdk.ZoomSDKInitializeListener;

public class RNZoomUsModule extends ReactContextBaseJavaModule implements ZoomSDKInitializeListener, MeetingServiceListener, InMeetingServiceListener, LifecycleEventListener {

    private final static String TAG = "RNZoomUs";
    private final static int MY_CAMERA_REQUEST_CODE = 100;
    private final ReactApplicationContext reactContext;

    private Boolean isInitialized = false;
    private Boolean isCalling = false;
    private Promise initializePromise;
    private Promise meetingPromise;

    public RNZoomUsModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "RNZoomUs";
    }

    private void configSettings() {
        ZoomSDK.getInstance().getMeetingSettingsHelper().setCustomizedMeetingUIEnabled(true);
        ZoomSDK.getInstance().getMeetingSettingsHelper().setAutoConnectVoIPWhenJoinMeeting(true);
        ZoomSDK.getInstance().getMeetingSettingsHelper().enableForceAutoStartMyVideoWhenJoinMeeting(true);
    }

    private void sendEvent(String eventName, @Nullable Object params) {
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @ReactMethod
    public void initialize(final String appKey, final String appSecret, final String webDomain, final Promise promise) {
        if (isInitialized) {
            promise.resolve("Already initialize Zoom SDK successfully.");
            return;
        }

        isInitialized = true;

        try {
            initializePromise = promise;

            reactContext.getCurrentActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ZoomSDK zoomSDK = ZoomSDK.getInstance();
                    ZoomSDKInitParams initParams = new ZoomSDKInitParams();
                    initParams.appKey = appKey;
                    initParams.appSecret = appSecret;
                    initParams.enableLog = true;
                    initParams.domain = webDomain;
                    zoomSDK.initialize(reactContext.getCurrentActivity(), RNZoomUsModule.this, initParams);
                }
            });
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void leaveMeeting(final Promise promise) {
        isCalling = false;
        try {
            reactContext.getCurrentActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ZoomSDK zoomSDK = ZoomSDK.getInstance();
                    zoomSDK.getMeetingService().leaveCurrentMeeting(true);
                    promise.resolve("Room Left successfully");
                }
            });
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void endMeeting(final Promise promise) {
        isCalling = false;
        try {
            reactContext.getCurrentActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ZoomSDK zoomSDK = ZoomSDK.getInstance();
                    zoomSDK.getMeetingService().leaveCurrentMeeting(true);
                    promise.resolve("Room Left successfully");
                }
            });
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void startMeeting(
            final String displayName,
            final String meetingNo,
            final String userId,
            final String userType,
            final String zoomAccessToken,
            final String zoomToken,
            final Promise promise
    ) {
        try {
            isCalling = false;
            meetingPromise = promise;

            reactContext.getCurrentActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ZoomSDK zoomSDK = ZoomSDK.getInstance();
                    if (!zoomSDK.isInitialized()) {
                        promise.reject("ERR_ZOOM_START", "ZoomSDK has not been initialized successfully");
                        return;
                    }

                    if (ContextCompat.checkSelfPermission(getReactApplicationContext(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_DENIED) {
                        ActivityCompat.requestPermissions(getCurrentActivity(), new String[]{Manifest.permission.CAMERA}, MY_CAMERA_REQUEST_CODE);
                    }

                    InMeetingAudioController mInMeetingAudioController = ZoomSDK.getInstance().getInMeetingService().getInMeetingAudioController();
                    Log.d(TAG, "isAudioConnected: " + mInMeetingAudioController.isAudioConnected());
                    if (!mInMeetingAudioController.isAudioConnected()) {
                        mInMeetingAudioController.muteMyAudio(false);
                        mInMeetingAudioController.connectAudioWithVoIP();
                    }

                    configSettings();
                    final MeetingService meetingService = zoomSDK.getMeetingService();
                    if (meetingService.getMeetingStatus() != MeetingStatus.MEETING_STATUS_IDLE) {
                        long lMeetingNo = 0;
                        try {
                            lMeetingNo = Long.parseLong(meetingNo);
                        } catch (NumberFormatException e) {
                            promise.reject("ERR_ZOOM_START", "Invalid meeting number: " + meetingNo);
                            return;
                        }

                        if (meetingService.getCurrentRtcMeetingNumber() == lMeetingNo) {
                            meetingService.returnToMeeting(reactContext.getCurrentActivity());
                            promise.resolve("Already joined zoom meeting");
                            return;
                        }
                    }

                    StartMeetingOptions opts = new StartMeetingOptions();
                    StartMeetingParamsWithoutLogin params = new StartMeetingParamsWithoutLogin();
                    params.displayName = displayName;
                    params.meetingNo = meetingNo;
                    params.userId = userId;
                    params.userType = EnumConverter.toUserType(userType);
                    params.zoomAccessToken = zoomAccessToken;
                    params.zoomToken = zoomToken;

                    int startMeetingResult = meetingService.startMeetingWithParams(reactContext.getCurrentActivity(), params, opts);
                    Log.i(TAG, "startMeeting, startMeetingResult=" + startMeetingResult);

                    // TODO:
                    InMeetingService mInMeetingService = ZoomSDK.getInstance().getInMeetingService();
                    InMeetingShareController mInMeetingShareController = mInMeetingService.getInMeetingShareController();
                    mInMeetingShareController.startShareViewSession();

                    if (mInMeetingShareController.isSharingOut()) {
                        if (!mInMeetingShareController.isSharingScreen()) {
                            mInMeetingShareController.startShareScreenContent();
                        }
                    }

                    if (startMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
                        promise.reject("ERR_ZOOM_START", "startMeeting, errorCode=" + startMeetingResult);
                    }
                }
            });
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void joinMeeting(
            final String displayName,
            final String meetingNo,
            Promise promise
    ) {
        try {
            meetingPromise = promise;

            ZoomSDK zoomSDK = ZoomSDK.getInstance();
            if (!zoomSDK.isInitialized()) {
                promise.reject("ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully");
                return;
            }
            configSettings();
            final MeetingService meetingService = zoomSDK.getMeetingService();

            JoinMeetingOptions opts = new JoinMeetingOptions();
            JoinMeetingParams params = new JoinMeetingParams();
            params.displayName = displayName;
            params.meetingNo = meetingNo;

            int joinMeetingResult = meetingService.joinMeetingWithParams(reactContext.getCurrentActivity(), params, opts);
            Log.i(TAG, "joinMeeting, joinMeetingResult=" + joinMeetingResult);

            if (joinMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
                promise.reject("ERR_ZOOM_JOIN", "joinMeeting, errorCode=" + joinMeetingResult);
            }
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void joinMeetingWithPassword(
            final String displayName,
            final String meetingNo,
            final String password,
            Promise promise
    ) {
        try {
            meetingPromise = promise;

            ZoomSDK zoomSDK = ZoomSDK.getInstance();
            if (!zoomSDK.isInitialized()) {
                promise.reject("ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully");
                return;
            }

            configSettings();
            final MeetingService meetingService = zoomSDK.getMeetingService();

            JoinMeetingOptions opts = new JoinMeetingOptions();
            JoinMeetingParams params = new JoinMeetingParams();
            params.displayName = displayName;
            params.meetingNo = meetingNo;
            params.password = password;

            int joinMeetingResult = meetingService.joinMeetingWithParams(reactContext.getCurrentActivity(), params, opts);
            Log.i(TAG, "joinMeeting, joinMeetingResult=" + joinMeetingResult);

            if (joinMeetingResult != MeetingError.MEETING_ERROR_SUCCESS) {
                promise.reject("ERR_ZOOM_JOIN", "joinMeeting, errorCode=" + joinMeetingResult);
            }
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    // ----- STREAMS INFORMATION ----

    @ReactMethod
    public void getCurrentID(Promise promise) {
        try {
            ZoomSDK zoomSDK = ZoomSDK.getInstance();
            if (!zoomSDK.isInitialized()) {
                promise.reject("ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully");
                return;
            }

            int uID = (int) zoomSDK.getInMeetingService().getMyUserID();
            Log.i(TAG, "getCurrentID: " + uID);

            promise.resolve(uID);
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    @ReactMethod
    public void getUsers(Promise promise) {
        try {
            ZoomSDK zoomSDK = ZoomSDK.getInstance();
            if (!zoomSDK.isInitialized()) {
                promise.reject("ERR_ZOOM_JOIN", "ZoomSDK has not been initialized successfully");
                return;
            }

            List<Long> userList = zoomSDK.getInMeetingService().getInMeetingUserList();

            WritableArray uIDs = Arguments.createArray();
            for (int i = 0; i < userList.size(); i++) {
                uIDs.pushInt(userList.get(i).intValue());
            }

            promise.resolve(uIDs);
        } catch (Exception ex) {
            promise.reject("ERR_UNEXPECTED_EXCEPTION", ex);
        }
    }

    // ----- VIDEO ACTIONS ----

    @ReactMethod
    public void pinVideo(int userID, Promise promise) {
        InMeetingVideoController ctrl = ZoomSDK.getInstance().getInMeetingService().getInMeetingVideoController();
        ctrl.pinVideo(true, userID);
    }

    @ReactMethod
    public void checkVideoRotation() {
        Display display = ((WindowManager) reactContext.getCurrentActivity().getSystemService(Service.WINDOW_SERVICE)).getDefaultDisplay();
        int displayRotation = display.getRotation();
        InMeetingVideoController controller = ZoomSDK.getInstance().getInMeetingService().getInMeetingVideoController();
        controller.rotateMyVideo(displayRotation);
    }

    @ReactMethod
    public void muteMyVideo(Promise promise) {
        InMeetingVideoController ctrl = ZoomSDK.getInstance().getInMeetingService().getInMeetingVideoController();
        boolean isMuted = ctrl.isMyVideoMuted();
        Log.d(TAG, "isMuted: " + isMuted);
        ctrl.muteMyVideo(!isMuted);
        promise.resolve(true);
    }

    @ReactMethod
    public void switchMyCamera(Promise promise) {
        InMeetingVideoController ctrl = ZoomSDK.getInstance().getInMeetingService().getInMeetingVideoController();
        ctrl.switchToNextCamera();
        promise.resolve(true);
    }

    @ReactMethod
    public void thumbnailInShare(Promise promise) {
        promise.resolve(true);
    }

    // ----- AUDIO ACTIONS ----

    @ReactMethod
    public void muteMyAudio(Promise promise) {
        InMeetingAudioController ctrl = ZoomSDK.getInstance().getInMeetingService().getInMeetingAudioController();
        boolean isMuted = ctrl.isMyAudioMuted();
        ctrl.muteMyAudio(!isMuted);
        promise.resolve(true);
    }

    @ReactMethod
    public void switchMyAudioSource(Promise promise) {
        promise.resolve(true);
    }

    // ----- CHAT ACTIONS ----
    @ReactMethod
    public void sendMessage(String message, Promise promise) {
        InMeetingChatController ctrl = ZoomSDK.getInstance().getInMeetingService().getInMeetingChatController();
        ctrl.sendChatToGroup(InMeetingChatController.MobileRTCChatGroup.MobileRTCChatGroup_All, message);
        promise.resolve(true);
    }

    // ----- EVENTS ----

    @Override
    public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {
        Log.i(TAG, "onZoomSDKInitializeResult, errorCode=" + errorCode + ", internalErrorCode=" + internalErrorCode);
        if (errorCode != ZoomError.ZOOM_ERROR_SUCCESS) {
            initializePromise.reject(
                    "ERR_ZOOM_INITIALIZATION",
                    "Error: " + errorCode + ", internalErrorCode=" + internalErrorCode
            );
        } else {
            registerListener();
            initializePromise.resolve("Initialize Zoom SDK successfully.");
        }
    }

    @Override
    public void onMeetingStatusChanged(MeetingStatus meetingStatus, int errorCode, int internalErrorCode) {
        Log.i(TAG, "onMeetingStatusChanged, meetingStatus=" + meetingStatus + ", errorCode=" + errorCode + ", internalErrorCode=" + internalErrorCode);

        if (meetingPromise == null) {
            return;
        }

        if (meetingStatus == MeetingStatus.MEETING_STATUS_FAILED) {
            meetingPromise.reject(
                    "ERR_ZOOM_MEETING",
                    "Error: " + errorCode + ", internalErrorCode=" + internalErrorCode
            );
            meetingPromise = null;
        } else if (meetingStatus == MeetingStatus.MEETING_STATUS_INMEETING) {
            meetingPromise.resolve("Connected to zoom meeting");
            meetingPromise = null;
        }
    }

    @Override
    public void onZoomAuthIdentityExpired() {
        Log.i(TAG, "onZoomAuthIdentityExpired");
        initializePromise.reject(
                "ERR_ZOOM_IDENTITY_",
                "Error: Auth Identity Expiredentication"
        );
    }

    private void registerListener() {
        Log.i(TAG, "registerListener");
        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        MeetingService meetingService = zoomSDK.getMeetingService();
        InMeetingService mInMeetingService = zoomSDK.getInMeetingService();
        if (meetingService != null) {
            meetingService.addListener(this);
            mInMeetingService.addListener(this);
        }
    }

    private void unregisterListener() {
        Log.i(TAG, "unregisterListener");
        ZoomSDK zoomSDK = ZoomSDK.getInstance();
        if (zoomSDK.isInitialized()) {
            MeetingService meetingService = zoomSDK.getMeetingService();
            InMeetingService mInMeetingService = zoomSDK.getInMeetingService();
            meetingService.removeListener(this);
            mInMeetingService.removeListener(this);
        }
    }

    @Override
    public void onCatalystInstanceDestroy() {
        unregisterListener();
    }

    // React LifeCycle
    @Override
    public void onHostDestroy() {
        unregisterListener();
    }

    @Override
    public void onHostPause() {
    }

    @Override
    public void onHostResume() {
    }

    // --------------

    @Override
    public void onMeetingNeedPasswordOrDisplayName(boolean b, boolean b1, InMeetingEventHandler inMeetingEventHandler) {
    }

    @Override
    public void onWebinarNeedRegister() {
        Log.i(TAG, "onWebinarNeedRegister: ");
    }

    @Override
    public void onJoinWebinarNeedUserNameAndEmail(InMeetingEventHandler inMeetingEventHandler) {
        Log.i(TAG, "onJoinWebinarNeedUserNameAndEmail: ");
    }

    @Override
    public void onMeetingNeedColseOtherMeeting(InMeetingEventHandler inMeetingEventHandler) {
        Log.i(TAG, "onMeetingNeedColseOtherMeeting: ");
    }

    @Override
    public void onMeetingFail(int i, int i1) {
        Log.i(TAG, "onMeetingFail: " + i + " " + i1);
    }

    @Override
    public void onMeetingLeaveComplete(long reason) {
        Log.i(TAG, "onMeetingLeaveComplete: " + reason);
        isCalling = false;
        sendEvent("meeting_view_destroyed", ((int) reason));  // TODO: reason -> us.zoom.sdk.MeetingEndReason
    }

    @Override
    public void onMeetingUserJoin(List<Long> list) {
        Log.i(TAG, "onMeetingUserJoin: " + list);
        int n = list.size() - 1;
        int userID = list.get(n).intValue();
        Log.i(TAG, "onMeetingUserJoin userID: " + userID);
        sendEvent("user_joined", userID);
    }

    @Override
    public void onMeetingUserLeave(List<Long> list) {
        Log.i(TAG, "onMeetingUserLeave: " + list);
        int n = list.size() - 1;

        if (n == 0) {
            sendEvent("meeting_view_destroyed", MeetingEndReason.END_FOR_NOATEENDEE);
            return;
        }

        int userID = list.get(n).intValue();
        Log.i(TAG, "onMeetingUserLeave userID: " + userID);
        sendEvent("user_left", userID);
    }

    @Override
    public void onMeetingUserUpdated(long userId) {
        Log.i(TAG, "onMeetingUserUpdated: " + userId);
    }

    @Override
    public void onMeetingHostChanged(long l) {

    }

    @Override
    public void onMeetingCoHostChanged(long l) {

    }

    @Override
    public void onActiveVideoUserChanged(long userId) {
        Log.i(TAG, "onActiveVideoUserChanged: " + userId);
    }

    @Override
    public void onActiveSpeakerVideoUserChanged(long l) {

    }

    @Override
    public void onSpotlightVideoChanged(boolean b) {

    }

    @Override
    public void onUserVideoStatusChanged(long userId) {
        Log.i(TAG, "onUserVideoStatusChanged: " + userId);
    }

    @Override
    public void onUserNetworkQualityChanged(long userId) {
        Log.i(TAG, "onUserNetworkQualityChanged: " + userId);
    }

    @Override
    public void onMicrophoneStatusError(InMeetingAudioController.MobileRTCMicrophoneError mobileRTCMicrophoneError) {
        Log.i(TAG, "onMicrophoneStatusError: " + mobileRTCMicrophoneError);
    }

    @Override
    public void onUserAudioStatusChanged(long userId) {
        Log.i(TAG, "onUserAudioStatusChanged: " + userId);
    }


    @Override
    public void onUserAudioTypeChanged(long userId) {
        Log.i(TAG, "onUserAudioTypeChanged: " + userId);
    }

    @Override
    public void onMyAudioSourceTypeChanged(int userId) {
        Log.i(TAG, "onMyAudioSourceTypeChanged: " + userId);
    }

    @Override
    public void onHostAskUnMute(long userId) {
        Log.i(TAG, "onHostAskUnMute: " + userId);
    }

    @Override
    public void onHostAskStartVideo(long userId) {
        Log.i(TAG, "onHostAskStartVideo: " + userId);
    }

    @Override
    public void onLowOrRaiseHandStatusChanged(long l, boolean b) {

    }

    @Override
    public void onMeetingSecureKeyNotification(byte[] bytes) {

    }

    @Override
    public void onChatMessageReceived(InMeetingChatMessage inMeetingChatMessage) {
        Log.i(TAG, "onChatMessageReceived: " + inMeetingChatMessage);
        sendEvent("meeting_chat_received", inMeetingChatMessage);
    }

    @Override
    public void onSilentModeChanged(boolean b) {
    }

    @Override
    public void onFreeMeetingReminder(boolean b, boolean b1, boolean b2) {
    }

    @Override
    public void onMeetingActiveVideo(long userId) {
        Log.i(TAG, "onMeetingActiveVideo: " + userId);

        if (!isCalling) {
            isCalling = true;
            sendEvent("meeting_ready", ((int) userId));
        }
    }

    @Override
    public void onSinkAttendeeChatPriviledgeChanged(int i) {

    }

    @Override
    public void onSinkAllowAttendeeChatNotification(int i) {

    }
}
