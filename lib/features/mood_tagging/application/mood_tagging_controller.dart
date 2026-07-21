import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/mood_tag.dart';
import '../../../data/repositories/mood_tag_repository.dart';

final moodTagsStreamProvider = StreamProvider<List<MoodTag>>((ref) {
  return ref.watch(moodTagRepositoryProvider).watchMoodTags();
});
