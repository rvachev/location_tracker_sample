import 'package:flutter/material.dart';
import 'package:location_tracker/features/location/services/location_service.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String result = 'unknown';
  String buttonText = 'Stop tracking';
  late final LocationService _locationService = LocationService();
  List<String> lastCoords = [];

  @override
  void initState() {
    _locationService.init();
    setLocationListener();
    super.initState();
  }

  void setLocationListener() {
    _locationService.subscribeOnUpdates((locationData) => {
          setState(() {
            result = '${locationData.latitude}, ${locationData.longitude}';
            lastCoords.add(result);
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                result,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 500,
              child: ListView.builder(
                  itemCount: lastCoords.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(lastCoords[index]),
                    );
                  }),
            )
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
