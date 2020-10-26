//
//  screen_capture_init_page.dart.dart
//  zego_express_screen_capture
//
//  Created by Patrick Fu on 2020/10/24.
//  Copyright © 2020 Zego. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zego_express_engine/zego_express_engine.dart';

import 'package:zego_express_screen_capture/config/zego_config.dart';
import 'package:zego_express_screen_capture/ui/zego_ui_tool.dart';
import 'package:zego_express_screen_capture/pages/screen_capture_login_page.dart';


import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';

class ScreenCaptureInitPage extends StatefulWidget {

  @override
  _ScreenCaptureInitPageState createState() => new _ScreenCaptureInitPageState();
}

class _ScreenCaptureInitPageState extends State<ScreenCaptureInitPage> {

  final TextEditingController _appGroupEdController = new TextEditingController();
  final TextEditingController _appIDEdController = new TextEditingController();
  final TextEditingController _appSignEdController = new TextEditingController();

  String _version;

  @override
  void initState() {
    super.initState();

    ZegoConfig.instance.load().then((value) {
      if (ZegoConfig.instance.appGroup.isNotEmpty) {
        _appGroupEdController.text = ZegoConfig.instance.appGroup;
      }

      if (ZegoConfig.instance.appID > 0) {
        _appIDEdController.text = ZegoConfig.instance.appID.toString();
      }

      if (ZegoConfig.instance.appSign.isNotEmpty) {
        _appSignEdController.text = ZegoConfig.instance.appSign;
      }
    });

    ZegoExpressEngine.getVersion().then((version) {
      print('[SDK Version] $version');
      setState(() {
        _version = version;
      });
    });
  }


  void onButtonPressed() {

    String appGroup = _appGroupEdController.text.trim();
    String strAppID = _appIDEdController.text.trim();
    String appSign = _appSignEdController.text.trim();

    if (appGroup.isEmpty || strAppID.isEmpty || appSign.isEmpty) {
      ZegoUITool.showAlert(context, 'AppID or AppSign or AppGroup cannot be empty');
      return;
    }

    int appID = int.tryParse(strAppID);
    if (appID == null) {
      ZegoUITool.showAlert(context, 'AppID is invalid, should be int');
      return;
    }

    ZegoConfig.instance.appGroup = appGroup;
    ZegoConfig.instance.appID = appID;
    ZegoConfig.instance.appSign = appSign;
    ZegoConfig.instance.saveConfig();

    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return ScreenCaptureLoginPage();
    }));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Step1 CreateEngine'),
      ),
      body: SafeArea(
        child: GestureDetector(

          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Text('Native SDK Version: '),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                    ),
                    Expanded(
                      child: Text('$_version'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                Row(
                  children: <Widget>[
                    Text('User ID: '),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                    ),
                    Text(ZegoConfig.instance.userID??'unknown'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  children: <Widget>[
                    Text('User Name: '),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                    ),
                    Text(ZegoConfig.instance.userName??'unknown'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  children: <Widget>[
                    Text('AppGroup: (for iOS ReplayKit)'),
                    GestureDetector(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        child: Icon(Icons.info_outline)
                      ),
                      onTap: () {
                        ZegoUITool.showAlert(context,
                          'If you want to experience this feature, please open [Runner.workspace] in `ios/` directory. '
                          'navigator on the left of Xcode, find the [App Groups] column in the [Signing & Capabilities] tab of '
                          'both Target [Runner] and [BroadcastExtensionFlutter], click the `+` to add a custom '
                          'App Group ID and enable it; then fill in this App Group ID into the text field'
                          );
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _appGroupEdController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
                    hintText: 'Please enter AppGroup (for iOS ReplayKit)',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
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
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  children: <Widget>[
                    Text('AppID:'),
                    GestureDetector(
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        child: Icon(Icons.info_outline)
                      ),
                      onTap: () {
                        ZegoUITool.showAlert(context, 'AppID and AppSign are the unique identifiers of each customer, please apply on https://zego.im');
                      },
                    ),
                  ],
                ),
                TextField(
                  controller: _appIDEdController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
                    hintText: 'Please enter AppID',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
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
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  children: <Widget>[
                    Text('AppSign:'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                TextField(
                  controller: _appSignEdController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
                    hintText: 'Please enter AppSign',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
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
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  children: <Widget>[
                    Text('SDK Environment  '),
                    Expanded(
                      child: Text('(Please select the environment corresponding to AppID)',
                        style: TextStyle(
                          fontSize: 10.0
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: ZegoConfig.instance.isTestEnv,
                      onChanged: (value) {
                        setState(() {
                          ZegoConfig.instance.isTestEnv = value;
                          ZegoConfig.instance.saveConfig();
                        });
                      },
                    ),
                    Text('Test'),

                    Checkbox(
                      value: !ZegoConfig.instance.isTestEnv,
                      onChanged: (value) {
                        setState(() {
                          ZegoConfig.instance.isTestEnv = !value;
                          ZegoConfig.instance.saveConfig();
                        });
                      },
                    ),
                    Text('Formal'),
                  ],
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
                    child: Text('Next',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                    onPressed: onButtonPressed,
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

}