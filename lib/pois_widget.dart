
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/sd_instances_bloc.dart';
import 'package:poli_direction/model/api/poi.dart';
import 'package:poli_direction/smart_direction_widget.dart';
import 'package:poli_direction/utils/http.dart';

import 'bloc/pois_bloc.dart';
import 'model/api/sd_instance.dart';
import 'model/ui/list_item.dart';

class POIsWidget extends StatefulWidget {

  POIsBloc poisBloc;

  POIsWidget({ Key key}) : super(key: key) {
    poisBloc = POIsBloc();
  }

  @override
  _POIsWidgetState createState() => _POIsWidgetState(poisBloc);

  static String get routeName => "/pois";
  String get title => "Punti di interesse";
}

class _POIsWidgetState extends State<POIsWidget> {
  POIsBloc poisBloc;

  _POIsWidgetState(this.poisBloc);

  @override
  Widget build(BuildContext context) {

    final SDInstance sdInstance =
      ModalRoute.of(context).settings.arguments as SDInstance;

    poisBloc.setSDInstance(sdInstance);

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<List<Listable>>(
                stream: poisBloc.sdInstanceListStream,
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
                                        SmartDirectionWidget.routeName,
                                        arguments: {'sdInstance': sdInstance, 'PoI': items[index] as POI}
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
        )
    );
  }
}