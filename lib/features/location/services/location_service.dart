import 'dart:async';
import 'package:location/location.dart';

class LocationService {
  late final Location _location = Location();

  LocationData? _locationData;
  StreamSubscription<LocationData>? _locationSubscription;

  void init() {
    _setupLocationSettings();
  }

  void _setupLocationSettings() async {
    if (await _isServiceEnabled() && await _isPermissionGranted()) {
      await _location.enableBackgroundMode(enable: true);
    }
  }

  Future<bool> _isServiceEnabled() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    return serviceEnabled;
  }

  Future<bool> _isPermissionGranted() async {
    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    return permissionStatus == PermissionStatus.granted ||
        permissionStatus == PermissionStatus.grantedLimited;
  }

  Future<LocationData?> getCurrentLocation() async {
    if (await _isServiceEnabled() && await _isPermissionGranted()) {
      _locationData = await _location.getLocation();
    } else {
      _locationData = null;
    }

    return _locationData;
  }

  void subscribeOnUpdates(Function(LocationData) onChanged) async {
    if (_locationSubscription == null) {
      await _location.changeSettings(interval: 30000, distanceFilter: 30);
      _location.onLocationChanged.listen((onChanged));
    }
  }

  void dispose() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }
}
