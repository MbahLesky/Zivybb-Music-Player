package com.lespa.zivybb.zivybb

import android.content.ContentUris
import android.content.Intent
import android.os.Build
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Extends audio_service's base activity (instead of plain FlutterActivity) so
// this activity shares the same FlutterEngine as the background audio
// service — required for the lock-screen/notification controls to work.
class MainActivity : AudioServiceActivity() {

    private var visualizerBridge: AudioVisualizerBridge? = null
    private var mediaDeleteBridge: MediaDeleteBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        visualizerBridge =
            AudioVisualizerBridge(flutterEngine.dartExecutor.binaryMessenger)

        // Deleting a media file needs an Activity from Android 10 on — the
        // user confirms it in a system dialog that answers via
        // onActivityResult — so this bridge is built here rather than being
        // a standalone plugin.
        mediaDeleteBridge =
            MediaDeleteBridge(this, flutterEngine.dartExecutor.binaryMessenger)

        // The bundled media-query plugin only reads MediaStore.Audio, so
        // videos-played-as-music (SRS: video audio playback) need their own
        // query. A small channel keeps this dependency-free.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VIDEO_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "queryVideos" -> result.success(queryVideos())
                    else -> result.notImplemented()
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        // Answers the Flutter side's pending delete first; anything the
        // bridge doesn't recognise belongs to a plugin further down.
        if (mediaDeleteBridge?.onActivityResult(requestCode, resultCode) == true) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        // Releases the system Visualizer effect. Leaking it would keep the
        // audio session captured for the life of the process.
        visualizerBridge?.dispose()
        visualizerBridge = null
        mediaDeleteBridge?.dispose()
        mediaDeleteBridge = null
        super.onDestroy()
    }

    private fun queryVideos(): List<Map<String, Any?>> {
        val columns = mutableListOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.TITLE,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Video.Media.DATE_ADDED,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            columns.add(MediaStore.Video.Media.ARTIST)
        }

        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            @Suppress("DEPRECATION")
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        }

        val videos = mutableListOf<Map<String, Any?>>()
        contentResolver.query(
            collection,
            columns.toTypedArray(),
            null,
            null,
            "${MediaStore.Video.Media.TITLE} COLLATE NOCASE ASC",
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.TITLE)
            val durationColumn =
                cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
            val bucketColumn =
                cursor.getColumnIndex(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)
            val dateAddedColumn =
                cursor.getColumnIndex(MediaStore.Video.Media.DATE_ADDED)
            val artistColumn = cursor.getColumnIndex("artist")

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                // DATA is deprecated but still populated, and the rest of the
                // app addresses tracks by file path (missing-file detection,
                // folder grouping, backup matching). Fall back to the
                // content:// URI on the rare device that leaves it null.
                val path = cursor.getString(dataColumn)
                    ?: ContentUris.withAppendedId(collection, id).toString()
                videos.add(
                    mapOf(
                        "id" to id.toString(),
                        "filePath" to path,
                        "title" to (cursor.getString(titleColumn) ?: "Unknown"),
                        "durationMs" to cursor.getLong(durationColumn),
                        "album" to if (bucketColumn >= 0) {
                            cursor.getString(bucketColumn)
                        } else {
                            null
                        },
                        "artist" to if (artistColumn >= 0) {
                            cursor.getString(artistColumn)
                        } else {
                            null
                        },
                        // Seconds since the epoch, per MediaStore; Dart
                        // normalizes the devices that report milliseconds.
                        "dateAdded" to if (dateAddedColumn >= 0) {
                            cursor.getLong(dateAddedColumn)
                        } else {
                            null
                        },
                    ),
                )
            }
        }
        return videos
    }

    private companion object {
        const val VIDEO_CHANNEL = "com.lespa.zivybb/video_query"
    }
}
