//
//  screen_capture_login_page.dart
//  zego_express_screen_capture
//
//  Created by Patrick Fu on 2020/10/25.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_screen_capture/ui/zego_ui_tool.dart';
import 'package:zego_express_screen_capture/config/zego_config.dart';

import 'package:zego_express_screen_capture/manager/screen_capture_manager.dart';

class ScreenCaptureLoginPage extends StatefulWidget {
  @override
  _ScreenCaptureLoginPageState createState() => _ScreenCaptureLoginPageState();
}

class _ScreenCaptureLoginPageState extends State<ScreenCaptureLoginPage> {

  final TextEditingController _roomIDEdController = new TextEditingController();
  final TextEditingController _streamIDEdController = new TextEditingController();

  ScreenCaptureManager manager = ScreenCaptureManagerFactory.createManager();
  bool screenCaptureBtnClickable = true;

  @override
  void initState() {
    super.initState();

    if (ZegoConfig.instance.roomID.isNotEmpty) {
      _roomIDEdController.text = ZegoConfig.instance.roomID;
    }
    if (ZegoConfig.instance.streamID.isNotEmpty) {
      _streamIDEdController.text = ZegoConfig.instance.streamID;
    }

    // Need to set app group ID and broadcast upload extension name first
    manager.setAppGroup(ZegoConfig.instance.appGroup);
    manager.setReplayKitExtensionName('BroadcastExtensionFlutter');
  }

  void syncConfig() {
    String roomID = _roomIDEdController.text.trim();
    String streamID = _streamIDEdController.text.trim();

    if (roomID.isEmpty || streamID.isEmpty) {
      ZegoUITool.showAlert(context, 'RoomID or StreamID cannot be empty');
      return;
    }

    ZegoConfig.instance.roomID = roomID;
    ZegoConfig.instance.streamID = streamID;
    ZegoConfig.instance.saveConfig();
  }

  void startScreenCapture() async {

    setState(() {
      screenCaptureBtnClickable = false;
    });

    syncConfig();

    // Set necessary params (just for iOS)
    await manager.setParamsForCreateEngine(ZegoConfig.instance.appID, ZegoConfig.instance.appSign, ZegoConfig.instance.isTestEnv, false);
    await manager.setParamsForVideoConfig(window.physicalSize.width.toInt(), window.physicalSize.height.toInt(), 15, 3000);
    await manager.setParamsForStartLive(ZegoConfig.instance.roomID, ZegoConfig.instance.userID, ZegoConfig.instance.userName, ZegoConfig.instance.streamID);

    // Start screen capture
    await manager.startScreenCapture();

    setState(() {
      screenCaptureBtnClickable = true;
    });
  }

  void stopScreenCapture() async {
    setState(() {
      screenCaptureBtnClickable = false;
    });

    await manager.stopScreenCapture();

    setState(() {
      screenCaptureBtnClickable = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ScreenCapture'),
      ),
      body: GestureDetector(

        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),

        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
              ),
              Row(
                children: <Widget>[
                  Text('RoomID: '),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
              ),
              TextField(
                controller: _roomIDEdController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
                  hintText: 'Please enter the room ID:',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black45,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff0e88eb),
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
              ),
              Text('RoomID represents the identification of a room, it needs to ensure that the RoomID is globally unique, and no longer than 255 bytes',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45
                ),
                maxLines: 2,
                softWrap: true,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
              ),
              Row(
                children: <Widget>[
                  Text('StreamID: '),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
              ),
              TextField(
                controller: _streamIDEdController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
                  hintText: 'Please enter streamID',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black45
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xff0e88eb)
                    )
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
              ),
              Text('StreamID must be globally unique and the length should not exceed 255 bytes',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black45
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
              ),
              Container(
                padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Color(0xff0e88eb),
                ),
                width: 240.0,
                height: 60.0,
                child: CupertinoButton(
                  child: Text('Start Screen Capture',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: screenCaptureBtnClickable ? startScreenCapture : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
              ),
              Container(
                padding: const EdgeInsets.all(0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Color(0xff0e88eb),
                ),
                width: 240.0,
                height: 60.0,
                child: CupertinoButton(
                  child: Text('Stop Screen Capture',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  onPressed: screenCaptureBtnClickable ? stopScreenCapture: null,
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}