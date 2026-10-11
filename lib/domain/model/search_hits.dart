import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_hits.freezed.dart';

/// What a search matched, as ids in the server's order.
///
/// A search caches what it found and returns only this. The results
/// themselves are then read from the cache by id
/// (`SearchRepository.watchResults`), so they stay live like every other
/// screen.
@freezed
abstract class SearchHits with _$SearchHits {
  const factory SearchHits({
    @Default(<String>[]) List<String> userIds,
    @Default(<String>[]) List<String> postIds,
  }) = _SearchHits;
}
