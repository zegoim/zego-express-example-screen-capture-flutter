//
//  screen_capture_manager_impl_ios.dart
//  zego-express-example-screen-capture-flutter
//
//  Created by Patrick Fu on 2020/10/27.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:zego_express_screen_capture/manager/screen_capture_manager.dart';

/// Only used for iOS
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

/// Private implementation
class ScreenCaptureManagerImplIOS extends ScreenCaptureManager {

  String extensionName;
  String appGroupID;

  @override
  Future<bool> startScreenCapture() async {
    if (this.extensionName == null || this.appGroupID == null) {
      print('On iOS, please `setAppGroup` and `setReplayKitExtensionName` first');
      return false;
    }
    return ReplayKitLauncher.launchReplayKitBroadcast(this.extensionName);
  }

  @override
  Future<bool> stopScreenCapture() async {
    return await ReplayKitLauncher.finishReplayKitBroadcast('ZGFinishReplayKitBroadcastNotificationName');
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
  Future<void> setParamsForCreateEngine(int appID, String appSign, bool onlyCaptureVideo) async {
    await SharedPreferenceAppGroup.setInt('ZG_SCREEN_CAPTURE_APP_ID', appID);
    await SharedPreferenceAppGroup.setString('ZG_SCREEN_CAPTURE_APP_SIGN', appSign);
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