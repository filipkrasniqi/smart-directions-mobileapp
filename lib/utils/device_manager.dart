
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_mac/get_mac.dart';

class DeviceManager {

  DeviceManager();

  Future<DeviceModel> getDeviceModel() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GetMac.macAddress;
    } on Exception {
      platformVersion = 'Failed to get Device MAC Address.';
    }
    return DeviceModel.getInstance(await this._getDeviceId(), platformVersion);
  }

  Future<String> _getDeviceId() async {
    return await DeviceId.getID;
  }

  String _getDeviceOSType() {
    return Platform.isIOS ? "ios" : Platform.isAndroid ? "android" : null;
  }

  Future<String> _getDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    }
  }

  Future<String> _getDeviceOSVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      return "$release, $sdkInt";
    } else {
      return null;
    }
  }
}

class DeviceModel {
  String _deviceID;
  String _beaconUUID;
  String _beaconIdentifier;
  String _macAddress;

  String get macAddress => _macAddress;

  static DeviceModel _instance;



  static String generateRandomString(int len) {
    var r = Random();
    const _chars = '1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  static String generateRandomStringHex(int len) {
    var r = Random();
    const _chars = '0123456789ABCDEF';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }

  DeviceModel(this._deviceID, this._macAddress) {
    this._beaconUUID = '${generateRandomStringHex(8)}-${generateRandomStringHex(4)}-${generateRandomStringHex(4)}-${generateRandomStringHex(4)}-${generateRandomStringHex(12)}';//'42ED98FF-2900-441A-802F-9C398FC199D2';//${_deviceID}'; // TODO deve diventare randoooooom!!!!!!
    this._beaconIdentifier = generateRandomString(32);
  }

  static DeviceModel getInstance(String deviceID, String macAddress) {
    if(_instance == null) {
      _instance = DeviceModel(deviceID, macAddress);
    }
    return _instance;
  }

  String get deviceID => _deviceID;

  String get beaconIdentifier => _beaconIdentifier;

  String get beaconUUID => _beaconUUID;

  String getBeaconIdentifier() {
    return this._beaconUUID.replaceAll("-", "").toLowerCase();
  }
}