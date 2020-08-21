
#import "RNZoomUs.h"

@implementation RNZoomUs
{
    BOOL isInitialized;
    RCTPromiseResolveBlock initializePromiseResolve;
    RCTPromiseRejectBlock initializePromiseReject;
    RCTPromiseResolveBlock meetingPromiseResolve;
    RCTPromiseRejectBlock meetingPromiseReject;
}

- (instancetype)init {
    if (self = [super init]) {
        isInitialized = NO;
        initializePromiseResolve = nil;
        initializePromiseReject = nil;
        meetingPromiseResolve = nil;
        meetingPromiseReject = nil;
    }
    return self;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[
        @"user_joined",
        @"user_leaved",
        @"user_waiting",
        @"user_joined_active",
        @"meeting_ready",
        @"meeting_join_confirmed",
        @"meeting_view_initialized",
        @"meeting_view_destroyed",
        @"meeting_chat_received"
    ];
}

RCT_EXPORT_MODULE()

- (void)configSettings {
    [[[MobileRTC sharedRTC] getMeetingSettings] setEnableCustomMeeting:YES]; // enable Custom UI
    [[[MobileRTC sharedRTC] getMeetingSettings] setAutoConnectInternetAudio:YES];
    [[[MobileRTC sharedRTC] getMeetingSettings] setMuteVideoWhenJoinMeeting:NO];
    [[[MobileRTC sharedRTC] getMeetingSettings] setThumbnailInShare:YES];
}

RCT_EXPORT_METHOD(
    initialize:(NSString *)appKey
    withAppSecret:(NSString *)appSecret
    withWebDomain:(NSString *)webDomain
    withResolve:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    if (isInitialized) {
        resolve(@"Already initialize Zoom SDK successfully.");
        return;
    }

    isInitialized = true;

    @try {
        initializePromiseResolve = resolve;
        initializePromiseReject = reject;

        MobileRTCSDKInitContext *context = [MobileRTCSDKInitContext alloc];
        context.domain = webDomain;
        context.enableLog = YES;
        [[MobileRTC sharedRTC] initialize:context];

        MobileRTCAuthService *authService = [[MobileRTC sharedRTC] getAuthService];
        if (authService) {
            authService.delegate = self;
            authService.clientKey = appKey;
            authService.clientSecret = appSecret;

            [authService sdkAuth];
        } else {
            NSLog(@"onZoomSDKInitializeResult, no authService");
        }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing initialize", ex);
    }
}

RCT_EXPORT_METHOD(
    leaveMeeting:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        [ms leaveMeetingWithCmd:LeaveMeetingCmd_Leave];
        resolve(@"Logged out Zoom");
    } else {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"AuthService not found", [NSError init]);
    }
}

RCT_EXPORT_METHOD(
    endMeeting:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        [ms leaveMeetingWithCmd:LeaveMeetingCmd_End];
        resolve(@"Logged out Zoom");
    } else {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"AuthService not found", [NSError init]);
    }
}

RCT_EXPORT_METHOD(
    startMeeting:(NSString *)displayName
    withMeetingNo:(NSString *)meetingNo
    withUserId:(NSString *)userId
    withUserType:(MobileRTCUserType)userType
    withZoomAccessToken:(NSString *)zoomAccessToken
    withZoomToken:(NSString *)zoomToken
    withResolve:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    @try {
        meetingPromiseResolve = resolve;
        meetingPromiseReject = reject;
        [self configSettings];

        MobileRTCWaitingRoomService *ws = [[MobileRTC sharedRTC] getWaitingRoomService];
        if (ws) {
            ws.delegate = self;
        }

        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            ms.delegate = self;

            if ([[[MobileRTC sharedRTC] getMeetingSettings] enableCustomMeeting]) {
                ms.customizedUImeetingDelegate = self;
            }

            MobileRTCMeetingStartParam4WithoutLoginUser *params = [[MobileRTCMeetingStartParam4WithoutLoginUser alloc]init];
            params.userName = displayName;
            params.meetingNumber = meetingNo;
            params.userID = userId;
            params.userType = userType;
            params.zak = zoomAccessToken;
            params.userToken = zoomToken;
            MobileRTCMeetingStartParam *startParams = params;

            MobileRTCMeetError startMeetingResult = [ms startMeetingWithStartParam:startParams];

            NSLog(@"startMeeting, startMeetingResult=%d", startMeetingResult);
        }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing startMeeting", ex);
    }
}

