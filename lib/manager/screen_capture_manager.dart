//
//  screen_capture_manager.dart
//  zego_express_screen_capture
//
//  Created by Patrick Fu on 2020/10/25.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'dart:io' show Platform;

/// Only used for iOS
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

class ScreenCaptureManagerFactory {

  static ScreenCaptureManager createManager() {
    if (Platform.isIOS) {
      return _ScreenCaptureManagerImplIOS();
    } else if (Platform.isAndroid) {
      return _ScreenCaptureManagerImplAndroid();
    } else {
      print('[ScreenCaptureManagerFactory] [createManager] Unsupported platform');
      return null;
    }
  }
}

abstract class ScreenCaptureManager {

  Future<bool> startScreenCapture();

  /// Only supports Android. On iOS, users need to actively stop screen capture
  Future<bool> stopScreenCapture();


  /// Only iOS needs to set
  /// [appGroupID] is both your `Runer` target and `BroadCast Upload Extension` target's AppGroup ID
  Future<void> setAppGroup(String appGroupID) {
    return null;
  }

  /// Only iOS needs to set
  /// [extensionName] is your `BroadCast Upload Extension` target's `Product Name`,
  /// or to be precise, the file name of the `.appex` product of the extension
  Future<void> setReplayKitExtensionName(String extensionName) {
    return null;
  }

  /// Only iOS needs to set
  /// [onlyCaptureVideo] indicates whether to capture only video buffer, otherwise it will capture video + audio buffer
  Future<void> setParamsForCreateEngine(int appID, String appSign, bool isTestEnv, bool onlyCaptureVideo) {
    return null;
  }

  /// Only iOS needs to set
  Future<void> setParamsForVideoConfig(int videoWidth, int videoHeight, int videoFPS, int videoBitrateKBPS) {
    return null;
  }

  /// Only iOS needs to set
  Future<void> setParamsForStartLive(String roomID, String userID, String userName, String streamID) {
    return null;
  }
}


/// Private implement
class _ScreenCaptureManagerImplAndroid extends ScreenCaptureManager {

  @override
  Future<bool> startScreenCapture() async {
    // TODO: implement startScreenCapture
    print('Android has not yet been implemented, currently only implemented in iOS');
    return false;
  }

  @override
  Future<bool> stopScreenCapture() async {
    // TODO: implement stopScreenCapture
    print('Android has not yet been implemented, currently only implemented in iOS');
    return false;
  }

}

/// Private implement
class _ScreenCaptureManagerImplIOS extends ScreenCaptureManager {

  String extensionName;
  String appGroupID;

  @override
  Future<bool> startScreenCapture() async {
    if (this.extensionName == null || this.appGroupID == null) {
      print('On iOS, please `setAppGroup` and `setReplayKitExtensionName` first');
      return false;
    }
    await ReplayKitLauncher.launchReplayKitBroadcast(this.extensionName);
    return true;
  }

  @override
  Future<bool> stopScreenCapture() async {
    print('On iOS, users need to actively stop screen capture');
    return false;
  }

  @override
  Future<void> setAppGroup(String appGroupID) async {
    this.appGroupID = appGroupID;
    await SharedPreferenceAppGroup.setAppGroup(appGroupID);
  }

  @override
  Future<void> setReplayKitExtensionName(String extensionName) {
    this.extensionName = extensionName;
    return null;
  }

  @override
  Future<void> setParamsForCreateEngine(int appID, String appSign, bool isTestEnv, bool onlyCaptureVideo) async {
    await SharedPreferenceAppGroup.setInt('ZG_SCREEN_CAPTURE_APP_ID', appID);
    await SharedPreferenceAppGroup.setString('ZG_SCREEN_CAPTURE_APP_SIGN', appSign);
    await SharedPreferenceAppGroup.setBool("ZG_SCREEN_CAPTURE_IS_TEST_ENV", isTestEnv);
    await SharedPreferenceAppGroup.setInt("ZG_SCREEN_CAPTURE_SCENARIO", 0);
    await SharedPreferenceAppGroup.setBool("ZG_SCREEN_CAPTURE_ONLY_CAPTURE_VIDEO", onlyCaptureVideo);
  }

  @override
  Future<void> setParamsForVideoConfig(int videoWidth, int videoHeight, int videoFPS, int videoBitrateKBPS) async {
    await SharedPreferenceAppGroup.setInt("ZG_SCREEN_CAPTURE_VIDEO_SIZE_WIDTH", videoWidth);
    await SharedPreferenceAppGroup.setInt("ZG_SCREEN_CAPTURE_VIDEO_SIZE_HEIGHT", videoHeight);
    await SharedPreferenceAppGroup.setInt("ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_FPS", videoFPS);
    await SharedPreferenceAppGroup.setInt("ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_BITRATE_KBPS", videoBitrateKBPS);
  }

  @override
  Future<void> setParamsForStartLive(String roomID, String userID, String userName, String streamID) async {
    await SharedPreferenceAppGroup.setString("ZG_SCREEN_CAPTURE_USER_ID", userID);
    await SharedPreferenceAppGroup.setString("ZG_SCREEN_CAPTURE_USER_NAME", userName);
    await SharedPreferenceAppGroup.setString("ZG_SCREEN_CAPTURE_ROOM_ID", roomID);
    await SharedPreferenceAppGroup.setString("ZG_SCREEN_CAPTURE_STREAM_ID", streamID);
  }
}