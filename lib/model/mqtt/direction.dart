import 'package:flutter/material.dart';

class Direction {
  int _face;
  int _feedback;
  bool _close;
  String _effectorID;
  int _color;

  static Map<int, Color> colors = {
    0: Colors.red,
    1: Colors.green,
    2: Colors.blue,
    3: Colors.orange
  };

  Direction(String payloadMQTT, String topicMQTT) {
    if(payloadMQTT != null && topicMQTT != null) {
      List<String> splits = payloadMQTT.split("\$");
      String device = splits[0];  // useless here: we already checked if it is correct
      _close = splits[1]=='1';
      _face = int.parse(splits[2]);
      _feedback = int.parse(splits[3]);
      _color = int.parse(splits[4]);
      List<String> splitsTopic = topicMQTT.split("/");
      this._effectorID = splitsTopic.last;
    }
  }

  Color get color => colors[_color];

  String get effectorID => _effectorID;

  bool get close => _close;

  int get feedback => _feedback;

  int get face => _face;

  String direction() {
    return feedback == 0 ? "Avanti" : feedback == 1 ? "Destra" : feedback == 2 ? "Indietro" : feedback == 3 ? "Sinistra" : feedback == 4 ? "Arrivato" : "Partito";
  }

  String facet() {
    return face == 0 ? "Top" : face == 1 ? "Right" : face == 2 ? "Bottom" : face == 3 ? "Left" : "All";
  }

  bool isEnd() {
    return false;
  }
}

class EndDirection extends Direction {
  EndDirection() : super(null, null);

  bool isEnd() {
    return true;
  }

}