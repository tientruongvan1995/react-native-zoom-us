//
//  ZoomMobileRCTActiveShareViewManager.m
//  RNZoomUs
//
//  Created by Tien Truong on 7/8/20.
//

#import "ZoomMobileRCTActiveShareViewManager.h"

@implementation ZoomMobileRCTActiveShareViewManager

RCT_EXPORT_MODULE(ZoomMobileRCTActiveShareVideoView);

- (UIView *)view
{
    MobileRTCActiveShareView *view = [MobileRTCActiveShareView new];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, VideoAspect, MobileRTCVideoView) {
    NSLog(@"== ZoomMobileRCTActiveShareViewManager videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCActiveShareView) {
    NSLog(@"== ZoomMobileRCTActiveShareViewManager userID: %@", json);
    NSUInteger uID = [json unsignedIntValue];
    [view stopAttendeeVideo];
    [view showAttendeeVideoWithUserID: uID];
}

RCT_CUSTOM_VIEW_PROPERTY(shareToID, NSUInteger, MobileRTCActiveShareView) {
    NSLog(@"== ZoomMobileRCTActiveShareViewManager shareToID: %@", json);
    NSUInteger uID = [json unsignedIntValue];
    [view showActiveShareWithUserID: uID];
}

@end
