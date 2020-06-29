
import { NativeModules, requireNativeComponent } from 'react-native';

const { RNZoomUs } = NativeModules;

export const ZoomMobileRTCVideoView = requireNativeComponent('ZoomMobileRTCVideoView');
export const ZoomMobileRCTActiveVideoView = requireNativeComponent('ZoomMobileRCTActiveVideoView');

export default RNZoomUs;
