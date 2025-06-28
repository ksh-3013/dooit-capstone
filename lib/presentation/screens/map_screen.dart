// 전체 코드 (Flutter + Web JS)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  InAppWebViewController? webViewController;
  bool isGymNearby = false;

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  void _moveMapToCurrentLocation(Position position) {
    final lat = position.latitude;
    final lng = position.longitude;
    final js = 'moveToLocation($lat, $lng);';
    webViewController?.evaluateJavascript(source: js);
  }

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position pos) {
      final js = 'moveToLocationWithHeading(${pos.latitude}, ${pos.longitude}, ${pos.heading});';
      webViewController?.evaluateJavascript(source: js);
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isGymNearby
          ? FloatingActionButton(
        onPressed: () => print('체크인 실행'),
        child: Icon(Icons.check),
      )
          : null,
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://dooit-bf5a9.web.app")
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;

          controller.addJavaScriptHandler(
            handlerName: 'gymInRange',
            callback: (args) {
              bool nearby = args.first == true;
              setState(() {
                isGymNearby = nearby;
              });
            },
          );
        },
        onLoadStop: (controller, url) async {
          Position? pos = await _determinePosition();
          if (pos != null) {
            _moveMapToCurrentLocation(pos);
          }
        },
      ),
    );
  }
}
