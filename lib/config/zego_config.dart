import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:math' show Random;

import 'package:zego_express_engine/zego_express_engine.dart' show ZegoScenario;

class ZegoConfig {

  static final ZegoConfig instance = ZegoConfig._internal();

  String appGroup;

  int appID;
  String appSign;
  int scenario;

  String userID;
  String userName;

  String roomID;
  String streamID;

  ZegoConfig._internal();

  Future<void> load() async {
    SharedPreferences config = await SharedPreferences.getInstance();

    this.appGroup = config.getString('appGroup') ?? '';

    this.appID = config.getInt('appID') ?? 0;
    this.appSign = config.getString('appSign') ?? '';
    this.scenario = config.getInt('scenario') ?? ZegoScenario.General.index;

    this.userID = config.getString('userID') ?? '${Platform.operatingSystem}-${new Random().nextInt(9999999).toString()}';
    this.userName = config.getString('userName') ?? 'user-$userID';

    this.roomID = config.getString('roomID') ?? '';
    this.streamID = config.getString('streamID') ?? '';
  }

  Future<void> saveConfig() async {

    SharedPreferences config = await SharedPreferences.getInstance();

    config.setString('appGroup', this.appGroup);

    config.setInt('appID', this.appID);
    config.setString('appSign', this.appSign);
    config.setInt('scenario', this.scenario);

    config.setString('userID', this.userID);
    config.setString('userName', this.userName);

    config.setString('roomID', this.roomID);
    config.setString('streamID', this.streamID);
  }

}