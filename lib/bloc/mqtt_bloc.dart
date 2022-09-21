import 'bloc.dart';

abstract class MQTTBloc implements Bloc {
  void updateObject(String payload, String topic);
}