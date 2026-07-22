import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/utils/duration_formatter.dart';

void main() {
  group('formatTrackDuration', () {
    test('pads seconds under ten', () {
      expect(
        formatTrackDuration(const Duration(minutes: 3, seconds: 5)),
        '3:05',
      );
    });

    test('shows zero minutes for short clips', () {
      expect(formatTrackDuration(const Duration(seconds: 48)), '0:48');
    });

    test('adds an hours segment past the hour', () {
      expect(
        formatTrackDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('handles zero', () {
      expect(formatTrackDuration(Duration.zero), '0:00');
    });
  });
}
