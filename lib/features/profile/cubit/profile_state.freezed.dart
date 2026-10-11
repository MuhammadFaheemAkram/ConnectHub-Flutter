// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState()';
}


}

/// @nodoc
class $ProfileStateCopyWith<$Res>  {
$ProfileStateCopyWith(ProfileState _, $Res Function(ProfileState) __);
}


/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProfileLoading value)?  loading,TResult Function( ProfileError value)?  error,TResult Function( ProfileNotFound value)?  notFound,TResult Function( ProfileLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProfileLoading() when loading != null:
return loading(_that);case ProfileError() when error != null:
return error(_that);case ProfileNotFound() when notFound != null:
return notFound(_that);case ProfileLoaded() when loaded != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProfileLoading value)  loading,required TResult Function( ProfileError value)  error,required TResult Function( ProfileNotFound value)  notFound,required TResult Function( ProfileLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case ProfileLoading():
return loading(_that);case ProfileError():
return error(_that);case ProfileNotFound():
return notFound(_that);case ProfileLoaded():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProfileLoading value)?  loading,TResult? Function( ProfileError value)?  error,TResult? Function( ProfileNotFound value)?  notFound,TResult? Function( ProfileLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case ProfileLoading() when loading != null:
return loading(_that);case ProfileError() when error != null:
return error(_that);case ProfileNotFound() when notFound != null:
return notFound(_that);case ProfileLoaded() when loaded != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( String message)?  error,TResult Function()?  notFound,TResult Function( User user,  List<Post> posts,  bool isLoadingPosts,  UiMessage? message)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProfileLoading() when loading != null:
return loading();case ProfileError() when error != null:
return error(_that.message);case ProfileNotFound() when notFound != null:
return notFound();case ProfileLoaded() when loaded != null:
return loaded(_that.user,_that.posts,_that.isLoadingPosts,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( String message)  error,required TResult Function()  notFound,required TResult Function( User user,  List<Post> posts,  bool isLoadingPosts,  UiMessage? message)  loaded,}) {final _that = this;
switch (_that) {
case ProfileLoading():
return loading();case ProfileError():
return error(_that.message);case ProfileNotFound():
return notFound();case ProfileLoaded():
return loaded(_that.user,_that.posts,_that.isLoadingPosts,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( String message)?  error,TResult? Function()?  notFound,TResult? Function( User user,  List<Post> posts,  bool isLoadingPosts,  UiMessage? message)?  loaded,}) {final _that = this;
switch (_that) {
case ProfileLoading() when loading != null:
return loading();case ProfileError() when error != null:
return error(_that.message);case ProfileNotFound() when notFound != null:
return notFound();case ProfileLoaded() when loaded != null:
return loaded(_that.user,_that.posts,_that.isLoadingPosts,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ProfileLoading implements ProfileState {
  const ProfileLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState.loading()';
}


}




/// @nodoc


class ProfileError implements ProfileState {
  const ProfileError(this.message);
  

 final  String message;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileErrorCopyWith<ProfileError> get copyWith => _$ProfileErrorCopyWithImpl<ProfileError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'ProfileState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ProfileErrorCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileErrorCopyWith(ProfileError value, $Res Function(ProfileError) _then) = _$ProfileErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ProfileErrorCopyWithImpl<$Res>
    implements $ProfileErrorCopyWith<$Res> {
  _$ProfileErrorCopyWithImpl(this._self, this._then);

  final ProfileError _self;
  final $Res Function(ProfileError) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ProfileError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ProfileNotFound implements ProfileState {
  const ProfileNotFound();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ProfileState.notFound()';
}


}




/// @nodoc


class ProfileLoaded implements ProfileState {
  const ProfileLoaded({required this.user,  List<Post> posts = const <Post>[], this.isLoadingPosts = false, this.message}): _posts = posts;
  

 final  User user;
/// Newest first.
 final  List<Post> _posts;
/// Newest first.
@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

/// No posts are cached yet, and the first fetch is still running.
@JsonKey() final  bool isLoadingPosts;
/// A one-time SnackBar.
 final  UiMessage? message;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLoadedCopyWith<ProfileLoaded> get copyWith => _$ProfileLoadedCopyWithImpl<ProfileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLoaded&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.posts, _posts)&&(identical(other.isLoadingPosts, isLoadingPosts) || other.isLoadingPosts == isLoadingPosts)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,user,const DeepCollectionEquality().hash(_posts),isLoadingPosts,message);
}

@override
String toString() {
    return 'ProfileState.loaded(user: $user, posts: $posts, isLoadingPosts: $isLoadingPosts, message: $message)';
}


}

/// @nodoc
abstract mixin class $ProfileLoadedCopyWith<$Res> implements $ProfileStateCopyWith<$Res> {
  factory $ProfileLoadedCopyWith(ProfileLoaded value, $Res Function(ProfileLoaded) _then) = _$ProfileLoadedCopyWithImpl;
@useResult
$Res call({
 User user, List<Post> posts, bool isLoadingPosts, UiMessage? message
});


$UserCopyWith<$Res> get user;$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$ProfileLoadedCopyWithImpl<$Res>
    implements $ProfileLoadedCopyWith<$Res> {
  _$ProfileLoadedCopyWithImpl(this._self, this._then);

  final ProfileLoaded _self;
  final $Res Function(ProfileLoaded) _then;

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? posts = null,Object? isLoadingPosts = null,Object? message = freezed,}) {
  return _then(ProfileLoaded(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,isLoadingPosts: null == isLoadingPosts ? _self.isLoadingPosts : isLoadingPosts // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of ProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res> get user {
  
  return $UserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of ProfileState
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
