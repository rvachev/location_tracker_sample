import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker/features/location/services/location_service.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(54.985605, 73.3487785), zoom: 15);
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Polyline> userWay = {};
  LatLng? lastUserLocation;

  String result = 'unknown';
  String buttonText = 'Stop tracking';
  late final LocationService _locationService = LocationService();
  List<String> lastCoords = [];

  @override
  void initState() {
    _locationService.init();
    findUserOnMap();
    setLocationListener();
    super.initState();
  }

  void setLocationListener() {
    _locationService.subscribeOnUpdates((locationData) {
      setState(() {
        result =
            '${locationData.latitude}, ${locationData.longitude} - ${DateTime.now()}';
        if (lastUserLocation != null) {
          LatLng newLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          userWay.add(Polyline(
              polylineId: PolylineId(result),
              width: 3,
              color: Colors.blue,
              points: _createPolylinePoints(lastUserLocation!, newLocation)));
        }
      });
    });
  }

  void findUserOnMap() async {
    LocationData? locationData = await _locationService.getCurrentLocation();
    GoogleMapController controller = await _mapController.future;
    lastUserLocation = LatLng(locationData!.latitude!, locationData.longitude!);
    controller.animateCamera(CameraUpdate.newLatLng(lastUserLocation!));

    setState(() {
      result = '${lastUserLocation!.latitude}, ${lastUserLocation!.longitude}';
    });
  }

  List<LatLng> _createPolylinePoints(LatLng lastLocation, LatLng newLocation) {
    List<LatLng> polylinePoints = [];
    polylinePoints.add(lastLocation);
    polylinePoints.add(newLocation);

    setState(() {
      lastUserLocation = newLocation;
    });

    return polylinePoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
                flex: 9,
                child: GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (mapController) {
                    _mapController.complete(mapController);
                  },
                  polylines: userWay,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                )),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  result,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
