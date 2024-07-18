import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myapp/constant.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng location = LatLng(-7.290939, 112.800999);
  static const LatLng destinasi = LatLng(-7.289564, 112.781629);

  Position? _startPosition;
  double _totalDistance = 0.0;
  StreamSubscription<Position>? _positionStream;

  double _speedInKmph = 0.0;
  Timer? _timer;

  LatLng? currentPosition;

  final locationController = Location();

  String getBPM = '0';

  List<LatLng> poltlineCoordinates = [];

  void getPolyPoint() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(location.latitude, location.longitude),
      PointLatLng(destinasi.latitude, destinasi.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => poltlineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _startTracking();
    _startTrackingKM();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLocationUpdates();
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('BPM_TEST');

    ref.onValue.listen((event) {
      setState(() {
        if (event.snapshot.exists) {
          getBPM = event.snapshot.value.toString();
        } else {
          getBPM = 'No data available.';
        }
      });
    }, onError: (error) {
      setState(() {
        getBPM = 'Error: $error';
      });
    });
  }

  void _startTracking() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getWalkingSpeed());
  }

  void _startTrackingKM() {
  final LocationSettings locationSettings = LocationSettings(
    distanceFilter: 0,
  );

  DateTime? previousUpdateTime;

  _positionStream = Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((Position position) {
    if (previousUpdateTime == null ||
        DateTime.now().difference(previousUpdateTime!) >= Duration(seconds: 1)) {
      // Only process position updates with a minimum interval of 1 second
      previousUpdateTime = DateTime.now();
      if (_startPosition == null) {
        _startPosition = position;
      } else {
        double distance = calculateDistance(
          _startPosition!.latitude,
          _startPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          _totalDistance += distance;
          _startPosition = position;
        });
      }
    }
  });
}

double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);
    double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLatitude)) * cos(_degreesToRadians(endLatitude)) *
        sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }



  Future<void> _getWalkingSpeed() async {
    Position position = await Geolocator.getCurrentPosition();
    double speedInMps = position.speed;
    setState(() {
      _speedInKmph = speedInMps * 3.6;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  void disposeKM() {
    _positionStream?.cancel();
    super.dispose();
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('bpm');

    ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        getBPM = event.snapshot.value.toString();
      } else {
        print('No data available.');
      }
    }, onError: (error) {
      print('Error: $error');
    });
    return MaterialApp(
        home: Scaffold(
            floatingActionButtonLocation: ExpandableFab.location,
            floatingActionButton: ExpandableFab(
              key: widget.key,
              type: ExpandableFabType.up,
              childrenAnimation: ExpandableFabAnimation.none,
              distance: 70,
              overlayStyle: ExpandableFabOverlayStyle(
                color: Colors.white.withOpacity(0.9),
              ),
              children: [
                const Row(
                  children: [
                    Text('History'),
                    SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: null,
                      child: Icon(Icons.history),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Logout'),
                    const SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: signUserOut,
                      child: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: location,
                          zoom: 13,
                        ),
                        polylines: {
                          Polyline(
                            polylineId: PolylineId('route'),
                            color: Colors.red,
                            width: 5,
                            points: poltlineCoordinates,
                          ),
                        },
                        markers: {
                          Marker(
                            markerId: MarkerId('posisi'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: currentPosition!,
                          ),
                          const Marker(
                            markerId: MarkerId('location'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: location,
                          ),
                          const Marker(
                            markerId: MarkerId('destinasi'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: destinasi,
                          ),
                        },
                      ),
                      Positioned(
                        right: 10.0,
                        top: 40.0,
                        child: Stack(
                          // Use Stack to position text on top of GlassmorphicContainer
                          alignment: Alignment.center,
                          children: [
                            GlassmorphicContainer(
                              width: 80,
                              height: 45,
                              borderRadius: 10,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0x0fffffff).withAlpha(0),
                                  const Color(0x0fffffff).withAlpha(0),
                                ],
                                stops: const [
                                  0.3,
                                  1,
                                ],
                              ),
                              border: 2,
                              blur: 10,
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0x0fffffff).withAlpha(01),
                                  const Color(0x0fffffff).withAlpha(100),
                                  const Color(0x0fffffff).withAlpha(01),
                                ],
                                stops: const [
                                  0.2,
                                  0.9,
                                  1,
                                ],
                              ),
                            ),
                            Positioned(
                              child: Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "${_totalDistance.toStringAsFixed(2)}\n"
                                  "Km/H", // Add line breaks for each character
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 10.0,
                        top: 40.0,
                        child: Stack(
                          // Use Stack to position text on top of GlassmorphicContainer
                          alignment: Alignment.center,
                          children: [
                            GlassmorphicContainer(
                              width: 80,
                              height: 45,
                              borderRadius: 10,
                              linearGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0x0fffffff).withAlpha(0),
                                  const Color(0x0fffffff).withAlpha(0),
                                ],
                                stops: const [
                                  0.3,
                                  1,
                                ],
                              ),
                              border: 2,
                              blur: 10,
                              borderGradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0x0fffffff).withAlpha(01),
                                  const Color(0x0fffffff).withAlpha(100),
                                  const Color(0x0fffffff).withAlpha(01),
                                ],
                                stops: const [
                                  0.2,
                                  0.9,
                                  1,
                                ],
                              ),
                            ),
                            Positioned(
                              child: Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "$_speedInKmph\n"
                                  "Km", // Add line breaks for each character
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      // Background container (optional)
                      Container(
                        padding:
                            const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 25, right: 25, top: 16, bottom: 40),
                                child: Text("$getBPM"),
                              ),
                            ),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 25, right: 25, top: 16, bottom: 40),
                                child: Text('Card 2'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: CircleButton(),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )));
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnable;
    PermissionStatus permissionGranted;

    serviceEnable = await locationController.serviceEnabled();
    if (serviceEnable) {
      serviceEnable = await locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
        print(currentPosition!);
      }
    });
  }
}

class CircleButton extends StatefulWidget {
  const CircleButton({super.key});

  @override
  _CircleButtonState createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool isTrue = false;

  void _toggleButton() {
    setState(() {
      isTrue = !isTrue;
    });

    if (isTrue) {
      // Do something when true
      print('Button is true');
    } else {
      // Do something when false
      print('Button is false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleButton,
      child: Container(
        width: 75.0,
        height: 75.0,
        decoration: BoxDecoration(
          color: isTrue ? Colors.green : Colors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            isTrue ? 'True' : 'False',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}



// Widget _buildCircleButton() {
//   return GestureDetector(
//     onTap: () {
//       // Add your button functionality here (optional)
//     },
//     child: Container(
//       alignment: Alignment.center,
//       width: 75, // Adjust button size
//       height: 75, // Adjust button size
//       decoration: const BoxDecoration(
//         shape: BoxShape.circle, // Make the button circular
//         color: Colors.blue, // Set button color
//       ),
//     ),
//   );
// }

