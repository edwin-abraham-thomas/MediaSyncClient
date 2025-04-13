package com.example.media_sync_client

import android.content.Context
import android.media.AudioManager
import android.os.SystemClock
import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CONTROL_CHANNEL = "media/control"
    private val INFO_CHANNEL = "media/info"

    private lateinit var audioManager: AudioManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CONTROL_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    controlMedia(KeyEvent.KEYCODE_MEDIA_PLAY)
                    result.success("Played")
                }

                "pause" -> {
                    controlMedia(KeyEvent.KEYCODE_MEDIA_PAUSE)
                    result.success("Paused")
                }

                "next" -> {
                    controlMedia(KeyEvent.KEYCODE_MEDIA_NEXT)
                    result.success("Skipped to next")
                }

                "previous" -> {
                    controlMedia(KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                    result.success("Skipped to previous")
                }

                "stop" -> {
                    controlMedia(KeyEvent.KEYCODE_MEDIA_STOP)
                    result.success("Stopped")
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            INFO_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getCurrentMedia") {
                val mediaInfo = getMediaInfo()
                result.success(mediaInfo)
            } else {
                result.notImplemented()
            }
        }

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    private fun controlMedia(keyCode: Int) {

        try {
            val eventTime = SystemClock.uptimeMillis()

            // Send key down event
            val eventDown = KeyEvent(eventTime, eventTime, KeyEvent.ACTION_DOWN, keyCode, 0)
            audioManager.dispatchMediaKeyEvent(eventDown)

            // Send key up event
            val eventUp = KeyEvent(eventTime, eventTime, KeyEvent.ACTION_UP, keyCode, 0)
            audioManager.dispatchMediaKeyEvent(eventUp)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }


    private fun getMediaInfo(): Map<String, Any?> {
        return mapOf(
            "title" to "Unknown",
            "artist" to "Unknown",
            "album" to "Unknown",
            "isPlaying" to audioManager.isMusicActive()
        )
    }
}
