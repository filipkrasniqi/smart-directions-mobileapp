import 'dart:convert';
import 'dart:io';

import 'package:device_id/device_id.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:http/http.dart';
import 'dart:core';
import 'package:logger/logger.dart';
import 'package:poli_direction/model/api/poi.dart';
import 'package:poli_direction/model/api/sd_instance.dart';

import 'device_manager.dart';

class RestAPI {

  static const int timeoutRequestSeconds = 10;

  static final String HOST_URL = "https://5a11-5-90-42-113.ngrok.io/";
  static final String BASE_API_URL = "${HOST_URL}device/";
  static final String SD_INSTANCES_URL = "${BASE_API_URL}sd_instances";
  static String POIS_URL(SDInstance sdInstance) => "${BASE_API_URL}${sdInstance.id}/pois";
  static String ACTIVATE_DEVICE_URL(String idDevice) => "${BASE_API_URL}${idDevice}/activate";
  static String DEACTIVATE_DEVICE_URL(String idDevice) => "${BASE_API_URL}${idDevice}/deactivate";

  static final BaseOptions options = new BaseOptions(
    baseUrl: HOST_URL,
    connectTimeout: timeoutRequestSeconds * 1000,
    receiveTimeout: timeoutRequestSeconds * 1000,
  );

  /// Singleton: makes use of factory constructors
  static final RestAPI _singleton = RestAPI._internal();

  factory RestAPI() {
    return _singleton;
  }

  RestAPI._internal();


  final Dio dio = new Dio(options);
  final Logger logger = Logger();

  /// Function returning the default header for any request without auth
  Map<String, String> defaultHeader() {
    return {
















      
      HttpHeaders.contentTypeHeader: "application/json",
    };
  }

  /// Function executing the post given URL and eventually the body and a non-default header
  Future<Response> defaultPost(String url,
      {Map<String, dynamic> body, Map<String, String> headers}) async {
    url = Uri.https(HOST_URL, url).toString();
    if (headers == null) {
      headers = this.defaultHeader();
    }
    Response response;
    if(body == null) {
      body = {};
    }
    if (body != null) {
      try {
        response = await dio.post(url, data: body.toString(), options: Options(
            headers: headers
        ));
      } on DioError catch(e) {
        response = e.response ?? Response(data: "", statusCode: 500);
      }

      logger.d("$url ${body.toString()} -> ${response.statusCode} ${response.data.toString()}");
      //print("API: $url ${body.toString()} -> ${response.statusCode} ${response.data.toString()}");
    }

    return response;
  }

  /// Function executing the get given URL and eventually an unencoded param in path, the query parameters as map and a non-default header
  Future<Response> defaultGet(
      String url, {
        String unencodedParamInPath,
        Map<String, String> queryParameters,
        Map<String, String> headers,
      }) async {
    if (unencodedParamInPath != null) {
      url = Uri.https(HOST_URL, '$url/$unencodedParamInPath', queryParameters)
          .toString();
    } else {
      url = Uri.https(HOST_URL, url).toString();
    }
    if (headers == null) {
      headers = this.defaultHeader();
    }
    if(queryParameters == null) {
      queryParameters = {};
    }

    Response response;
    try {
      response = await dio.get(url, queryParameters: queryParameters, options: Options(
        headers: headers,
      ));
    } on DioError catch(e) {
      response = e.response ?? Response(data: "", statusCode: 500);
    }

    logger.d("$url -> ${response.statusCode} ${response.data.toString()}");

    return response;
  }

  /// Function executing the put given URL, body and eventually a non-default header
  Future<Response> defaultPut(String url, Map<String, dynamic> body,
      [Map<String, String> headers]) async {
    url = Uri.https(HOST_URL, url).toString();
    if (headers == null) {
      headers = this.defaultHeader();
    }
    Response response;

    try {
      response = await dio.put(url, data: body.toString(), options: Options(
          headers: headers
      ));
    } on DioError catch(e) {
      response = e.response ?? Response(data: "", statusCode: 500);
    }

    logger.d("$url ${body.toString()} -> ${response.statusCode} ${response.data.toString()}");

    return response;
  }

  /// Performs GET request to retrieve SD instances
  Future<List<SDInstance>> getSDInstances() async {
    String url = SD_INSTANCES_URL;
    Response response;
    try {
      response = await dio.get(url);
    } catch (error) {
      //In case of error, return internal server error
      response = Response(data: "", statusCode: 500);
    }

    switch (response.statusCode) {
      case 200:
        List l = response.data;
        return l.map((model) => SDInstance.fromJson(model)).toList();
        break;
      default:
        throw('Error');
    }


  }

  /// Performs GET request to retrieve POIs related to a SD instance
  Future<List<POI>> getPOIs(SDInstance sdInstance) async {
    String url = POIS_URL(sdInstance);
    Response response;
    try {
      response = await dio.get(url);
    } catch (error) {
      //In case of error, return internal server error
      response = Response(data: "", statusCode: 500);
    }

    switch (response.statusCode) {
      case 200:
        List l = response.data;
        return l.map((model) => POI.fromJson(model)).toList();
        break;
      default:
        throw('Error');
    }


  }

  /// Performs POST request to activate the device
  Future<bool> activateDevice(SDInstance sdInstance, POI destination) async {
    String url = ACTIVATE_DEVICE_URL((await DeviceManager().getDeviceModel()).getBeaconIdentifier());
    Response response;
    try {
      response = await dio.post(url, data:{'id_sd': sdInstance.id, 'id_building': destination.idBuilding, 'id_POI': destination.id});
    } catch (error) {
      //In case of error, return internal server error
      response = Response(data: "", statusCode: 500);
    }

    switch (response.statusCode) {
      case 200:
        return true;
        break;
      default:
        throw('Error');
    }
  }

  /// Performs POST request to activate the device
  Future<bool> deactivateDevice() async {
    String url = DEACTIVATE_DEVICE_URL((await DeviceManager().getDeviceModel()).getBeaconIdentifier());
    Response response;
    try {
      response = await dio.post(url);
    } catch (error) {
      //In case of error, return internal server error
      response = Response(data: "", statusCode: 500);
    }

    switch (response.statusCode) {
      case 200:
        return true;
        break;
      default:
        throw('Error');
    }
  }
}