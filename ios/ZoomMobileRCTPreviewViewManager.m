//
//  ZoomMobileRCTPreviewViewManager.m
//  AppAuth
//
//  Created by Tien Truong on 7/7/20.
//

#import "ZoomMobileRCTPreviewViewManager.h"

@implementation ZoomMobileRCTPreviewViewManager

RCT_EXPORT_MODULE(ZoomMobileRCTPreviewVideoView);

- (UIView *)view
{
    MobileRTCPreviewVideoView *view = [MobileRTCPreviewVideoView new];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, VideoAspect, MobileRTCPreviewVideoView) {
    NSLog(@"== ZoomMobileRCTPreviewViewManager videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCPreviewVideoView) {
    NSLog(@"== ZoomMobileRCTPreviewViewManager userID: %@", json);
    NSUInteger uID = [json unsignedIntValue];
    [view stopAttendeeVideo];
    [view showAttendeeVideoWithUserID: uID];
}
@end
