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
    MobileRTCVideoView *view = [MobileRTCVideoView new];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(videoAspect, MobileRTCVideoAspect, MobileRTCVideoView) {
    NSLog(@"== ZoomMobileRCTViewManager videoAspect: %@", json);
    [view setVideoAspect: json];
}

RCT_CUSTOM_VIEW_PROPERTY(userID, NSUInteger, MobileRTCVideoView) {
    NSLog(@"== ZoomMobileRCTViewManager userID: %@", json);
    [view stopAttendeeVideo];
    NSUInteger uID = [json unsignedIntValue];
    [view showAttendeeVideoWithUserID:uID];
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
