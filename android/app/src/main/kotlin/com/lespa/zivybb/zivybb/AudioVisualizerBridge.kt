package com.lespa.zivybb.zivybb

import android.media.audiofx.Visualizer
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.hypot
import kotlin.math.ln
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * Streams real frequency-band levels to Dart, so the wave visualizer can
 * react to the audio actually playing rather than to a simulated waveform.
 *
 * Wraps [android.media.audiofx.Visualizer], attached to the audio session
 * `just_audio` reports via `androidAudioSessionId`. That API is what requires
 * the RECORD_AUDIO permission — it can observe the output mix — which is why
 * the whole feature is opt-in and the Dart side only starts this after the
 * user has enabled it and granted the permission.
 *
 * The FFT is folded down to [BAND_COUNT] logarithmically-spaced bands here
 * rather than in Dart: it keeps ~20 messages a second down to a small array
 * instead of a few hundred floats, and log spacing matches how pitch is
 * perceived, so the low end doesn't collapse into a single bar.
 */
class AudioVisualizerBridge(messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val METHOD_CHANNEL = "com.lespa.zivybb/visualizer"
        private const val EVENT_CHANNEL = "com.lespa.zivybb/visualizer_events"

        /** Number of bands handed to Dart. Matches the visualizer's bar count. */
        private const val BAND_COUNT = 32

        /**
         * Ignore the lowest bins: bin 0 is DC and the first couple carry
         * rumble and encoder noise that would otherwise peg the first bar.
         */
        private const val FIRST_BIN = 2
    }

    private val methodChannel = MethodChannel(messenger, METHOD_CHANNEL)
    private val eventChannel = EventChannel(messenger, EVENT_CHANNEL)

    private var visualizer: Visualizer? = null
    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    fun dispose() {
        stopCapture()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val sessionId = call.argument<Int>("sessionId")
                if (sessionId == null) {
                    result.error("no_session", "sessionId is required", null)
                    return
                }
                try {
                    startCapture(sessionId)
                    result.success(true)
                } catch (error: Throwable) {
                    // Creating a Visualizer fails on plenty of real devices —
                    // permission revoked, the effect being unavailable, or
                    // another app already holding the session. None of those
                    // should break playback, so report it and let Dart fall
                    // back to the simulated waveform.
                    stopCapture()
                    result.error("unavailable", error.message, null)
                }
            }
            "stop" -> {
                stopCapture()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun startCapture(sessionId: Int) {
        stopCapture()

        val created = Visualizer(sessionId).apply {
            // Largest capture the device allows: more FFT bins means the log
            // banding below has something to work with at the low end.
            captureSize = Visualizer.getCaptureSizeRange()[1]
        }
        visualizer = created

        created.setDataCaptureListener(
            object : Visualizer.OnDataCaptureListener {
                override fun onWaveFormDataCapture(
                    v: Visualizer?,
                    waveform: ByteArray?,
                    samplingRate: Int,
                ) = Unit

                override fun onFftDataCapture(
                    v: Visualizer?,
                    fft: ByteArray?,
                    samplingRate: Int,
                ) {
                    if (fft != null) emitBands(fft)
                }
            },
            // Fastest the device will give us. Dart smooths and interpolates
            // between frames, so a ~20Hz feed still animates at 60fps.
            Visualizer.getMaxCaptureRate(),
            /* waveform = */ false,
            /* fft = */ true,
        )
        created.enabled = true
    }

    private fun stopCapture() {
        visualizer?.let { existing ->
            try {
                existing.enabled = false
                existing.release()
            } catch (_: Throwable) {
                // Already released or in a bad state; nothing useful to do.
            }
        }
        visualizer = null
    }

    /**
     * Folds the raw FFT into [BAND_COUNT] log-spaced magnitudes in 0..1.
     *
     * The byte array is interleaved real/imaginary pairs, except for the two
     * ends: `fft[0]` is the DC real part and `fft[1]` the Nyquist real part,
     * neither of which has an imaginary partner.
     */
    private fun emitBands(fft: ByteArray) {
        val sink = eventSink ?: return
        val binCount = fft.size / 2
        if (binCount <= FIRST_BIN) return

        val bands = DoubleArray(BAND_COUNT)
        val usableBins = binCount - FIRST_BIN

        for (band in 0 until BAND_COUNT) {
            // Log-spaced edges so bass occupies as many bands as treble.
            val start = logBin(band, usableBins) + FIRST_BIN
            val end = logBin(band + 1, usableBins) + FIRST_BIN
            val last = max(start + 1, min(end, binCount))

            var peak = 0.0
            for (bin in start until last) {
                val real = fft[bin * 2].toInt()
                val imaginary = fft[bin * 2 + 1].toInt()
                peak = max(peak, hypot(real.toDouble(), imaginary.toDouble()))
            }

            // Magnitudes are roughly 0..128 per component but heavily
            // bottom-weighted, so a decibel-ish curve is what makes the
            // result look like the music instead of a flat line with spikes.
            val normalized = if (peak <= 0.0) {
                0.0
            } else {
                (ln(peak) / ln(128.0)).coerceIn(0.0, 1.0)
            }
            bands[band] = normalized
        }

        sink.success(bands.toList())
    }

    /** Bin index for the [band]th log-spaced edge across [usableBins]. */
    private fun logBin(band: Int, usableBins: Int): Int {
        val fraction = band.toDouble() / BAND_COUNT
        // usableBins^fraction spreads edges geometrically from 1 to usableBins.
        return (usableBins.toDouble().pow(fraction) - 1.0)
            .coerceIn(0.0, (usableBins - 1).toDouble())
            .toInt()
    }
}
