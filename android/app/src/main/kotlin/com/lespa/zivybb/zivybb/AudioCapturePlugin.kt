package com.lespa.zivybb.zivybb

import android.media.audiofx.Visualizer
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.math.hypot
import kotlin.math.log10
import kotlin.math.min
import kotlin.math.pow

/**
 * Streams live frequency magnitudes from the app's own audio session so the
 * visualizer reacts to the actual music rather than a simulation.
 *
 * Uses [Visualizer], which is bound to one audio session id. The active
 * session changes whenever playback switches players (notably on every
 * crossfade), so Dart calls `start` again with the new id and this releases
 * and re-attaches.
 */
class AudioCapturePlugin(messenger: BinaryMessenger) {

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var visualizer: Visualizer? = null
    private var eventSink: EventChannel.EventSink? = null
    private var activeSessionId: Int? = null

    init {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val sessionId = call.argument<Int>("sessionId")
                    if (sessionId == null) {
                        result.error("no_session", "sessionId is required", null)
                    } else {
                        result.success(start(sessionId))
                    }
                }
                "stop" -> {
                    stop()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        eventChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            },
        )
    }

    /** Returns true if capture is running on [sessionId]. */
    private fun start(sessionId: Int): Boolean {
        if (activeSessionId == sessionId && visualizer != null) return true
        stop()

        // Session 0 would mean the global output mix, which ordinary apps
        // may not capture; only the app's own session is permitted.
        if (sessionId == 0) return false

        return try {
            val capture = Visualizer(sessionId).apply {
                // The smallest capture size keeps the FFT cheap; the
                // visualizer only needs a coarse spectrum, not fidelity.
                captureSize = Visualizer.getCaptureSizeRange()[0]
                setDataCaptureListener(
                    object : Visualizer.OnDataCaptureListener {
                        override fun onWaveFormDataCapture(
                            visualizer: Visualizer?,
                            waveform: ByteArray?,
                            samplingRate: Int,
                        ) = Unit

                        override fun onFftDataCapture(
                            visualizer: Visualizer?,
                            fft: ByteArray?,
                            samplingRate: Int,
                        ) {
                            fft?.let { emit(toBands(it)) }
                        }
                    },
                    // Half the maximum rate is smooth enough to read at 60fps
                    // without waking Dart more often than it can paint.
                    Visualizer.getMaxCaptureRate() / 2,
                    false,
                    true,
                )
                enabled = true
            }
            visualizer = capture
            activeSessionId = sessionId
            true
        } catch (error: RuntimeException) {
            // Thrown when the device refuses the capture — most often
            // because RECORD_AUDIO wasn't granted, but also on devices that
            // simply don't offer the effect. Either way the caller falls
            // back to the simulated waveform.
            visualizer = null
            activeSessionId = null
            false
        }
    }

    fun stop() {
        visualizer?.let {
            try {
                it.enabled = false
                it.release()
            } catch (_: RuntimeException) {
                // Already released or in a bad state; nothing to salvage.
            }
        }
        visualizer = null
        activeSessionId = null
    }

    fun dispose() {
        stop()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    private fun emit(bands: List<Double>) {
        // The capture callback runs off the main thread; platform channels
        // must be used on it.
        mainHandler.post { eventSink?.success(bands) }
    }

    /**
     * Folds the raw FFT into [BAND_COUNT] normalized (0..1) magnitudes.
     *
     * The byte array holds interleaved real/imaginary pairs. Bands are
     * spaced logarithmically because pitch is perceived that way — linear
     * spacing crowds all the musical content into the first few bars.
     */
    private fun toBands(fft: ByteArray): List<Double> {
        val binCount = fft.size / 2
        if (binCount <= 1) return List(BAND_COUNT) { 0.0 }

        val bands = ArrayList<Double>(BAND_COUNT)
        for (band in 0 until BAND_COUNT) {
            val start = logBin(band, binCount)
            val end = max(logBin(band + 1, binCount), start + 1)

            var peak = 0.0
            for (bin in start until min(end, binCount)) {
                val real = fft[bin * 2].toInt()
                val imaginary = fft[bin * 2 + 1].toInt()
                val magnitude = hypot(real.toDouble(), imaginary.toDouble())
                if (magnitude > peak) peak = magnitude
            }

            // Decibel-ish scaling, so quiet detail stays visible instead of
            // every bar sitting near zero until a loud passage.
            val scaled = if (peak > 0) (log10(peak) / LOG_MAX_MAGNITUDE) else 0.0
            bands.add(scaled.coerceIn(0.0, 1.0))
        }
        return bands
    }

    private fun logBin(band: Int, binCount: Int): Int {
        val fraction = band.toDouble() / BAND_COUNT
        return (binCount.toDouble().pow(fraction)).toInt().coerceIn(0, binCount)
    }

    private fun max(a: Int, b: Int) = if (a > b) a else b

    private companion object {
        const val METHOD_CHANNEL = "com.lespa.zivybb/audio_capture"
        const val EVENT_CHANNEL = "com.lespa.zivybb/audio_capture_events"

        /** Must match the visualizer's bar count on the Dart side. */
        const val BAND_COUNT = 24

        /** log10 of the largest magnitude a signed-byte FFT pair can reach. */
        val LOG_MAX_MAGNITUDE = log10(hypot(128.0, 128.0))
    }
}
