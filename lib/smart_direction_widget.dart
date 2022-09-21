import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poli_direction/bloc/sd_instances_bloc.dart';
import 'package:poli_direction/utils/beacon.dart';
import 'package:poli_direction/utils/http.dart';

import 'bloc/pois_bloc.dart';
import 'bloc/smart_direction_bloc.dart';
import 'model/api/poi.dart';
import 'model/api/sd_instance.dart';
import 'model/mqtt/direction.dart';
import 'model/ui/list_item.dart';

class SmartDirectionWidget extends StatefulWidget {
  SmartDirectionBloc navigationBloc;
  BLEBeacon _beacon;

  SmartDirectionWidget({Key key}) : super(key: key) {
    navigationBloc = SmartDirectionBloc();
    _beacon = BLEBeacon();
    _beacon.start();
  }

  @override
  _SmartDirectionWidgetState createState() =>
      _SmartDirectionWidgetState(navigationBloc);

  static String get routeName => "/navigation";

  String get title => "Navigazione";
}

class _SmartDirectionWidgetState extends State<SmartDirectionWidget> {
  SmartDirectionBloc navigationBloc;

  _SmartDirectionWidgetState(this.navigationBloc);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    POI poi = args['PoI'] as POI;
    SDInstance sdInstance = args['sdInstance'] as SDInstance;

    // TODO devo fare communicate mqtt di attivarmi XXX
    // TODO inoltre devo fare partire il beacon, motivo per il quale i cosi non ricevono...
    /*
    BeaconBroadcast beacon = BeaconBroadcast()
        .setUUID('39ED98FF-2900-441A-802F-<MAC>')
        .setMajorId(1)
        .setIdentifier("11112222333344445555666677778888")
        .setMinorId(100);

    beacon.checkTransmissionSupported().then((value) => {
      print(value)
      // TODO if not supported???
    });
     */

    navigationBloc.startDirection(sdInstance, poi);

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Direction>(
                stream: navigationBloc.directionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Direction direction = snapshot.data;
                    if(direction.isEnd()) {
                      Navigator.of(context).pop();
                      return Text('Closing...',
                          style: TextStyle(color: direction.color));
                    } else {
                      Map<String, CustomPainter> mapPainters = {
                        'Right': RightLinePainter(),
                        'Left': LeftLinePainter(),
                        'Top': TopLinePainter(),
                        'Bottom': BottomLinePainter(),
                        'All': AllLinesPainter()
                      };
                      Map<String, String> mapImage = {
                        'Destra': 'right',
                        'Sinistra': 'left',
                        'Avanti': 'top',
                        'Indietro': 'bottom',
                        'Arrivato': 'destination',
                        'Partito': 'start.png',
                      };
                      Map<Color, String> mapColors = {
                        Colors.red: 'red',
                        Colors.blue: 'blue',
                        Colors.green: 'green',
                        Colors.orange: 'orange'
                      };

                      //List<Container> containers = items.map((neighbour) => Container(height: 50, child: Center(child: Text(neighbour.name)))).toList();
                      return Expanded(
                          child: Column(children: [
                            Text('Follow this color', style: TextStyle(fontSize: 15, color: direction.color)),
                            Row(
                              children: [
                                Image.asset(
                                    "assets/${mapImage[direction.direction()]}-${mapColors[direction.color]}.png",
                                    width: 300,
                                    height: 300,
                                    fit: BoxFit.cover)
                              ],
                            ),
                            CustomPaint(
                              size: Size(300, 300),
                              painter: mapPainters[direction.facet()],
                            ),
                            OutlineButton(
                                child: const Text("Concludi"),
                                onPressed: () {
                                  navigationBloc.deactivateDevice();
                                })
                          ]));
                    }
                  } else {
                    return Text('Waiting for anchor...',
                        style: TextStyle(color: Colors.black));
                  }
                })
          ],
        ));
  }
}

class AllLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    Offset start = Offset(0, .25 * size.height);
    Offset end = Offset(size.width, .25 * size.height);

    canvas.drawLine(start, end, paint);

    start = Offset(0, .75 * size.height);
    end = Offset(size.width, .75 * size.height);

    canvas.drawLine(start, end, paint);

    start = Offset(size.width, .25 * size.height);
    end = Offset(size.width, .75 * size.height);

    canvas.drawLine(start, end, paint);

    start = Offset(0, .25 * size.height);
    end = Offset(0, .75 * size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TopLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    Offset start = Offset(0, .25 * size.height);
    Offset end = Offset(size.width, .25 * size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BottomLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    Offset start = Offset(0, .75 * size.height);
    Offset end = Offset(size.width, .75 * size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    Offset start = Offset(size.width, .25 * size.height);
    Offset end = Offset(size.width, .75 * size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class LeftLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 15;

    Offset start = Offset(0, .25 * size.height);
    Offset end = Offset(0, .75 * size.height);

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
