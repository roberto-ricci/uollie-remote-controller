import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uollie_remote_controller/views/settings_dialog.dart';

void main() {
  testWidgets('loads trims and saves both edited values', (tester) async {
    List<int>? saved;
    await tester.pumpWidget(MaterialApp(
      home: SettingsDialog(
        connected: const Stream<bool>.empty(),
        readTrim: () async => [95, 100],
        writeTrim: (left, right) async { saved = [left, right]; },
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Left motor: 95%'), findsOneWidget);
    tester.widget<Slider>(find.byType(Slider).first).onChanged!(90);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, [90, 100]);
  });

  testWidgets('disconnection disables editing and saving', (tester) async {
    final connection = StreamController<bool>();
    addTearDown(connection.close);
    await tester.pumpWidget(MaterialApp(
      home: SettingsDialog(
        connected: connection.stream,
        readTrim: () async => [95, 100],
        writeTrim: (_, __) async => fail('Must not write after disconnect'),
      ),
    ));
    await tester.pumpAndSettle();
    connection.add(false);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    for (final slider in tester.widgetList<Slider>(find.byType(Slider))) {
      expect(slider.onChanged, isNull);
    }
    expect(find.textContaining('Device disconnected'), findsOneWidget);
  });

  testWidgets('failed read offers retry and prevents saving defaults', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(MaterialApp(
      home: SettingsDialog(
        connected: const Stream<bool>.empty(),
        readTrim: () async {
          if (attempts++ == 0) throw StateError('Read failed');
          return [80, 90];
        },
        writeTrim: (_, __) async {},
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Left motor: 80%'), findsOneWidget);
    expect(find.text('Right motor: 90%'), findsOneWidget);
  });
}
