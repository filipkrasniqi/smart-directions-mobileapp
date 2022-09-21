import 'package:poli_direction/model/ui/list_item.dart';

class SDInstance implements Listable {
  int _id;
  String _name;

  SDInstance(this._id, this._name);

  String get name => _name;

  int get id => _id;

  SDInstance.fromJson(Map<String, dynamic> json)
      : _id = json['id_sd'],
        _name = json['name'];
}