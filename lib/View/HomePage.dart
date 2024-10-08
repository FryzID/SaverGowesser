import 'dart:async';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myapp/notification_service.dart';
import 'package:rxdart/subjects.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constant.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  static const _actionTitles = ['Create Post', 'Upload Photo', 'Upload Video'];
  HomePage({super.key});

  void notif() async {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService.init();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

final database = FirebaseDatabase.instance.ref();

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  late GoogleMapController mapController;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  LatLng? location;
  LatLng? destinasi;
  bool _showMarker = false;
  bool _showLocation = false;
  final LatLng _center = const LatLng(-33.86, 151.20);
  Set<Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  Position? _startPosition;
  double _totalDistance = 0.0;
  StreamSubscription<Position>? _positionStream;

  double _speedInKmph = 0.0;
  Timer? _timer;

  double bpmsmt = 0;

  LatLng? currentPosition;

  final locationController = Location();

  String getBPM = '0';

  List<LatLng> poltlineCoordinates = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleMarker() {
    setState(() {
      _showMarker = !_showMarker;
    });
  }

  void _toggleLocation() {
    setState(() {
      _showLocation = !_showLocation;
      _updatePolylines();
    });
  }

  // void _onLongPress(LatLng position) {
  //   setState(() {
  //     destinasi = position;
  //     _updatePolylines();
  //   });
  // }

  Future<void> _updatePolylines() async {
    _polylines.clear();
    if (destinasi != null) {
      List<LatLng> polylineCoordinates = [];
      if (_showLocation && location != null) {
        polylineCoordinates = await _getPolylinePoints(location!, destinasi!);
        _polylines.add(Polyline(
          polylineId: PolylineId('polyline_location_destinasi'),
          points: polylineCoordinates,
          color: Colors.blue,
        ));
      } else {
        polylineCoordinates =
            await _getPolylinePoints(currentPosition!, destinasi!);
        _polylines.add(Polyline(
          polylineId: PolylineId('polyline_posisi_destinasi'),
          points: polylineCoordinates,
          color: Colors.red,
        ));
      }
      // Print the polyline coordinates
      for (var point in polylineCoordinates) {
        print('Lat: ${point.latitude}, Lng: ${point.longitude}');
      }
    }
  }

  // Future<void> initializePlatformNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('ic_stat_justwater');

  //   final InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //   );

  //   await _localNotifications.initialize(initializationSettings,
  //       onSelectNotification: selectNotification);
  // }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }

  Future<List<LatLng>> _getPolylinePoints(LatLng start, LatLng end) async {
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }

  @override
  void initState() {
    super.initState();
    // _startTracking();
    // _startTrackingKM();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLocationUpdates();
    });
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('bpm');

    final Speed = database.child('Speed/');

    ref.onValue.listen((event) {
      setState(() {
        if (event.snapshot.exists) {
          getBPM = event.snapshot.value.toString();
          int bpmValue = int.tryParse(getBPM) ?? 0;
          if (bpmValue >= 200) {
            // initializePlatformNotifications();
            NotificationService.showInstantNotification(
              'Detak Jantung Tinggi!',
              'Kurangi detak intensitas atau kecepatan bersepeda anda',
            );
          }
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
    _timer =
        Timer.periodic(Duration(seconds: 1), (Timer t) => _getWalkingSpeed());
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
          DateTime.now().difference(previousUpdateTime!) >=
              Duration(seconds: 1)) {
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
            database.update({'Distance': _totalDistance});
            _startPosition = position;
          });
        }
      }
    });
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLatitude)) *
            cos(_degreesToRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _getWalkingSpeed() async {
    database.update({'Speed': _speedInKmph, 'Distance': _totalDistance});
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
        int bpmValue = int.tryParse(getBPM) ?? 0;
        if (bpmValue >= 200) {
          // initializePlatformNotifications();
          NotificationService.showInstantNotification(
              'Detak Jantung Tinggi!',
              'Kurangi detak intensitas atau kecepatan bersepeda anda',
            );
        }
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
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: currentPosition!,
                          zoom: 13.0,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId('posisi'),
                            icon: BitmapDescriptor.defaultMarker,
                            position: currentPosition!,
                            visible: !_showLocation,
                          ),
                          if (_showLocation && location != null)
                            Marker(
                              markerId: MarkerId('location'),
                              icon: BitmapDescriptor.defaultMarker,
                              position: location!,
                            ),
                          if (destinasi != null)
                            Marker(
                              markerId: MarkerId('destinasi'),
                              icon: BitmapDescriptor.defaultMarker,
                              position: destinasi!,
                            ),
                        },
                        polylines: _polylines,
                        // onLongPress: _onLongPress,
                      ),
                      // Positioned(
                      //   bottom: 50,
                      //   left: 10,
                      //   child: ElevatedButton(
                      //     onPressed: _toggleLocation,
                      //     child: Text(_showLocation
                      //         ? 'Hide Location'
                      //         : 'Show Location'),
                      //   ),
                      // ),
                      // Positioned(
                      //   bottom: 50,
                      //   left: 10,
                      //   child: ElevatedButton(
                      //     onPressed: _toggleLocation,
                      //     child: Text(_showLocation
                      //         ? 'Hide Location'
                      //         : 'Show Location'),
                      //   ),
                      // ),
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
                                  "${_speedInKmph.toStringAsFixed(2)}\n"
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
                                  "${_totalDistance.toStringAsFixed(2)}\n"
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
                            SizedBox(
                              width: 120, // Set the desired width
                              height: 100, // Set the desired height
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, top: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'BPM',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Divider(),
                                      Text(
                                        '$getBPM',
                                        style: TextStyle(
                                            // fontSize: 16,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Card(
                            //   child: Padding(
                            //     padding: EdgeInsets.only(
                            //         left: 25, right: 25, top: 10, bottom: 10),
                            //     child: Text("$getBPM"),
                            //   ),
                            // ),
                            SizedBox(
                              width: 120, // Set the desired width
                              height: 100, // Set the desired height
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 5, top: 10, bottom: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Max BPM',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Divider(),
                                      Text(
                                        '200',
                                        style: TextStyle(
                                            // fontSize: 16,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
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
  final homePage =
      _HomePageState(); // Assuming this is needed for communication

  void _toggleButton() {
    final appOn = database.child('App_on/');
    setState(() {
      isTrue = !isTrue;
    });

    if (isTrue) {
      // Do something when true
      appOn.set(true);
      print('Button is true');
      homePage._startTracking();
      homePage._startTrackingKM();
    } else {
      // Do something when false
      appOn.set(false);
      homePage.dispose();
      homePage.disposeKM();
      print('Button is false');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggleButton,
      splashColor: Colors.blue.withAlpha(30),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 75.0,
        height: 75.0,
        decoration: BoxDecoration(
          color: isTrue ? Colors.red : Colors.green,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(
            isTrue ? FontAwesomeIcons.times : FontAwesomeIcons.play,
            color: Colors.white,
            size: 40,
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

