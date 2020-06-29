
#import "RNZoomUs.h"

@implementation RNZoomUs
{
    BOOL isInitialized;
    RCTPromiseResolveBlock initializePromiseResolve;
    RCTPromiseRejectBlock initializePromiseReject;
    RCTPromiseResolveBlock meetingPromiseResolve;
    RCTPromiseRejectBlock meetingPromiseReject;

    RCTResponseSenderBlock waitingCallback;
}

- (instancetype)init {
    if (self = [super init]) {
        isInitialized = NO;
        initializePromiseResolve = nil;
        initializePromiseReject = nil;
        meetingPromiseResolve = nil;
        meetingPromiseReject = nil;
        waitingCallback = nil;
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

RCT_EXPORT_MODULE()

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

    [[MobileRTC sharedRTC] getMeetingSettings].enableCustomMeeting = YES; // enable Custom UI
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
    withUserType:(NSInteger)userType
    withZoomAccessToken:(NSString *)zoomAccessToken
    withZoomToken:(NSString *)zoomToken
    withResolve:(RCTPromiseResolveBlock)resolve
    withReject:(RCTPromiseRejectBlock)reject
    ) {
    @try {
        meetingPromiseResolve = resolve;
        meetingPromiseReject = reject;

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
            params.userType = (MobileRTCUserType)userType;
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

        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            ms.delegate = self;

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

        MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
        if (ms) {
            ms.delegate = self;

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

RCT_EXPORT_METHOD(onWaitingConnect:(RCTResponseSenderBlock)callback) {
    waitingCallback = callback;
}

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
    waitingCallback(@[[NSNull null], @(isWaiting)]);
}

- (void)onMeetingReady {
    NSLog(@"===== onMeetingReady");
}

- (void)onJoinMeetingConfirmed {
    NSLog(@"===== onJoinMeetingConfirmed");
}

// MARK: MobileRTCWaitingRoomServiceDelegate
- (void)onWaitingRoomUserJoin:(NSUInteger)userId {
    NSLog(@"===== onWaitingRoomUserJoin %lu", userId);
//    MobileRTCWaitingRoomService *ws = [[MobileRTC sharedRTC] getWaitingRoomService];
//    NSArray *arr = [ws waitingRoomList];
//    MobileRTCMeetingUserInfo *userInfo = [ws waitingRoomUserInfoByID:userId];
//    NSLog(@"Waiting Room: %@", arr);
//    NSLog(@"userInfo: %@", userInfo);
//    [ws admitToMeeting:userId];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [ws putInWaitingRoom:userId];
//    });
}

- (void)onWaitingRoomUserLeft:(NSUInteger)userId {
    NSLog(@"===== onWaitingRoomUserLeft %lu", userId);
//    MobileRTCWaitingRoomService *ws = [[MobileRTC sharedRTC] getWaitingRoomService];
//    MobileRTCMeetingUserInfo *userInfo = [ws waitingRoomUserInfoByID:userId];
//    NSLog(@"userInfo: %@", userInfo);
}

// MARK: MobileRTCCustomizedUIMeetingDelegate
- (void)onDestroyMeetingView {
    NSLog(@"onDestroyMeetingView");
}

- (void)onInitMeetingView {
    NSLog(@"onInitMeetingView");
}

@end

@implementation RCTConvert (JBHStatus)
RCT_ENUM_CONVERTER(JBHCmd, (@{
    @"show": @(JBHCmd_Show),
    @"hide": @(JBHCmd_Hide)
    }), JBHCmd_Hide, intValue)
@end
