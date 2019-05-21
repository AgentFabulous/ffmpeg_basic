import 'dart:async';

import 'package:flutter/services.dart';

class FfmpegBasic {
  static const MethodChannel _channel = const MethodChannel('ffmpeg_basic');

  static Future<String> getExternalLibs() async {
    final String version = await _channel.invokeMethod('getExternalLibs');
    return version;
  }

  static Future<int> exec(String cmd) async {
    final int rc = await _channel.invokeMethod('exec', {'cmd': cmd});
    return rc;
  }

  static Future<int> execList(List<String> cmd) async {
    final int rc = await _channel.invokeMethod('execList', {'cmd': cmd});
    return rc;
  }

  static Future cancel() async {
    await _channel.invokeMethod('cancel');
  }
}
