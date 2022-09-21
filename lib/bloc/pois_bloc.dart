import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/bloc.dart';
import 'package:poli_direction/model/api/poi.dart';
import 'package:poli_direction/model/api/sd_instance.dart';
import 'package:poli_direction/model/ui/list_item.dart';
import 'package:poli_direction/utils/http.dart';

class POIsBloc implements Bloc {
  final _sdInstanceController = StreamController<List<Listable>>();
  List<POI> values = new List();

  SDInstance _sdInstance;

  RestAPI http;


  POIsBloc() {
    http = RestAPI();
  }

  void setSDInstance(SDInstance sdInstance) {
    _sdInstance = sdInstance;

    http.getPOIs(sdInstance).then((value) => {
      setInstances(value)
    });
  }

  Stream<List<Listable>> get sdInstanceListStream => _sdInstanceController.stream;

  void setInstances(List<POI> values) {
    this.values = values;
    _sdInstanceController.sink.add(this.values);
  }

  @override
  void dispose() {
    this._sdInstanceController.close();
  }

}