RCT_EXPORT_METHOD(
    joinMeeting:(NSString *)displayName
    withMeetingNo:(NSString *)meetingNo
    withResolve:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    @try {
        meetingPromiseResolve = resolve;
        meetingPromiseReject = reject;
        [self configSettings];

        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            ms.delegate = self;

            if ([[[MobileRTC sharedRTC] getMeetingSettings] enableCustomMeeting]) {
                ms.customizedUImeetingDelegate = self;
            }

            NSDictionary *paramDict = @{
                kMeetingParam_Username: displayName,
                kMeetingParam_MeetingNumber: meetingNo
            };

            MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
            NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
        }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
    }
}

RCT_EXPORT_METHOD(
    joinMeetingWithPassword:(NSString *)displayName
    withMeetingNo:(NSString *)meetingNo
    withPassword:(NSString *)password
    withResolve:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    @try {
        meetingPromiseResolve = resolve;
        meetingPromiseReject = reject;
        [self configSettings];

        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            ms.delegate = self;

            if ([[[MobileRTC sharedRTC] getMeetingSettings] enableCustomMeeting]) {
                ms.customizedUImeetingDelegate = self;
            }

            NSDictionary *paramDict = @{
                kMeetingParam_Username: displayName,
                kMeetingParam_MeetingNumber: meetingNo,
                kMeetingParam_MeetingPassword: password
            };

            MobileRTCMeetError joinMeetingResult = [ms joinMeetingWithDictionary:paramDict];
            NSLog(@"joinMeeting, joinMeetingResult=%d", joinMeetingResult);
        }
    } @catch (NSError *ex) {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing joinMeeting", ex);
    }
}

// USER ACTION

RCT_EXPORT_METHOD(
    getCurrentID:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        NSUInteger uID = [ms myselfUserID];
        NSNumber *payload = [[NSNumber alloc] initWithUnsignedLong:uID];
        resolve(payload);
    } else {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing getCurrentID", [[NSError init] initWithText:@"MobileRTCMeetingService not found!"]);
    }
}

RCT_EXPORT_METHOD(
    getUsers:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        NSArray *users = [ms getInMeetingUserList];
        resolve(users);
    } else {
        reject(@"ERR_UNEXPECTED_EXCEPTION", @"Executing getCurrentID", [[NSError init] initWithText:@"MobileRTCMeetingService not found!"]);
    }
}

RCT_EXPORT_METHOD(pinVideo:(NSUInteger)userID) {
    [[[MobileRTC sharedRTC] getMeetingService] pinVideo:YES withUser:userID];
}

RCT_EXPORT_METHOD(muteMyVideo) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        if (![ms canUnmuteMyVideo]) return;
        BOOL mute = [ms isSendingMyVideo];
        NSLog(@"muteMyVideo:%d", mute);
        MobileRTCVideoError error = [ms muteMyVideo:mute];
        NSLog(@"MobileRTCVideoError:%d", error);
    }
}

RCT_EXPORT_METHOD(switchMyCamera) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) [ms switchMyCamera];
}

RCT_EXPORT_METHOD(thumbnailInShare:(BOOL)isShared) {
    [[[MobileRTC sharedRTC] getMeetingSettings] setThumbnailInShare:isShared];
}

// ----- AUDIO ACTIONS ----

RCT_EXPORT_METHOD(switchMyAudioSource:(RCTPromiseResolveBlock)resolve
                  withReject:(RCTPromiseRejectBlock)reject) {
    MobileRTCAudioError error = [[[MobileRTC sharedRTC] getMeetingService] switchMyAudioSource];
    if (error == MobileRTCAudioError_Success) {
        resolve(@"Switch Audio Success!");
    } else {
        reject(@"ERR_UNEXPECTED_EXCEPTION",
               [NSString stringWithFormat:@"SwitchMyAudioSource: %d", error],
               [NSError errorWithDomain:@"us.zoom.sdk" code:error userInfo:nil]);
    }
}

