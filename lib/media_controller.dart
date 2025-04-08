import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MediaController with ChangeNotifier {
  static const platform = MethodChannel('media/control');

  String currentMedia = "Sample Song"; // Mock media for POC
  bool isPlaying = false;

  Future<void> play() async {
    try {
      String result = await platform.invokeMethod('play');
      isPlaying = true;
      print("Play result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to play: '${e.message}'.");
    }
  }

  Future<void> pause() async {
    try {
      String result = await platform.invokeMethod('pause');
      isPlaying = false;
      print("Pause result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to pause: '${e.message}'.");
    }
  }

  Future<void> nextTrack() async {
    try {
      String result = await platform.invokeMethod('next');
      print("Next track result: $result");
      // Update UI or state if needed
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to skip to next track: '${e.message}'.");
    }
  }

  Future<void> previousTrack() async {
    try {
      String result = await platform.invokeMethod('previous');
      print("Previous track result: $result");
      // Update UI or state if needed
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to go to previous track: '${e.message}'.");
    }
  }

  Future<void> stop() async {
    try {
      String result = await platform.invokeMethod('stop');
      isPlaying = false;
      print("Stop result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to stop: '${e.message}'.");
    }
  }

  // Simulate fetching current media state (for POC)
  void fetchMediaState() {
    // In a real app, this would query the native platform
    notifyListeners();
  }
}
