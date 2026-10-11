// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostDetailState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PostDetailState()';
}


}

/// @nodoc
class $PostDetailStateCopyWith<$Res>  {
$PostDetailStateCopyWith(PostDetailState _, $Res Function(PostDetailState) __);
}


/// Adds pattern-matching-related methods to [PostDetailState].
extension PostDetailStatePatterns on PostDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PostDetailLoading value)?  loading,TResult Function( PostDetailError value)?  error,TResult Function( PostDetailNotFound value)?  notFound,TResult Function( PostDetailLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PostDetailLoading() when loading != null:
return loading(_that);case PostDetailError() when error != null:
return error(_that);case PostDetailNotFound() when notFound != null:
return notFound(_that);case PostDetailLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PostDetailLoading value)  loading,required TResult Function( PostDetailError value)  error,required TResult Function( PostDetailNotFound value)  notFound,required TResult Function( PostDetailLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case PostDetailLoading():
return loading(_that);case PostDetailError():
return error(_that);case PostDetailNotFound():
return notFound(_that);case PostDetailLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PostDetailLoading value)?  loading,TResult? Function( PostDetailError value)?  error,TResult? Function( PostDetailNotFound value)?  notFound,TResult? Function( PostDetailLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case PostDetailLoading() when loading != null:
return loading(_that);case PostDetailError() when error != null:
return error(_that);case PostDetailNotFound() when notFound != null:
return notFound(_that);case PostDetailLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String message)?  error,TResult Function()?  notFound,TResult Function( Post post,  List<Comment> recentComments,  bool isSending,  int sentCount,  UiMessage? message)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PostDetailLoading() when loading != null:
return loading();case PostDetailError() when error != null:
return error(_that.message);case PostDetailNotFound() when notFound != null:
return notFound();case PostDetailLoaded() when loaded != null:
return loaded(_that.post,_that.recentComments,_that.isSending,_that.sentCount,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function()  notFound,required TResult Function( Post post,  List<Comment> recentComments,  bool isSending,  int sentCount,  UiMessage? message)  loaded,}) {final _that = this;
switch (_that) {
case PostDetailLoading():
return loading();case PostDetailError():
return error(_that.message);case PostDetailNotFound():
return notFound();case PostDetailLoaded():
return loaded(_that.post,_that.recentComments,_that.isSending,_that.sentCount,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function()?  notFound,TResult? Function( Post post,  List<Comment> recentComments,  bool isSending,  int sentCount,  UiMessage? message)?  loaded,}) {final _that = this;
switch (_that) {
case PostDetailLoading() when loading != null:
return loading();case PostDetailError() when error != null:
return error(_that.message);case PostDetailNotFound() when notFound != null:
return notFound();case PostDetailLoaded() when loaded != null:
return loaded(_that.post,_that.recentComments,_that.isSending,_that.sentCount,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class PostDetailLoading implements PostDetailState {
  const PostDetailLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PostDetailState.loading()';
}


}




/// @nodoc


class PostDetailError implements PostDetailState {
  const PostDetailError(this.message);
  

 final  String message;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailErrorCopyWith<PostDetailError> get copyWith => _$PostDetailErrorCopyWithImpl<PostDetailError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'PostDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $PostDetailErrorCopyWith<$Res> implements $PostDetailStateCopyWith<$Res> {
  factory $PostDetailErrorCopyWith(PostDetailError value, $Res Function(PostDetailError) _then) = _$PostDetailErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$PostDetailErrorCopyWithImpl<$Res>
    implements $PostDetailErrorCopyWith<$Res> {
  _$PostDetailErrorCopyWithImpl(this._self, this._then);

  final PostDetailError _self;
  final $Res Function(PostDetailError) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(PostDetailError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PostDetailNotFound implements PostDetailState {
  const PostDetailNotFound();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PostDetailState.notFound()';
}


}




/// @nodoc


class PostDetailLoaded implements PostDetailState {
  const PostDetailLoaded({required this.post,  List<Comment> recentComments = const <Comment>[], this.isSending = false, this.sentCount = 0, this.message}): _recentComments = recentComments;
  

 final  Post post;
/// The latest few comments, the oldest of them first.
 final  List<Comment> _recentComments;
/// The latest few comments, the oldest of them first.
@JsonKey() List<Comment> get recentComments {
  if (_recentComments is EqualUnmodifiableListView) return _recentComments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentComments);
}

@JsonKey() final  bool isSending;
/// Goes up by one each time a comment is sent. A one-time effect: the
/// View clears the input when it changes.
@JsonKey() final  int sentCount;
/// A one-time SnackBar.
 final  UiMessage? message;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailLoadedCopyWith<PostDetailLoaded> get copyWith => _$PostDetailLoadedCopyWithImpl<PostDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailLoaded&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.recentComments, _recentComments)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.sentCount, sentCount) || other.sentCount == sentCount)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,post,const DeepCollectionEquality().hash(_recentComments),isSending,sentCount,message);
}

@override
String toString() {
    return 'PostDetailState.loaded(post: $post, recentComments: $recentComments, isSending: $isSending, sentCount: $sentCount, message: $message)';
}


}

/// @nodoc
abstract mixin class $PostDetailLoadedCopyWith<$Res> implements $PostDetailStateCopyWith<$Res> {
  factory $PostDetailLoadedCopyWith(PostDetailLoaded value, $Res Function(PostDetailLoaded) _then) = _$PostDetailLoadedCopyWithImpl;
@useResult
$Res call({
 Post post, List<Comment> recentComments, bool isSending, int sentCount, UiMessage? message
});


$PostCopyWith<$Res> get post;$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$PostDetailLoadedCopyWithImpl<$Res>
    implements $PostDetailLoadedCopyWith<$Res> {
  _$PostDetailLoadedCopyWithImpl(this._self, this._then);

  final PostDetailLoaded _self;
  final $Res Function(PostDetailLoaded) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? post = null,Object? recentComments = null,Object? isSending = null,Object? sentCount = null,Object? message = freezed,}) {
  return _then(PostDetailLoaded(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,recentComments: null == recentComments ? _self._recentComments : recentComments // ignore: cast_nullable_to_non_nullable
as List<Comment>,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,sentCount: null == sentCount ? _self.sentCount : sentCount // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}/// Create a copy of PostDetailState
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
