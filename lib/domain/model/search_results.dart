import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_results.freezed.dart';

/// The people and posts a search found, in the server's order.
@freezed
abstract class SearchResults with _$SearchResults {
  const SearchResults._();

  const factory SearchResults({
    @Default(<User>[]) List<User> users,
    @Default(<Post>[]) List<Post> posts,
  }) = _SearchResults;

  bool get isEmpty => users.isEmpty && posts.isEmpty;
}
