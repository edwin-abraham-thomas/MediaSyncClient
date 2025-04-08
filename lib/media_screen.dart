import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'media_controller.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaController = Provider.of<MediaController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Local Media Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Now Playing: ${mediaController.currentMedia}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 40),
                  onPressed: mediaController.previousTrack,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    mediaController.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                  onPressed: () {
                    if (mediaController.isPlaying) {
                      mediaController.pause();
                    } else {
                      mediaController.play();
                    }
                  },
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 40),
                  onPressed: mediaController.nextTrack,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.stop, size: 40),
                  onPressed: mediaController.stop,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              mediaController.isPlaying ? 'Playing' : 'Paused',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
