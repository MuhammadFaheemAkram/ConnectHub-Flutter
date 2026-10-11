// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmarks_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookmarksState {

 BookmarksStatus get status;/// The most recently bookmarked first.
 List<Post> get posts; String get errorMessage;/// A one-time SnackBar, possibly with Undo.
 UiMessage? get message;
/// Create a copy of BookmarksState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarksStateCopyWith<BookmarksState> get copyWith => _$BookmarksStateCopyWithImpl<BookmarksState>(this as BookmarksState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BookmarksState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarksState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.posts, _this.posts)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as BookmarksState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.posts),_this.errorMessage,_this.message);
}

@override
String toString() {
  final _this = this as BookmarksState;
  return 'BookmarksState(status: ${_this.status}, posts: ${_this.posts}, errorMessage: ${_this.errorMessage}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $BookmarksStateCopyWith<$Res>  {
  factory $BookmarksStateCopyWith(BookmarksState value, $Res Function(BookmarksState) _then) = _$BookmarksStateCopyWithImpl;
@useResult
$Res call({
 BookmarksStatus status, List<Post> posts, String errorMessage, UiMessage? message
});


$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$BookmarksStateCopyWithImpl<$Res>
    implements $BookmarksStateCopyWith<$Res> {
  _$BookmarksStateCopyWithImpl(this._self, this._then);

  final BookmarksState _self;
  final $Res Function(BookmarksState) _then;

/// Create a copy of BookmarksState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? posts = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(BookmarksState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookmarksStatus,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}
/// Create a copy of BookmarksState
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


/// Adds pattern-matching-related methods to [BookmarksState].
extension BookmarksStatePatterns on BookmarksState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarksState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarksState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarksState value)  $default,){
final _that = this;
switch (_that) {
case _BookmarksState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarksState value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarksState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookmarksStatus status,  List<Post> posts,  String errorMessage,  UiMessage? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarksState() when $default != null:
return $default(_that.status,_that.posts,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookmarksStatus status,  List<Post> posts,  String errorMessage,  UiMessage? message)  $default,) {final _that = this;
switch (_that) {
case _BookmarksState():
return $default(_that.status,_that.posts,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookmarksStatus status,  List<Post> posts,  String errorMessage,  UiMessage? message)?  $default,) {final _that = this;
switch (_that) {
case _BookmarksState() when $default != null:
return $default(_that.status,_that.posts,_that.errorMessage,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _BookmarksState implements BookmarksState {
  const _BookmarksState({this.status = BookmarksStatus.loading,  List<Post> posts = const <Post>[], this.errorMessage = '', this.message}): _posts = posts;
  

@override@JsonKey() final  BookmarksStatus status;
/// The most recently bookmarked first.
 final  List<Post> _posts;
/// The most recently bookmarked first.
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override@JsonKey() final  String errorMessage;
/// A one-time SnackBar, possibly with Undo.
@override final  UiMessage? message;

/// Create a copy of BookmarksState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarksStateCopyWith<_BookmarksState> get copyWith => __$BookmarksStateCopyWithImpl<_BookmarksState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarksState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_posts),errorMessage,message);
}

@override
String toString() {
    return 'BookmarksState(status: $status, posts: $posts, errorMessage: $errorMessage, message: $message)';
}


}

/// @nodoc
abstract mixin class _$BookmarksStateCopyWith<$Res> implements $BookmarksStateCopyWith<$Res> {
  factory _$BookmarksStateCopyWith(_BookmarksState value, $Res Function(_BookmarksState) _then) = __$BookmarksStateCopyWithImpl;
@override @useResult
$Res call({
 BookmarksStatus status, List<Post> posts, String errorMessage, UiMessage? message
});


@override $UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$BookmarksStateCopyWithImpl<$Res>
    implements _$BookmarksStateCopyWith<$Res> {
  __$BookmarksStateCopyWithImpl(this._self, this._then);

  final _BookmarksState _self;
  final $Res Function(_BookmarksState) _then;

/// Create a copy of BookmarksState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? posts = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(_BookmarksState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookmarksStatus,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of BookmarksState
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
