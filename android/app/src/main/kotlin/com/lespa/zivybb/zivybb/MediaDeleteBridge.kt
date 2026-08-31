package com.lespa.zivybb.zivybb

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.ContentUris
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Deletes a song's file from the device on Dart's behalf.
 *
 * Three eras of Android need three different routes, which is the whole
 * reason this lives here rather than in `dart:io`:
 *
 *  - **API 30+ (Android 11+)**: apps cannot delete media they do not own at
 *    all. [MediaStore.createDeleteRequest] hands back an [android.app.PendingIntent]
 *    that shows the *system's* delete confirmation; the OS performs the
 *    delete only if the user agrees.
 *  - **API 29 (Android 10)**: a direct delete throws
 *    [RecoverableSecurityException] for files owned by another app, carrying
 *    an intent that asks the user for one-shot write access. Granting it
 *    lets a second delete attempt through.
 *  - **API 28 and below**: `WRITE_EXTERNAL_STORAGE` is enough to delete
 *    directly, and the file itself is removed as a fallback for the odd
 *    device whose media store row does not match the file on disk.
 *
 * Because two of those three routes are answered by the user in a system
 * dialog, the Flutter result is held until [onActivityResult] fires. Only one
 * delete can be in flight at a time; a second request while one is pending is
 * rejected rather than silently replacing the first, which would strand it.
 */
class MediaDeleteBridge(
    private val activity: Activity,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.lespa.zivybb/media_delete"

        /** Distinct enough not to collide with any plugin's own codes. */
        const val REQUEST_CODE = 0x5A11

        private const val DELETED = "deleted"
        private const val DENIED = "denied"
        private const val FAILED = "failed"
    }

    private val methodChannel = MethodChannel(messenger, CHANNEL)

    /** The Flutter result waiting on the system dialog, if any. */
    private var pendingResult: MethodChannel.Result? = null

    /** What that dialog is about, so API 29 can retry the delete after it. */
    private var pendingUri: Uri? = null
    private var pendingNeedsRetry = false

    init {
        methodChannel.setMethodCallHandler(this)
    }

    fun dispose() {
        // A pending dialog outlives nothing useful once the engine is going
        // away, but Flutter still expects every result to be answered.
        pendingResult?.success(FAILED)
        clearPending()
        methodChannel.setMethodCallHandler(null)
    }

    private fun clearPending() {
        pendingResult = null
        pendingUri = null
        pendingNeedsRetry = false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "deleteSong") {
            result.notImplemented()
            return
        }
        if (pendingResult != null) {
            result.error("busy", "A delete is already awaiting confirmation", null)
            return
        }

        val id = call.argument<String>("id")?.toLongOrNull()
        if (id == null) {
            result.error("bad_id", "A numeric media-store id is required", null)
            return
        }
        val isVideo = call.argument<Boolean>("isVideo") ?: false
        val filePath = call.argument<String>("filePath")

        try {
            deleteSong(id, isVideo, filePath, result)
        } catch (error: Throwable) {
            // Covers a failed startIntentSenderForResult, which throws after
            // the pending state has been staged — leaving it set would block
            // every later delete as "busy".
            clearPending()
            result.error("delete_failed", error.message, null)
        }
    }

    private fun deleteSong(
        id: Long,
        isVideo: Boolean,
        filePath: String?,
        result: MethodChannel.Result,
    ) {
        val uri = ContentUris.withAppendedId(collectionFor(isVideo), id)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // The system performs the delete itself once the user agrees, so
            // there is nothing left to retry afterwards.
            val request = MediaStore.createDeleteRequest(
                activity.contentResolver,
                listOf(uri),
            )
            pendingResult = result
            pendingUri = uri
            pendingNeedsRetry = false
            activity.startIntentSenderForResult(
                request.intentSender,
                REQUEST_CODE,
                null,
                0,
                0,
                0,
            )
            return
        }

        try {
            val rows = activity.contentResolver.delete(uri, null, null)
            result.success(if (rows > 0 || deleteFile(filePath)) DELETED else FAILED)
        } catch (security: SecurityException) {
            val recoverable = asRecoverable(security)
            if (recoverable == null) {
                result.success(FAILED)
                return
            }
            // Android 10 only: ask for write access, then delete for real in
            // onActivityResult.
            pendingResult = result
            pendingUri = uri
            pendingNeedsRetry = true
            activity.startIntentSenderForResult(
                recoverable.userAction.actionIntent.intentSender,
                REQUEST_CODE,
                null,
                0,
                0,
                0,
            )
        }
    }

    /**
     * Reports the outcome of the system dialog. Returns whether [requestCode]
     * was ours, so the activity can pass anything else along untouched.
     */
    fun onActivityResult(requestCode: Int, resultCode: Int): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val result = pendingResult ?: return true
        val uri = pendingUri
        val needsRetry = pendingNeedsRetry
        clearPending()

        if (resultCode != Activity.RESULT_OK) {
            // The user said no in Android's own dialog. Not a failure — the
            // library row has to stay exactly as it was.
            result.success(DENIED)
            return true
        }

        if (!needsRetry || uri == null) {
            result.success(DELETED)
            return true
        }

        result.success(
            try {
                val rows = activity.contentResolver.delete(uri, null, null)
                if (rows > 0) DELETED else FAILED
            } catch (_: SecurityException) {
                FAILED
            },
        )
        return true
    }

    private fun collectionFor(isVideo: Boolean): Uri {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (isVideo) {
                MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            }
        } else {
            @Suppress("DEPRECATION")
            if (isVideo) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }
        }
    }

    /**
     * Last resort below API 29, for the file whose media-store row is stale
     * or already gone: the user asked for the file to be deleted, and the
     * row disappearing on the next scan is exactly what they expect.
     */
    private fun deleteFile(filePath: String?): Boolean {
        if (filePath.isNullOrEmpty()) return false
        // Content URIs come through here on devices that left DATA null;
        // there is no file to unlink in that case.
        if (filePath.startsWith("content://")) return false
        return try {
            File(filePath).delete()
        } catch (_: SecurityException) {
            false
        }
    }

    private fun asRecoverable(error: SecurityException): RecoverableSecurityException? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
            error is RecoverableSecurityException
        ) {
            error
        } else {
            null
        }
    }
}
