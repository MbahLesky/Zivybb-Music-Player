import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';

/// Maximum number of tracks surfaced in a single discovery feed.
const _feedSize = 20;

/// Surfaces a feed of random, lesser-played tracks from artists already in
/// the library (SRS F-4.3, Screens.md #8), refreshed on demand rather than
/// reactively — so liking or queueing a card doesn't reshuffle the feed
/// out from under the user.
class DiscoveryController extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() => _pickFeed();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_pickFeed);
  }

  Future<List<Song>> _pickFeed() async {
    final songs = await ref.read(songRepositoryProvider).allSongs();
    final candidates = songs.where((song) => !song.isMissing).toList()
      ..sort((a, b) => a.playCount.compareTo(b.playCount));

    // Favor the half of the library that's played least often.
    final poolSize = max(1, (candidates.length / 2).ceil());
    final pool = candidates.take(poolSize).toList()..shuffle(Random());
    return pool.take(_feedSize).toList(growable: false);
  }
}

final discoveryControllerProvider =
    AsyncNotifierProvider<DiscoveryController, List<Song>>(
      DiscoveryController.new,
    );
