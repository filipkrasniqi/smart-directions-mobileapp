import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/bloc.dart';
import 'package:poli_direction/model/api/sd_instance.dart';
import 'package:poli_direction/model/ui/list_item.dart';
import 'package:poli_direction/utils/http.dart';

class SDInstancesBloc implements Bloc {
  final _sdInstanceController = StreamController<List<Listable>>();
  List<SDInstance> values = new List();

  RestAPI http;


  SDInstancesBloc() {
    http = RestAPI();

    http.getSDInstances().then((value) => {
      setInstances(value)
    });
  }

  Stream<List<Listable>> get sdInstanceListStream => _sdInstanceController.stream;

  void setInstances(List<SDInstance> values) {
    this.values = values;
    _sdInstanceController.sink.add(this.values);
  }

  @override
  void dispose() {
    this._sdInstanceController.close();
  }

}