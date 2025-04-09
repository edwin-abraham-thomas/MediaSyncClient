import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MediaController with ChangeNotifier {
  static const controlChannel = MethodChannel('media/control');
  static const infoChannel = MethodChannel('media/info');

  String currentMedia = "Unknown"; // Will be updated with real media info
  String currentArtist = "Unknown";
  String currentAlbum = "Unknown";
  bool isPlaying = false;

  MediaController() {
    // Initialize by fetching media info
    fetchMediaState();

    // Set up periodic refresh (every 2 seconds)
    Timer.periodic(Duration(seconds: 2), (timer) {
      fetchMediaState();
    });
  }

  Future<void> play() async {
    try {
      String result = await controlChannel.invokeMethod('play');
      isPlaying = true;
      print("Play result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to play: '${e.message}'.");
    }
  }

  Future<void> pause() async {
    try {
      String result = await controlChannel.invokeMethod('pause');
      isPlaying = false;
      print("Pause result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to pause: '${e.message}'.");
    }
  }

  Future<void> nextTrack() async {
    try {
      String result = await controlChannel.invokeMethod('next');
      print("Next track result: $result");
      // Update UI or state if needed
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to skip to next track: '${e.message}'.");
    }
  }

  Future<void> previousTrack() async {
    try {
      String result = await controlChannel.invokeMethod('previous');
      print("Previous track result: $result");
      // Update UI or state if needed
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to go to previous track: '${e.message}'.");
    }
  }

  Future<void> stop() async {
    try {
      String result = await controlChannel.invokeMethod('stop');
      isPlaying = false;
      print("Stop result: $result");
      notifyListeners();
    } on PlatformException catch (e) {
      print("Failed to stop: '${e.message}'.");
    }
  }

  // Simulate fetching current media state (for POC)
  Future<void> fetchMediaState() async {
    try {
      final Map<dynamic, dynamic> result = await infoChannel.invokeMethod(
        'getCurrentMedia',
      );

      // Update properties
      currentMedia = result['title'] ?? 'Unknown';
      currentArtist = result['artist'] ?? 'Unknown';
      currentAlbum = result['album'] ?? 'Unknown';
      isPlaying = result['isPlaying'] ?? false;

      // Notify listeners to update UI
      notifyListeners();

      return;
    } on PlatformException catch (e) {
      print("Failed to get media info: '${e.message}'.");
      return;
    }
  }
}
