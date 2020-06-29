//
//  ZoomMobileRCTActiveViewManager.m
//  AppAuth
//
//  Created by Tien Truong on 6/26/20.
//

#import "ZoomMobileRCTActiveViewManager.h"

@implementation ZoomMobileRCTActiveViewManager
{
}

RCT_EXPORT_MODULE(ZoomMobileRCTActiveVideoView);
- (UIView *)view
{
    MobileRTCActiveVideoView *view = [[MobileRTCActiveVideoView alloc] init];

    MobileRTCMeetingService *ms = [[MobileRTC sharedRTC] getMeetingService];
    if (ms) {
        NSUInteger uID = [ms myselfUserID];
        [view showAttendeeVideoWithUserID:uID];
    }
    [view setVideoAspect:MobileRTCVideoAspect_PanAndScan];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, VideoAspect, MobileRTCVideoView) {
    NSLog(@"videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCVideoView) {
    NSLog(@"userID: %@", json);
    [view showAttendeeVideoWithUserID: json];
}

@end
