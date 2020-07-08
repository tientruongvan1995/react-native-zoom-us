//
//  ZoomMobileRCTPreviewViewManager.h
//  AppAuth
//
//  Created by Tien Truong on 7/7/20.
//

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import "RCTViewManager.h"
#import <MobileRTC/MobileRTC.h>
#import <MobileRTC/MobileRTCVideoView.h>


NS_ASSUME_NONNULL_BEGIN

@interface ZoomMobileRCTPreviewViewManager : RCTViewManager

@end

NS_ASSUME_NONNULL_END
