package com.lespa.zivybb.zivybb

import android.content.Context
import android.media.AudioManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// Reads and sets the device's media volume, so the Now Playing screen's
// vertical swipe moves the same volume the hardware keys do.
//
// Deliberately not the player's own volume: just_audio's setVolume is what
// the crossfade ramps drive, and a user-facing control sharing that would
// fight the fade. STREAM_MUSIC is a separate, system-owned level.
class SystemVolumeBridge(
    context: Context,
    messenger: BinaryMessenger,
) {

    private val audioManager =
        context.applicationContext.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    private val channel = MethodChannel(messenger, CHANNEL).apply {
        setMethodCallHandler { call, result ->
            when (call.method) {
                "getVolume" -> result.success(currentVolume())
                "setVolume" -> {
                    val level = call.argument<Double>("level")
                    if (level == null) {
                        result.error("bad_args", "level is required", null)
                    } else {
                        result.success(setVolume(level))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    /** The media volume as 0..1. */
    private fun currentVolume(): Double {
        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        if (max <= 0) return 0.0
        return audioManager.getStreamVolume(AudioManager.STREAM_MUSIC).toDouble() / max
    }

    /**
     * Sets the media volume from a 0..1 [level] and returns where it actually
     * landed. The system works in whole steps — typically 15 of them — so the
     * caller has to be told the rounded value or its overlay drifts away from
     * the real level.
     */
    private fun setVolume(level: Double): Double {
        val max = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        if (max <= 0) return 0.0
        val step = Math.round(level.coerceIn(0.0, 1.0) * max).toInt()
        // No flags: the screen draws its own indicator, and the system panel
        // sliding in over the artwork on every swipe would be noise.
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, step, 0)
        return step.toDouble() / max
    }

    private companion object {
        const val CHANNEL = "com.lespa.zivybb/system_volume"
    }
}