RCT_EXPORT_METHOD(muteMyAudio:(RCTPromiseResolveBlock)resolve
                  withReject:(RCTPromiseRejectBlock)reject) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        MobileRTCAudioType audioType = [ms myAudioType];
        switch (audioType) {
            case MobileRTCAudioType_VoIP: //voip
            case MobileRTCAudioType_Telephony: //phone
            {
                if (![ms canUnmuteMyAudio]) {
                    break;
                }
                BOOL isMuted = [ms isMyAudioMuted];
                [ms muteMyAudio:!isMuted];
                break;
            }
            case MobileRTCAudioType_None: {
                break;
            }
        }
        resolve(@"Success");
    }
}

// ----- CHAT ACTIONS ----

RCT_EXPORT_METHOD(sendMessage:(NSString *)message
                  withResolve:(RCTPromiseResolveBlock)resolve
                  withReject:(RCTPromiseRejectBlock)reject) {
    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        [ms sendChatToGroup:MobileRTCChatGroup_All WithContent:message];
        resolve(@"Success");
    } else {
        reject(
            @"ERR_ZOOM_SEND_MESSAGE",
            [NSString stringWithFormat:@"Error: %@", @"Meeting Service Not Found"],
            [NSError errorWithDomain:@"us.zoom.sdk" code:0 userInfo:nil]
        );
    }
}

// MARK: MobileRTCAuthDelegate

- (void)onMobileRTCAuthReturn:(MobileRTCAuthError)returnValue {
    NSLog(@"nZoomSDKInitializeResult, errorCode=%d", returnValue);
    if (returnValue != MobileRTCAuthError_Success) {
        initializePromiseReject(
            @"ERR_ZOOM_INITIALIZATION",
            [NSString stringWithFormat:@"Error: %d", returnValue],
            [NSError errorWithDomain:@"us.zoom.sdk" code:returnValue userInfo:nil]
            );
    } else {
        initializePromiseResolve(@"Initialize Zoom SDK successfully.");
    }
}

