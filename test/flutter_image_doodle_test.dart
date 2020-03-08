import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_image_doodle/flutter_image_doodle.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_image_doodle');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterImageDoodle.platformVersion, '42');
  });
}
