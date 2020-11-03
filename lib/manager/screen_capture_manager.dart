//
//  screen_capture_manager.dart
//  zego_express_screen_capture
//
//  Created by Patrick Fu on 2020/10/25.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'dart:io' show Platform;
import 'package:zego_express_screen_capture/manager/internal/screen_capture_manager_impl_android.dart';
import 'package:zego_express_screen_capture/manager/internal/screen_capture_manager_impl_ios.dart';

/// The factory to create `ScreenCaptureManager`
class ScreenCaptureManagerFactory {

  static ScreenCaptureManager createManager() {
    if (Platform.isIOS) {
      return ScreenCaptureManagerImplIOS();
    } else if (Platform.isAndroid) {
      return ScreenCaptureManagerImplAndroid();
    } else {
      print('[ScreenCaptureManagerFactory] [createManager] Unsupported platform');
      return null;
    }
  }
}

/// This manager should be created by `ScreenCaptureManagerFactory` class
abstract class ScreenCaptureManager {

  Future<bool> startScreenCapture();

  /// Only supports Android. On iOS, users need to actively stop screen capture
  Future<bool> stopScreenCapture();

  /// [onlyCaptureVideo] indicates whether to capture only video buffer, otherwise it will capture video + audio buffer
  Future<void> setParamsForCreateEngine(int appID, String appSign, bool isTestEnv, bool onlyCaptureVideo);

  Future<void> setParamsForVideoConfig(int videoWidth, int videoHeight, int videoFPS, int videoBitrateKBPS);

  Future<void> setParamsForStartLive(String roomID, String userID, String userName, String streamID);

  /// Only iOS needs to set
  /// [appGroupID] is both your `Runner` target and `BroadCast Upload Extension` target's AppGroup ID
  Future<void> setAppGroup(String appGroupID) {
    return null;
  }

  /// Only iOS needs to set
  /// [extensionName] is your `BroadCast Upload Extension` target's `Product Name`,
  /// or to be precise, the file name of the `.appex` product of the extension
  Future<void> setReplayKitExtensionName(String extensionName) {
    return null;
  }
}
