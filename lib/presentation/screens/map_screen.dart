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

  // 위치 권한 요청 및 현재 위치 얻기
  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있음');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한 거부됨');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('위치 권한 영구 거부됨');
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  // Flutter 위치 받아서 JS 호출해 지도 중심 이동
  void _moveMapToCurrentLocation(Position position) {
    final lat = position.latitude;
    final lng = position.longitude;
    final js = 'moveToLocation($lat, $lng);';
    webViewController?.evaluateJavascript(source: js);
  }

  @override
  void initState() {
    super.initState();

    // WebView 생성 후 위치 권한 받고 위치 요청, JS 호출 실행
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Position? pos = await _determinePosition();
      if (pos != null) {
        _moveMapToCurrentLocation(pos);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://dooit-bf5a9.web.app/")
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnLoadResource: true,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStop: (controller, url) async {
          Position? pos = await _determinePosition();
          if (pos != null) {
            _moveMapToCurrentLocation(pos);
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          print('Console: ${consoleMessage.message}');
        },
        onLoadError: (controller, url, code, message) {
          print('WebView load error: $message');
        },
        onLoadHttpError: (controller, url, statusCode, description) {
          print('WebView HTTP error: $statusCode - $description');
        },
      ),
    );
  }
  }
