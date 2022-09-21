import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:poli_direction/utils/device_manager.dart';

class BLEBeacon {

  BeaconBroadcast beacon;

  void start() async {
    DeviceModel model = await DeviceManager().getDeviceModel();

    beacon = BeaconBroadcast()
        .setUUID(model.beaconUUID.toUpperCase())
        .setMajorId(1)
        .setMinorId(100);

    beacon.checkTransmissionSupported().then((value) => {
      beacon.start()
    });
  }

  void stop() {
    beacon.stop();
  }
}