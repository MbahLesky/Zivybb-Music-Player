package com.lespa.zivybb.zivybb

import com.ryanheise.audioservice.AudioServiceActivity

// Extends audio_service's base activity (instead of plain FlutterActivity) so
// this activity shares the same FlutterEngine as the background audio
// service — required for the lock-screen/notification controls to work.
class MainActivity : AudioServiceActivity()
