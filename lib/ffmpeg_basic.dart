import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FfmpegBasic {
  static const MethodChannel _channel = const MethodChannel('ffmpeg_basic');
  static const EventChannel _events = const EventChannel('ffmpeg_basic_events');
  static Future<String> getExternalLibs() async {
    final String version = await _channel.invokeMethod('getExternalLibs');
    return version;
  }

  static registerStreamListener(
      {@required StreamSubscription subscription,
      @required Function fn,
      bool forceRegister = false}) {
    if (subscription != null && forceRegister) {
      subscription.cancel();
      subscription = null;
    }

    if (subscription == null)
      subscription = _events.receiveBroadcastStream().listen(fn);
  }

  static Future<void> exec(String cmd) async {
    final int rc = await _channel.invokeMethod('exec', {'cmd': cmd});
    return rc;
  }

  static Future<void> execList(List<String> cmd) async {
    final int rc = await _channel.invokeMethod('execList', {'cmd': cmd});
    return rc;
  }

  static Future cancel() async {
    await _channel.invokeMethod('cancel');
  }
}
