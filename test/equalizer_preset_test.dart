import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/repositories/equalizer_preset_repository.dart';

void main() {
  late AppDatabase database;
  late EqualizerPresetRepository repository;

  setUp(() {
    database = AppDatabase.connect(NativeDatabase.memory());
    repository = EqualizerPresetRepository(database: database);
  });

  tearDown(() => database.close());

  test('seeding creates the built-in presets plus the custom curve', () async {
    await repository.ensureSeeded();

    final presets = await repository.watchPresets().first;
    expect(presets.map((p) => p.id), contains(customEqualizerPresetId));
    expect(presets.map((p) => p.id), contains('bass_boost'));
    expect(
      presets.firstWhere((p) => p.id == customEqualizerPresetId).bandGains,
      List<double>.filled(equalizerBandLabels.length, 0),
      reason: 'the custom curve starts flat',
    );
  });

  test(
    're-seeding backfills new presets without touching tuned ones',
    () async {
      // Stand in for an install predating the custom curve: only the original
      // built-ins are stored.
      await database
          .into(database.equalizerPresets)
          .insert(
            EqualizerPresetsCompanion.insert(
              id: 'flat',
              name: 'Flat',
              bandLevelsJson: '[0,0,0,0,0]',
            ),
          );

      await repository.ensureSeeded();
      await repository.updateBandGains(customEqualizerPresetId, [
        5,
        4,
        3,
        2,
        1,
      ]);

      // A later app start must not flatten the user's tuned curve.
      await repository.ensureSeeded();

      final presets = await repository.watchPresets().first;
      expect(
        presets.firstWhere((p) => p.id == customEqualizerPresetId).bandGains,
        [5, 4, 3, 2, 1],
      );
      expect(
        presets.where((p) => p.id == 'flat'),
        hasLength(1),
        reason: 'seeding twice must not duplicate an existing preset',
      );
    },
  );

  test('updateBandGains rewrites only the targeted preset', () async {
    await repository.ensureSeeded();
    await repository.updateBandGains(customEqualizerPresetId, [1, 2, 3, 4, 5]);

    final presets = await repository.watchPresets().first;
    expect(
      presets.firstWhere((p) => p.id == customEqualizerPresetId).bandGains,
      [1, 2, 3, 4, 5],
    );
    expect(
      presets.firstWhere((p) => p.id == 'bass_boost').bandGains,
      [6, 4, 0, -2, -2],
      reason: 'built-in presets stay as shipped',
    );
  });
}
