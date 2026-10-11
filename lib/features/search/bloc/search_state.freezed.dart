// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchState {

 SearchStatus get status;/// The query being searched or shown, trimmed.
 String get query; SearchScope get scope;/// Everything the server found, whatever the scope.
 SearchResults get results;/// Newest first.
 List<String> get recentSearches; String get errorMessage;/// A one-time SnackBar.
 UiMessage? get message;
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateCopyWith<SearchState> get copyWith => _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.results, _this.results) || other.results == _this.results)&&const DeepCollectionEquality().equals(other.recentSearches, _this.recentSearches)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as SearchState;
  return Object.hash(runtimeType,_this.status,_this.query,_this.scope,_this.results,const DeepCollectionEquality().hash(_this.recentSearches),_this.errorMessage,_this.message);
}

@override
String toString() {
  final _this = this as SearchState;
  return 'SearchState(status: ${_this.status}, query: ${_this.query}, scope: ${_this.scope}, results: ${_this.results}, recentSearches: ${_this.recentSearches}, errorMessage: ${_this.errorMessage}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res>  {
  factory $SearchStateCopyWith(SearchState value, $Res Function(SearchState) _then) = _$SearchStateCopyWithImpl;
@useResult
$Res call({
 SearchStatus status, String query, SearchScope scope, SearchResults results, List<String> recentSearches, String errorMessage, UiMessage? message
});


$SearchResultsCopyWith<$Res> get results;$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$SearchStateCopyWithImpl<$Res>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? query = null,Object? scope = null,Object? results = null,Object? recentSearches = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(SearchState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SearchStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as SearchScope,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as SearchResults,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}
/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<$Res> get results {
  
  return $SearchResultsCopyWith<$Res>(_self.results, (value) {
    return _then(_self.copyWith(results: value));
  });
}/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UiMessageCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $UiMessageCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchState].
extension SearchStatePatterns on SearchState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchState value)  $default,){
final _that = this;
switch (_that) {
case _SearchState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SearchStatus status,  String query,  SearchScope scope,  SearchResults results,  List<String> recentSearches,  String errorMessage,  UiMessage? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.status,_that.query,_that.scope,_that.results,_that.recentSearches,_that.errorMessage,_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SearchStatus status,  String query,  SearchScope scope,  SearchResults results,  List<String> recentSearches,  String errorMessage,  UiMessage? message)  $default,) {final _that = this;
switch (_that) {
case _SearchState():
return $default(_that.status,_that.query,_that.scope,_that.results,_that.recentSearches,_that.errorMessage,_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SearchStatus status,  String query,  SearchScope scope,  SearchResults results,  List<String> recentSearches,  String errorMessage,  UiMessage? message)?  $default,) {final _that = this;
switch (_that) {
case _SearchState() when $default != null:
return $default(_that.status,_that.query,_that.scope,_that.results,_that.recentSearches,_that.errorMessage,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SearchState extends SearchState {
  const _SearchState({this.status = SearchStatus.idle, this.query = '', this.scope = SearchScope.all, this.results = const SearchResults(),  List<String> recentSearches = const <String>[], this.errorMessage = '', this.message}): _recentSearches = recentSearches,super._();
  

@override@JsonKey() final  SearchStatus status;
/// The query being searched or shown, trimmed.
@override@JsonKey() final  String query;
@override@JsonKey() final  SearchScope scope;
/// Everything the server found, whatever the scope.
@override@JsonKey() final  SearchResults results;
/// Newest first.
 final  List<String> _recentSearches;
/// Newest first.
@override@JsonKey() List<String> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

@override@JsonKey() final  String errorMessage;
/// A one-time SnackBar.
@override final  UiMessage? message;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateCopyWith<_SearchState> get copyWith => __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchState&&(identical(other.status, status) || other.status == status)&&(identical(other.query, query) || other.query == query)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.results, results) || other.results == results)&&const DeepCollectionEquality().equals(other.recentSearches, _recentSearches)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,query,scope,results,const DeepCollectionEquality().hash(_recentSearches),errorMessage,message);
}

@override
String toString() {
    return 'SearchState(status: $status, query: $query, scope: $scope, results: $results, recentSearches: $recentSearches, errorMessage: $errorMessage, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res> implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(_SearchState value, $Res Function(_SearchState) _then) = __$SearchStateCopyWithImpl;
@override @useResult
$Res call({
 SearchStatus status, String query, SearchScope scope, SearchResults results, List<String> recentSearches, String errorMessage, UiMessage? message
});


@override $SearchResultsCopyWith<$Res> get results;@override $UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$SearchStateCopyWithImpl<$Res>
    implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? query = null,Object? scope = null,Object? results = null,Object? recentSearches = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(_SearchState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SearchStatus,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as SearchScope,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as SearchResults,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchResultsCopyWith<$Res> get results {
  
  return $SearchResultsCopyWith<$Res>(_self.results, (value) {
    return _then(_self.copyWith(results: value));
  });
}/// Create a copy of SearchState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UiMessageCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $UiMessageCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}

// dart format on
