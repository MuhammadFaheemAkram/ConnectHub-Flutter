import 'package:connect_hub/core/common/compact_count.dart';
import 'package:connect_hub/core/design_system/design_system.dart';
import 'package:connect_hub/domain/model/post.dart';
import 'package:connect_hub/domain/model/search_scope.dart';
import 'package:connect_hub/domain/model/user.dart';
import 'package:connect_hub/features/search/bloc/search_bloc.dart';
import 'package:connect_hub/features/search/bloc/search_event.dart';
import 'package:connect_hub/features/search/bloc/search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The Search tab: a search bar, scope chips, and then the recent searches
/// (nothing typed), the results, or what went wrong.
///
/// Stateful only for the search field's controller: a tapped recent search
/// is written into the field. Everything else is the [SearchBloc]'s.
class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.onOpenPost,
    required this.onOpenComments,
    required this.onOpenProfile,
  });

  /// Called with the post's id.
  final ValueChanged<String> onOpenPost;

  /// Called with the post's id.
  final ValueChanged<String> onOpenComments;

  /// Called with the user's id.
  final ValueChanged<String> onOpenProfile;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  SearchBloc get _bloc => context.read<SearchBloc>();

  /// A result was tapped: its query becomes a recent search (Correctness
  /// Rule 11), then the result opens.
  void _open(void Function(String id) open, String id) {
    _bloc.add(const SearchResultOpened());
    open(id);
  }

  void _searchAgain(String query) {
    _query.text = query;
    _bloc.add(SearchSubmitted(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: BlocListener<SearchBloc, SearchState>(
        listenWhen: (previous, current) =>
            current.message != null && current.message != previous.message,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!.text)));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.xxSmall,
                AppSpacing.medium,
                AppSpacing.xSmall,
              ),
              child: AppSearchField(
                controller: _query,
                hintText: 'Search people and posts',
                onChanged: (query) => _bloc.add(SearchQueryChanged(query)),
                onSubmitted: (query) => _bloc.add(SearchSubmitted(query)),
                onCleared: () => _bloc.add(const SearchQueryChanged('')),
              ),
            ),
            const _ScopeChips(),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) => switch (state.status) {
                  SearchStatus.idle => _RecentSearches(
                    searches: state.recentSearches,
                    onSelected: _searchAgain,
                    onClear: () =>
                        _bloc.add(const SearchRecentSearchesCleared()),
                  ),
                  SearchStatus.loading when state.results.isEmpty =>
                    const LoadingView(message: 'Searching…'),
                  SearchStatus.failure => ErrorView(
                    message: state.errorMessage,
                    onRetry: () => _bloc.add(const SearchRetried()),
                  ),
                  _ when state.hasNoMatches => EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No results',
                    message: _noMatchesMessage(state.scope, state.query),
                  ),
                  // Loading a new query keeps the previous results on screen,
                  // under a progress bar, rather than flashing a spinner.
                  _ => Column(
                    children: [
                      if (state.status == SearchStatus.loading)
                        const LinearProgressIndicator(
                          semanticsLabel: 'Searching',
                        ),
                      Expanded(
                        child: _Results(
                          people: state.people,
                          posts: state.posts,
                          personTile: (user) => _PersonTile(
                            user: user,
                            onTap: () => _open(widget.onOpenProfile, user.id),
                          ),
                          postCard: (post) => PostCard(
                            key: ValueKey(post.id),
                            post: post,
                            onTap: () => _open(widget.onOpenPost, post.id),
                            onAuthorTap: () =>
                                _open(widget.onOpenProfile, post.author.id),
                            onLike: () => _bloc.add(SearchLikeToggled(post)),
                            onComment: () =>
                                _open(widget.onOpenComments, post.id),
                            onBookmark: () =>
                                _bloc.add(SearchBookmarkToggled(post)),
                          ),
                        ),
                      ),
                    ],
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _noMatchesMessage(SearchScope scope, String query) =>
      switch (scope) {
        SearchScope.all => 'No people or posts match “$query”.',
        SearchScope.people => 'No people match “$query”.',
        SearchScope.posts => 'No posts match “$query”.',
      };
}

/// All · People · Posts. Only filters what the search already found.
class _ScopeChips extends StatelessWidget {
  const _ScopeChips();

  static const _labels = {
    SearchScope.all: 'All',
    SearchScope.people: 'People',
    SearchScope.posts: 'Posts',
  };

  @override
  Widget build(BuildContext context) {
    final scope = context.select((SearchBloc bloc) => bloc.state.scope);
    // A filter row starts at the leading edge, under the search bar's icon.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
        child: Wrap(
          spacing: AppSpacing.xSmall,
          children: [
            for (final MapEntry(key: value, value: label) in _labels.entries)
              ChoiceChip(
                label: Text(label),
                selected: value == scope,
                onSelected: (_) =>
                    context.read<SearchBloc>().add(SearchScopeChanged(value)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Nothing typed: the recent searches, or a prompt when there are none.
class _RecentSearches extends StatelessWidget {
  const _RecentSearches({
    required this.searches,
    required this.onSelected,
    required this.onClear,
  });

  final List<String> searches;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const EmptyStateView(
        icon: Icons.travel_explore,
        title: 'Search ConnectHub',
        message: 'Find people and posts by name or keyword.',
      );
    }
    final theme = Theme.of(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.xSmall,
            AppSpacing.xSmall,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent searches',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ),
        for (final query in searches)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            onTap: () => onSelected(query),
          ),
      ],
    );
  }
}

/// The results in two sections, People then Posts; a section with nothing
/// in it (or hidden by the scope) is left out.
class _Results extends StatelessWidget {
  const _Results({
    required this.people,
    required this.posts,
    required this.personTile,
    required this.postCard,
  });

  final List<User> people;
  final List<Post> posts;
  final Widget Function(User user) personTile;
  final Widget Function(Post post) postCard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.large),
      children: [
        if (people.isNotEmpty) ...[
          const _SectionTitle('People'),
          for (final user in people) personTile(user),
        ],
        if (posts.isNotEmpty) ...[
          const _SectionTitle('Posts'),
          for (final post in posts)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                0,
                AppSpacing.medium,
                AppSpacing.small,
              ),
              child: postCard(post),
            ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.xSmall,
      ),
      child: Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

/// A person in the results: picture, name, bio and follower count.
class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final followers = compactCount(user.followersCount);
    return ListTile(
      // The name is right next to it, so the picture stays silent.
      leading: ExcludeSemantics(
        child: UserAvatar(name: user.name, url: user.avatarUrl),
      ),
      title: Text(user.name),
      subtitle: Text(
        user.bio.isEmpty ? '$followers followers' : user.bio,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
