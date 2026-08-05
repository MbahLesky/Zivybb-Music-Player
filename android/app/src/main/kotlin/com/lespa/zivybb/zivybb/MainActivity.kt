package com.lespa.zivybb.zivybb

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

// Extends audio_service's base activity (instead of plain FlutterActivity) so
// this activity shares the same FlutterEngine as the background audio
// service — required for the lock-screen/notification controls to work.
class MainActivity : AudioServiceActivity() {
    private var visualizerBridge: AudioVisualizerBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        visualizerBridge =
            AudioVisualizerBridge(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        // Releases the system Visualizer effect. Leaking it would keep the
        // audio session captured for the life of the process.
        visualizerBridge?.dispose()
        visualizerBridge = null
        super.onDestroy()
    }
}
