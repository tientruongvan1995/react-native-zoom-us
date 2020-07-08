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
    MobileRTCActiveVideoView *view = [MobileRTCActiveVideoView new];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, VideoAspect, MobileRTCVideoView) {
    NSLog(@"== ZoomMobileRCTActiveViewManager videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCVideoView) {
    NSLog(@"== ZoomMobileRCTActiveViewManager userID: %@", json);
    NSUInteger uID = [json unsignedIntValue];
    [view stopAttendeeVideo];
    [view showAttendeeVideoWithUserID: uID];
}

@end
