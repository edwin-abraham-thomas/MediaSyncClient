import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MediaController with ChangeNotifier {
  static const platform = MethodChannel('com.example.media_control/media');

  String currentMedia = "Sample Song"; // Mock media for POC
  bool isPlaying = false;

  Future<void> play() async {
    try {
      await platform.invokeMethod('play');
      isPlaying = true;
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to play: '${e.message}'.");
    }
  }

  Future<void> pause() async {
    try {
      await platform.invokeMethod('pause');
      isPlaying = false;
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to pause: '${e.message}'.");
    }
  }

  // Simulate fetching current media state (for POC)
  void fetchMediaState() {
    // In a real app, this would query the native platform
    notifyListeners();
  }
}
