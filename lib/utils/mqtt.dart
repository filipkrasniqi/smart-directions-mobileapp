import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:poli_direction/bloc/mqtt_bloc.dart';
import 'package:poli_direction/model/api/poi.dart';
import 'package:poli_direction/utils/device_manager.dart';
import 'package:poli_direction/utils/http.dart';

class MQTT {

  static final String MQTT_BROKER = '80.211.69.17';
  static final int MQTT_PORT = 1884;

  bool connected;
  String _clientIdentifier;
  MQTTBloc bloc;
  POI _destination;

  RestAPI http;

  String get clientIdentifier => _clientIdentifier;

  set clientIdentifier(String value) {
    _clientIdentifier = value;
  }

  MqttServerClient clientDevice;

  List<String> effectors;

  MQTT(MQTTBloc bloc) {
    this.connected = false;
    this.bloc = bloc;
    this.effectors = ["11:11:11:11:11:11", "22:22:22:22:22:22"];
  }

  void reset() {
    this.connected = false;
    this._destination = null;
  }

  void disconnect() {
    if(connected) {
      clientDevice.disconnect();
      this.reset();
    }
  }

  void connectWithHTTP(POI destination) async {
    this._destination = destination;
    DeviceModel model = await DeviceManager().getDeviceModel();
    clientIdentifier = model.deviceID;
    clientDevice =
        MqttServerClient.withPort(MQTT_BROKER, clientIdentifier, MQTT_PORT);
    clientDevice.logging(on: true);

    clientDevice.onConnected = () async {
      connected = true;

      clientDevice.subscribe(
          "directions/effector/activate/#", MqttQos.atMostOnce);

      clientDevice.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload;
        final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
        final topic = c[0].topic;

        if(topic.contains("directions/effector/activate")) {
          // here is different from normal effectors: I handle multiple device connecting, but I only show mine
          // for normal effectors, they must receive all devices and toggle correctly visualization
          if(payload.contains(model.getBeaconIdentifier())) {
            bloc.updateObject(payload, topic);
          }
        }

        print('Received message:$payload from topic: ${c[0].topic}>');
      });
    };

    clientDevice.onDisconnected = () => {
      connected = false
    };
    clientDevice.onUnsubscribed = (String topic) => {
      print('Unsubscribed topic: $topic')
    };
    clientDevice.onSubscribed = (String topic) => {
      print('Subscribed topic: $topic')
    };
    clientDevice.onSubscribeFail = (String topic) {
      print('Failed to subscribe $topic');
    };
    clientDevice.pongCallback = () => {
      print('Ping response client callback invoked')
    };

    String username = 'effector', password = 'effector';

    // first, connect as device and require to be activated
    MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs(username, password)
        .keepAliveFor(60)
    // .withWillTopic('ble/disconnect')
    // .withWillMessage('Will message')
        .startClean()
    //.withWillQos(MqttQos.atLeastOnce);
        .withWillQos(MqttQos.atMostOnce);
    clientDevice.connectionMessage = connMessage;

    connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs(username, password)
        .keepAliveFor(60)
    // .withWillTopic('ble/disconnect')
    // .withWillMessage('Will message')
        .startClean()
    //.withWillQos(MqttQos.atLeastOnce);
        .withWillQos(MqttQos.atMostOnce);

    try {
    // await client.connect();
    await clientDevice.connect(username, password);
    } catch (e) {
    print('Exception: $e');
    clientDevice.disconnect();
    }
  }

  void connect(POI destination) async {
    this._destination = destination;
    DeviceModel model = await DeviceManager().getDeviceModel();

    clientIdentifier = model.deviceID;
    clientDevice =
      MqttServerClient.withPort(MQTT_BROKER, clientIdentifier, MQTT_PORT);
    clientDevice.logging(on: true);
    clientDevice.onConnected = () async {
      connected = true;

      final builder1 = MqttClientPayloadBuilder();
      String id = model.beaconUUID.replaceAll("-", "").toLowerCase();
      builder1.addString("${_destination.id}\$${_destination.idBuilding}\$${id}");
      clientDevice.publishMessage('directions/device/activate/${model.deviceID}', MqttQos.atMostOnce, builder1.payload);

      // TODO sono arrivao a riuscire a inviare agli effettori!!! Testare ora perchè di qui il client non funziona. Può essere perchè istanzio due mqtt diversi...
      // TODO ho cancellato i nodi perchè durante le reinizializzazioni si sono aggiunti multipli; rimangono però dei nodi nonostante in mappa non si visualizzano, sistemare e capire perchè. Immagino durante la init_node perchè prima non c'era sto prob

      clientDevice.disconnect();

      // then, connect as effector and start tracking
      String username = "effector";
      String password = "effector";

      String clientIdentifierEffector = "11:11:11:11:11:11";

      // TODO rimosso su broker controllo in ricezione: andrà riaggiunto in aclfile che solo effettore con ID può ricevere messaggio a lui destinato

      MqttServerClient clientEffector = MqttServerClient.withPort(MQTT_BROKER, clientIdentifierEffector, MQTT_PORT);

      MqttConnectMessage connMessage = MqttConnectMessage()
          .withClientIdentifier(clientIdentifierEffector)
          .authenticateAs(username, password)
          .keepAliveFor(60)
      // .withWillTopic('ble/disconnect')
      // .withWillMessage('Will message')
          .startClean()
      //.withWillQos(MqttQos.atLeastOnce);
          .withWillQos(MqttQos.atMostOnce);
      clientEffector.connectionMessage = connMessage;
      try {
        // await client.connect();
        await clientEffector.connect(username, password);
      } catch (e) {
        print('Exception: $e');
        clientEffector.disconnect();
      }

      clientEffector.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload;
        final payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
        final topic = c[0].topic;

        if(topic.contains("directions/effector/activate")) {
          // here is different from normal effectors: I handle multiple device connecting, but I only show mine
          // for normal effectors, they must receive all devices and toggle correctly visualization
          if(payload.contains(model.getBeaconIdentifier())) {
            bloc.updateObject(payload, topic);
          }
        }

        print('Received message:$payload from topic: ${c[0].topic}>');
      });

      clientEffector.onConnected = () {
        connected = true;
        clientEffector.subscribe("directions/effector/activate/#", MqttQos.atMostOnce);
      };

      clientEffector.onDisconnected = () => {
        connected = false
      };
      clientEffector.onUnsubscribed = (String topic) => {
        print('Unsubscribed topic: $topic')
      };
      clientEffector.onSubscribed = (String topic) => {
        print('Subscribed topic: $topic')
      };
      clientEffector.onSubscribeFail = (String topic) {
        print('Failed to subscribe $topic');
      };
      clientEffector.pongCallback = () => {
        print('Ping response client callback invoked')
      };


    };

    clientDevice.onDisconnected = () => {
      connected = false
    };
    clientDevice.onUnsubscribed = (String topic) => {
      print('Unsubscribed topic: $topic')
    };
    clientDevice.onSubscribed = (String topic) => {
      print('Subscribed topic: $topic')
    };
    clientDevice.onSubscribeFail = (String topic) {
      print('Failed to subscribe $topic');
    };
    clientDevice.pongCallback = () => {
      print('Ping response client callback invoked')
    };

    String username = 'device', password = 'device';

    // first, connect as device and require to be activated
    MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs(username, password)
        .keepAliveFor(60)
    // .withWillTopic('ble/disconnect')
    // .withWillMessage('Will message')
        .startClean()
    //.withWillQos(MqttQos.atLeastOnce);
        .withWillQos(MqttQos.atMostOnce);
    clientDevice.connectionMessage = connMessage;

    connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .authenticateAs(username, password)
        .keepAliveFor(60)
    // .withWillTopic('ble/disconnect')
    // .withWillMessage('Will message')
        .startClean()
    //.withWillQos(MqttQos.atLeastOnce);
        .withWillQos(MqttQos.atMostOnce);
    try {
      // await client.connect();
      await clientDevice.connect(username, password);
    } catch (e) {
      print('Exception: $e');
      clientDevice.disconnect();
    }
  }

}