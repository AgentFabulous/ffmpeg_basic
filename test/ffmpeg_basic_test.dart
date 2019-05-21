import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffmpeg_basic/ffmpeg_basic.dart';

void main() {
  const MethodChannel channel = MethodChannel('ffmpeg_basic');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FfmpegBasic.platformVersion, '42');
  });
}
