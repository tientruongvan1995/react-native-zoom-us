//
//  ZoomMobileRCTViewManager.m
//  AppAuth
//
//  Created by Tien Truong on 6/20/20.
//

#import "ZoomMobileRCTViewManager.h"

@implementation ZoomMobileRCTViewManager
{
}

RCT_EXPORT_MODULE(ZoomMobileRTCVideoView);
- (UIView *)view
{
    MobileRTCVideoView *view = [[MobileRTCVideoView alloc] init];
    [view setVideoAspect:MobileRTCVideoAspect_PanAndScan];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, MobileRTCVideoAspect, MobileRTCVideoView) {
    NSLog(@"videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCVideoView) {
    NSLog(@"userID: %@", json);
    [view showAttendeeVideoWithUserID:json];
}

@end

@implementation RCTConvert (VideoAspect)
RCT_ENUM_CONVERTER(MobileRTCVideoAspect, (@{
    @"original": @(MobileRTCVideoAspect_Original),
    @"letterBox": @(MobileRTCVideoAspect_LetterBox),
    @"panAndScan": @(MobileRTCVideoAspect_PanAndScan),
    @"fullFilled": @(MobileRTCVideoAspect_Full_Filled),
    }), MobileRTCVideoAspect_Original, intValue)
@end
