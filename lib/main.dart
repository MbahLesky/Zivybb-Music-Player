import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'core/services/audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // A manually-created container (rather than ProviderScope's own) so the
  // audio handler can be built and registered with AudioService before
  // runApp, while still sharing every provider with the rest of the app.
  final container = ProviderContainer();
  await AudioService.init(
    builder: () => container.read(audioHandlerProvider),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.lespa.zivybb.zivybb.audio',
      androidNotificationChannelName: 'Zivybb playback',
      // Keeps the foreground service alive through pause (rather than the
      // default of stopping it) so resuming playback from the lock screen
      // never hits Android 12+'s ForegroundServiceStartNotAllowedException.
      androidStopForegroundOnPause: false,
    ),
  );

  // Best-effort: without this the notification silently never shows on
  // Android 13+, but playback must still work if it's denied.
  unawaited(Permission.notification.request());

  runApp(
    UncontrolledProviderScope(container: container, child: const ZivybbApp()),
  );
}
