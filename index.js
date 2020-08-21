
import { NativeEventEmitter, NativeModules, requireNativeComponent } from 'react-native';

const { RNZoomUs } = NativeModules;
const RNZoomEmitter = new NativeEventEmitter(RNZoomUs);

export const ZoomMobileRTCVideoView = requireNativeComponent('ZoomMobileRTCVideoView');
export const ZoomMobileRCTActiveVideoView = requireNativeComponent('ZoomMobileRCTActiveVideoView');
export const ZoomMobileRCTPreviewVideoView = requireNativeComponent('ZoomMobileRCTPreviewVideoView');
export const ZoomMobileRCTActiveShareVideoView = requireNativeComponent('ZoomMobileRCTActiveShareVideoView');

export const ZoomEvent = {
    USER_JOIN: "user_joined", 
    USER_LEAVE: "user_leaved", 
    USER_WAITING: "user_waiting",
    MEETING_READY:"meeting_ready",
    MEETING_JOIN_CONFIRMED:"meeting_join_confirmed",
    MEETING_VIEW_INITIALIZED:"meeting_view_initialized",
    MEETING_VIEW_DESTROYED:"meeting_view_destroyed",
    MEETING_CHAT_RECEIVED:"meeting_chat_received",
}

class ZoomUs {
    static instance = new ZoomUs();

    // ----- CALL ACTIONS ----
    initialize = async (key, secret, domain) => await RNZoomUs.initialize(key, secret, domain);
    
    startMeeting = async (displayName, zoomMeetingNo, userId, userType, zoomAccessToken, zoomToken) => await RNZoomUs.startMeeting(displayName, zoomMeetingNo, userId, userType, zoomAccessToken, zoomToken);
    
    joinMeeting = async (displayName, zoomMeetingNo, password) => await (password ? RNZoomUs.joinMeetingWithPassword(displayName, zoomMeetingNo, password) : RNZoomUs.joinMeeting(displayName, zoomMeetingNo));

    leaveMeeting = async () => await RNZoomUs.leaveMeeting();

    endMeeting = async () => await RNZoomUs.endMeeting();

    // ----- STREAMS INFORMATION ----

    getCurrentID = async () => await RNZoomUs.getCurrentID();

    getUsers = async () => await RNZoomUs.getUsers();

    // ----- VIDEO ACTIONS ----

    pinVideo = id => RNZoomUs.pinVideo(id); // pin to actived video

    toggleMuteMyVideo = () => RNZoomUs.muteMyVideo();

    switchMyCamera = () => RNZoomUs.switchMyCamera();

    thumbnailInShare = (isShared) => RNZoomUs.thumbnailInShare(isShared);

    // ----- AUDIO ACTIONS ----

    toggleMyAudio = () => RNZoomUs.muteMyAudio();
    
    switchMyAudioSource = () => RNZoomUs.switchMyAudioSource();

    // ----- EVENTS ----

    addEvent = (event, callback) => RNZoomEmitter.addListener(event, callback);

    removeEvent = (event, callback) => RNZoomEmitter.removeListener(event, callback)

    removeAllEvent = () => RNZoomEmitter.removeAllListeners();

    onUserJoined = callback => RNZoomEmitter.addListener(ZoomEvent.USER_JOIN, callback);
    onUserLeft = callback => RNZoomEmitter.addListener(ZoomEvent.USER_LEAVE, callback);
    onUserWaiting = callback => RNZoomEmitter.addListener(ZoomEvent.USER_WAITING, callback);
    onMeetingReady = callback => RNZoomEmitter.addListener(ZoomEvent.MEETING_READY, callback);
    onJoinConfirmed = callback => RNZoomEmitter.addListener(ZoomEvent.MEETING_JOIN_CONFIRMED, callback);
    onMeetingViewInitialized = callback => RNZoomEmitter.addListener(ZoomEvent.MEETING_VIEW_INITIALIZED, callback);
    onMeetingViewDestroyed = callback => RNZoomEmitter.addListener(ZoomEvent.MEETING_VIEW_DESTROYED, callback);
    onMeetingChatReceived = callback => RNZoomEmitter.addListener(ZoomEvent.MEETING_CHAT_RECEIVED, callback);

    offUserJoined = callback => RNZoomEmitter.removeListener(ZoomEvent.USER_JOIN, callback);
    offUserLeft = callback => RNZoomEmitter.removeListener(ZoomEvent.USER_LEAVE, callback);
    offUserWaiting = callback => RNZoomEmitter.removeListener(ZoomEvent.USER_WAITING, callback);
    offMeetingReady = callback => RNZoomEmitter.removeListener(ZoomEvent.MEETING_READY, callback);
    offJoinConfirmed = callback => RNZoomEmitter.removeListener(ZoomEvent.MEETING_JOIN_CONFIRMED, callback);
    offMeetingViewInitialized = callback => RNZoomEmitter.removeListener(ZoomEvent.MEETING_VIEW_INITIALIZED, callback);
    offMeetingViewDestroyed = callback => RNZoomEmitter.removeListener(ZoomEvent.MEETING_VIEW_DESTROYED, callback);
    offMeetingChatReceived = callback => RNZoomEmitter.removeListener(ZoomEvent.MEETING_CHAT_RECEIVED, callback);
}

export default ZoomUs.instance;