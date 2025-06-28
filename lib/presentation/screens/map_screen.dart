import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  InAppWebViewController? webViewController;
  StreamSubscription<Position>? positionStream;

  bool isGymSelected = false;
  DateTime? checkinStartTime;
  Timer? _timer;
  Duration? elapsed;

  bool isCheckedIn = false;
  Map<String, dynamic>? checkoutResult;

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

  void startCheckinTimer(DateTime start) {
    checkinStartTime = start;
    isCheckedIn = true;
    elapsed = Duration.zero;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = now.difference(checkinStartTime!);
      setState(() {
        elapsed = diff;
      });
    });
  }

  void _moveMapToCurrentLocation(Position position) {
    final lat = position.latitude;
    final lng = position.longitude;
    final js = 'moveToLocation($lat, $lng);';
    webViewController?.evaluateJavascript(source: js);
  }

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
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (elapsed == null) return;
    final minutes = elapsed!.inMinutes;

    try {
      final res = await http.post(
        Uri.parse('https://your.api.server/api/exer/checkout'), // URL 수정 필수
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"min": minutes}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          isCheckedIn = false;
          checkoutResult = data;
          elapsed = null;
        });
      } else {
        print("체크아웃 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isGymSelected
          ? FloatingActionButton(
        onPressed: () {
          webViewController?.evaluateJavascript(source: 'markAsCheckedIn();');
        },
        child: Icon(Icons.check),
      )
          : isCheckedIn
          ? FloatingActionButton.extended(
        onPressed: _checkout,
        label: Text("체크아웃"),
        icon: Icon(Icons.logout),
      )
          : null,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
                url: WebUri("https://dooit-bf5a9.web.app?version=${DateTime.now().millisecondsSinceEpoch}")
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;

              controller.addJavaScriptHandler(
                handlerName: 'gymSelected',
                callback: (args) {
                  bool selected = args.first == true;
                  setState(() {
                    isGymSelected = selected;
                  });
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'checkinTime',
                callback: (args) {
                  final String timeStr = args.first;
                  final DateTime time = DateTime.parse(timeStr);
                  startCheckinTimer(time);
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

          // 체크인 경과 시간 표시
          if (elapsed != null)
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${elapsed!.inMinutes}분 ${elapsed!.inSeconds % 60}초',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

          // 체크아웃 결과 표시
          if (checkoutResult != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("운동 기록 완료", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("추가 시간: ${checkoutResult!['min']}분", style: TextStyle(color: Colors.white)),
                    Text("오늘 누적: ${checkoutResult!['todayTotalTime']}분", style: TextStyle(color: Colors.white)),
                    Text("총 운동: ${checkoutResult!['totalTime']}분", style: TextStyle(color: Colors.white)),
                    Text("획득 포인트: ${checkoutResult!['point']}", style: TextStyle(color: Colors.white)),
                    Text("총 포인트: ${checkoutResult!['totalPoint']}", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
