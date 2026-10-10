// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedState()';
}


}

/// @nodoc
class $FeedStateCopyWith<$Res>  {
$FeedStateCopyWith(FeedState _, $Res Function(FeedState) __);
}


/// Adds pattern-matching-related methods to [FeedState].
extension FeedStatePatterns on FeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FeedLoading value)?  loading,TResult Function( FeedEmpty value)?  empty,TResult Function( FeedError value)?  error,TResult Function( FeedLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FeedLoading() when loading != null:
return loading(_that);case FeedEmpty() when empty != null:
return empty(_that);case FeedError() when error != null:
return error(_that);case FeedLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FeedLoading value)  loading,required TResult Function( FeedEmpty value)  empty,required TResult Function( FeedError value)  error,required TResult Function( FeedLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case FeedLoading():
return loading(_that);case FeedEmpty():
return empty(_that);case FeedError():
return error(_that);case FeedLoaded():
return loaded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FeedLoading value)?  loading,TResult? Function( FeedEmpty value)?  empty,TResult? Function( FeedError value)?  error,TResult? Function( FeedLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case FeedLoading() when loading != null:
return loading(_that);case FeedEmpty() when empty != null:
return empty(_that);case FeedError() when error != null:
return error(_that);case FeedLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  empty,TResult Function( String message)?  error,TResult Function( List<Post> posts,  bool hasMore,  LoadMoreStatus loadMore,  UiMessage? message)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FeedLoading() when loading != null:
return loading();case FeedEmpty() when empty != null:
return empty();case FeedError() when error != null:
return error(_that.message);case FeedLoaded() when loaded != null:
return loaded(_that.posts,_that.hasMore,_that.loadMore,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  empty,required TResult Function( String message)  error,required TResult Function( List<Post> posts,  bool hasMore,  LoadMoreStatus loadMore,  UiMessage? message)  loaded,}) {final _that = this;
switch (_that) {
case FeedLoading():
return loading();case FeedEmpty():
return empty();case FeedError():
return error(_that.message);case FeedLoaded():
return loaded(_that.posts,_that.hasMore,_that.loadMore,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  empty,TResult? Function( String message)?  error,TResult? Function( List<Post> posts,  bool hasMore,  LoadMoreStatus loadMore,  UiMessage? message)?  loaded,}) {final _that = this;
switch (_that) {
case FeedLoading() when loading != null:
return loading();case FeedEmpty() when empty != null:
return empty();case FeedError() when error != null:
return error(_that.message);case FeedLoaded() when loaded != null:
return loaded(_that.posts,_that.hasMore,_that.loadMore,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class FeedLoading implements FeedState {
  const FeedLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedState.loading()';
}


}




/// @nodoc


class FeedEmpty implements FeedState {
  const FeedEmpty();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FeedState.empty()';
}


}




/// @nodoc


class FeedError implements FeedState {
  const FeedError(this.message);
  

 final  String message;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedErrorCopyWith<FeedError> get copyWith => _$FeedErrorCopyWithImpl<FeedError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'FeedState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $FeedErrorCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory $FeedErrorCopyWith(FeedError value, $Res Function(FeedError) _then) = _$FeedErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FeedErrorCopyWithImpl<$Res>
    implements $FeedErrorCopyWith<$Res> {
  _$FeedErrorCopyWithImpl(this._self, this._then);

  final FeedError _self;
  final $Res Function(FeedError) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FeedError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FeedLoaded implements FeedState {
  const FeedLoaded({required  List<Post> posts, this.hasMore = true, this.loadMore = LoadMoreStatus.idle, this.message}): _posts = posts;
  

 final  List<Post> _posts;
 List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// Whether older posts can still be loaded.
@JsonKey() final  bool hasMore;
@JsonKey() final  LoadMoreStatus loadMore;
/// A one-time SnackBar.
 final  UiMessage? message;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedLoadedCopyWith<FeedLoaded> get copyWith => _$FeedLoadedCopyWithImpl<FeedLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedLoaded&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.loadMore, loadMore) || other.loadMore == loadMore)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),hasMore,loadMore,message);
}

@override
String toString() {
    return 'FeedState.loaded(posts: $posts, hasMore: $hasMore, loadMore: $loadMore, message: $message)';
}


}

/// @nodoc
abstract mixin class $FeedLoadedCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory $FeedLoadedCopyWith(FeedLoaded value, $Res Function(FeedLoaded) _then) = _$FeedLoadedCopyWithImpl;
@useResult
$Res call({
 List<Post> posts, bool hasMore, LoadMoreStatus loadMore, UiMessage? message
});


$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$FeedLoadedCopyWithImpl<$Res>
    implements $FeedLoadedCopyWith<$Res> {
  _$FeedLoadedCopyWithImpl(this._self, this._then);

  final FeedLoaded _self;
  final $Res Function(FeedLoaded) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? hasMore = null,Object? loadMore = null,Object? message = freezed,}) {
  return _then(FeedLoaded(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,loadMore: null == loadMore ? _self.loadMore : loadMore // ignore: cast_nullable_to_non_nullable
as LoadMoreStatus,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of FeedState
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