// MARK: MobileRTCMeetingServiceDelegate
- (void)onMeetingReturn:(MobileRTCMeetError)errorCode internalError:(NSInteger)internalErrorCode {
    NSLog(@"onMeetingReturn, error=%d, internalErrorCode=%zd", errorCode, internalErrorCode);

    if (!meetingPromiseResolve) {
        return;
    }

    if (errorCode != MobileRTCMeetError_Success) {
        meetingPromiseReject(
            @"ERR_ZOOM_MEETING",
            [NSString stringWithFormat:@"Error: %d, internalErrorCode=%zd", errorCode, internalErrorCode],
            [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
            );
    } else {
        meetingPromiseResolve(@"Connected to zoom meeting");
    }

    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
}

- (void)onMeetingStateChange:(MobileRTCMeetingState)state {
    NSLog(@"onMeetingStatusChanged, meetingState=%d", state);

    if (state == MobileRTCMeetingState_InMeeting || state == MobileRTCMeetingState_Idle) {
        if (!meetingPromiseResolve) {
            return;
        }

        NSLog(@"onMeetingStatusChanged resolved!");
        meetingPromiseResolve(@"Connected to zoom meeting");

        meetingPromiseResolve = nil;
        meetingPromiseReject = nil;
    }
}

- (void)onMeetingError:(MobileRTCMeetError)errorCode message:(NSString *)message {
    NSLog(@"onMeetingError, errorCode=%d, message=%@", errorCode, message);

    if (!meetingPromiseResolve) {
        return;
    }

    if ([message isEqualToString:@"success"]) {
        meetingPromiseResolve(@"Connected to zoom meeting");
    } else {
        meetingPromiseReject(
            @"ERR_ZOOM_MEETING",
            [NSString stringWithFormat:@"Error: %d, internalErrorCode=%@", errorCode, message],
            [NSError errorWithDomain:@"us.zoom.sdk" code:errorCode userInfo:nil]
            );
    }

    meetingPromiseResolve = nil;
    meetingPromiseReject = nil;
}

- (void)onWaitingRoomStatusChange:(BOOL)needWaiting
{
    if (needWaiting) {
        NSLog(@"needWaiting true");
    } else {
        NSLog(@"needWaiting false");
    }
}

- (void)onJBHWaitingWithCmd:(JBHCmd)cmd
{
    NSLog(@"onJBHWaitingWithCmd %d", cmd);
    BOOL isWaiting = (cmd == JBHCmd_Show);
    [self sendEventWithName:@"user_waiting" body:@(isWaiting)];
}

- (void)onMeetingReady {
    NSLog(@"===== onMeetingReady");
    [self sendEventWithName:@"meeting_ready" body:@(YES)];
}

- (void)onJoinMeetingConfirmed {
    NSLog(@"===== onJoinMeetingConfirmed");
    [self sendEventWithName:@"meeting_join_confirmed" body:@(YES)];
}

/*!
 @brief The function will be invoked once the user joins the meeting.
 @return The ID of user who leaves the meeting.
 */
- (void)onSinkMeetingUserJoin:(NSUInteger)userID {
    NSLog(@"===== onSinkMeetingUserJoin %lu", userID);
    [self sendEventWithName:@"user_joined" body:@(userID)];
}

/*!
 @brief The function will be invoked once the user leaves the meeting.
 @return The ID of user who leaves the meeting.
 */
- (void)onSinkMeetingUserLeft:(NSUInteger)userID {
    NSLog(@"===== onSinkMeetingUserLeft %lu", userID);
    [self sendEventWithName:@"user_leaved" body:@(userID)];
}

- (void)onSinkMeetingActiveVideo:(NSUInteger)userID
{
    NSLog(@"===== onSinkMeetingActiveVideo %lu", userID);
    [self sendEventWithName:@"user_joined_active" body:@(userID)];
}

// MARK: MobileRTCWaitingRoomServiceDelegate
- (void)onWaitingRoomUserJoin:(NSUInteger)userId {
    NSLog(@"===== onWaitingRoomUserJoin %lu", userId);
}

- (void)onWaitingRoomUserLeft:(NSUInteger)userId {
    NSLog(@"===== onWaitingRoomUserLeft %lu", userId);
}

// MARK: MESSGAGE
- (void)onInMeetingChat:(NSString *)messageID {
    NSLog(@"===== onInMeetingChat %@", messageID);
    MobileRTCMeetingChat *chat = [[[MobileRTC sharedRTC] getMeetingService] meetingChatByID:messageID];
    [self sendEventWithName:@"meeting_chat_received" body:chat];
    NSLog(@"===== %@", chat);
}

// MARK: MobileRTCCustomizedUIMeetingDelegate
- (void)onDestroyMeetingView {
    NSLog(@"onDestroyMeetingView");
    [self sendEventWithName:@"meeting_view_destroyed" body:@(YES)];
}

- (void)onInitMeetingView {
    NSLog(@"onInitMeetingView");
    [self sendEventWithName:@"meeting_view_initialized" body:@(YES)];
}

@end

@implementation RCTConvert (JBHStatus)
RCT_ENUM_CONVERTER(JBHCmd, (@{
    @"show": @(JBHCmd_Show),
    @"hide": @(JBHCmd_Hide)
    }), JBHCmd_Hide, intValue)
@end

@implementation RCTConvert (RTCUserType)
RCT_ENUM_CONVERTER(MobileRTCUserType, (@{
    @"facebook": @(MobileRTCUserType_Facebook),
    @"google": @(MobileRTCUserType_GoogleOAuth),
    @"device": @(MobileRTCUserType_DeviceUser),
    @"api": @(MobileRTCUserType_APIUser),
    @"zoom": @(MobileRTCUserType_ZoomUser),
    @"sso": @(MobileRTCUserType_SSOUser),
    @"unknown": @(MobileRTCUserType_Unknown),
    }), MobileRTCUserType_Unknown, intValue)
@end
