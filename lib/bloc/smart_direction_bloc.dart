import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/bloc.dart';
import 'package:poli_direction/bloc/mqtt_bloc.dart';
import 'package:poli_direction/model/api/poi.dart';
import 'package:poli_direction/model/api/sd_instance.dart';
import 'package:poli_direction/model/mqtt/direction.dart';
import 'package:poli_direction/model/ui/list_item.dart';
import 'package:poli_direction/utils/http.dart';
import 'package:poli_direction/utils/mqtt.dart';

class SmartDirectionBloc implements MQTTBloc {
  final _directionController = StreamController<Direction>();
  Map<String, Direction> _directions;

  SDInstance _sdInstance;
  POI _destination;

  MQTT mqtt;
  RestAPI http;

  SmartDirectionBloc() {
    mqtt = MQTT(this);
    http = RestAPI();
    _directions = Map();
  }

  void startDirection(SDInstance sdInstance, POI destination) async {
    // if here, mqtt can be started because brain is tracking
    mqtt.disconnect();
    this._sdInstance = sdInstance;
    this._destination = destination;
    // activate
    await http.activateDevice(_sdInstance, _destination);
    mqtt.connectWithHTTP(this._destination);
  }

  void startNavigation(SDInstance sdInstance, POI destination) {
    _sdInstance = sdInstance;
    _destination = destination;
  }

  void deactivateDevice() async {
    // TODO stop beacon
    bool result = await http.deactivateDevice();
    if(result) {
      _directionController.sink.add(new EndDirection());
    }
  }

  Stream<Direction> get directionStream => _directionController.stream;

  void setDirection(Direction direction) {
    this._directions[direction.effectorID] = direction;
    // search for the active effector
    Direction currentActive = null;
    try {
      currentActive = this._directions.values.firstWhere((element) => element.close);
      _directionController.sink.add(currentActive);
    } catch(Exception)  {
      print("NESSUNO ATTIVO");
    }
  }

  @override
  void dispose() {
    this._directionController.close();
  }

  @override
  void updateObject(String payload, String topic) {
    this.setDirection(Direction(payload, topic));
  }

}