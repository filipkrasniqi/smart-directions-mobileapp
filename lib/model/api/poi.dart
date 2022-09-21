import 'package:poli_direction/model/ui/list_item.dart';

class POI implements Listable {
  int _id;
  String _name;
  int _idBuilding;

  POI(this._id, this._name, this._idBuilding);

  String get name => _name;

  int get id => _id;

  int get idBuilding => _idBuilding;

  POI.fromJson(Map<String, dynamic> json)
      : _id = json['idPOI'] as int,
        _name = json['name'],
        _idBuilding = json['idBuilding'] as int;
}