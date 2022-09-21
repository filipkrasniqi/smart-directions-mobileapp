
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/sd_instances_bloc.dart';
import 'package:poli_direction/pois_widget.dart';
import 'package:poli_direction/utils/http.dart';

import 'model/api/sd_instance.dart';
import 'model/ui/list_item.dart';

class SDInstancesWidget extends StatefulWidget {

  SDInstancesBloc sdInstancesBloc;

  SDInstancesWidget({ Key key}) : super(key: key) {
    sdInstancesBloc = SDInstancesBloc();
  }

  @override
  _SDInstancesWidgetState createState() => _SDInstancesWidgetState(sdInstancesBloc);
}

class _SDInstancesWidgetState extends State<SDInstancesWidget> {
  SDInstancesBloc sdInstancesBloc;

  _SDInstancesWidgetState(this.sdInstancesBloc);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        StreamBuilder<List<Listable>>(
            stream: sdInstancesBloc.sdInstanceListStream,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                List<Listable> items = snapshot.data;
                List<Container> containers = items.map((neighbour) => Container(height: 50, child: Center(child: Text(neighbour.name)))).toList();
                return Expanded(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: containers.length,
                        itemBuilder: (BuildContext context, int index) {
                          //return containers.elementAt(index);
                          return InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(
                                      POIsWidget.routeName,
                                      arguments: items[index] as SDInstance
                                  );
                              },
                              child: new Card(
                                child: containers.elementAt(index))

                          );
                        }
                    )
                );
              } else {

                return Text(
                    'Downloading...',
                    style: TextStyle(color: Colors.black)
                );
              }
            }),
      ],
    );
  }
}