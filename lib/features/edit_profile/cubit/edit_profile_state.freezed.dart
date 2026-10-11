// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditProfileState {

/// The profile the form started from; `null` until it has loaded.
 User? get original;/// Why the profile couldn't be loaded, if it couldn't.
 String? get loadError; String get name; String get bio; String get avatarUrl; FormStatus get status;/// Why the last save failed, from the server.
 String? get errorMessage;
/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditProfileStateCopyWith<EditProfileState> get copyWith => _$EditProfileStateCopyWithImpl<EditProfileState>(this as EditProfileState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EditProfileState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditProfileState&&(identical(other.original, _this.original) || other.original == _this.original)&&(identical(other.loadError, _this.loadError) || other.loadError == _this.loadError)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as EditProfileState;
  return Object.hash(runtimeType,_this.original,_this.loadError,_this.name,_this.bio,_this.avatarUrl,_this.status,_this.errorMessage);
}

@override
String toString() {
  final _this = this as EditProfileState;
  return 'EditProfileState(original: ${_this.original}, loadError: ${_this.loadError}, name: ${_this.name}, bio: ${_this.bio}, avatarUrl: ${_this.avatarUrl}, status: ${_this.status}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $EditProfileStateCopyWith<$Res>  {
  factory $EditProfileStateCopyWith(EditProfileState value, $Res Function(EditProfileState) _then) = _$EditProfileStateCopyWithImpl;
@useResult
$Res call({
 User? original, String? loadError, String name, String bio, String avatarUrl, FormStatus status, String? errorMessage
});


$UserCopyWith<$Res>? get original;

}
/// @nodoc
class _$EditProfileStateCopyWithImpl<$Res>
    implements $EditProfileStateCopyWith<$Res> {
  _$EditProfileStateCopyWithImpl(this._self, this._then);

  final EditProfileState _self;
  final $Res Function(EditProfileState) _then;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? original = freezed,Object? loadError = freezed,Object? name = null,Object? bio = null,Object? avatarUrl = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(EditProfileState(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as User?,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}


/// Adds pattern-matching-related methods to [EditProfileState].
extension EditProfileStatePatterns on EditProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EditProfileState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EditProfileState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EditProfileState value)  $default,){
final _that = this;
switch (_that) {
case _EditProfileState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EditProfileState value)?  $default,){
final _that = this;
switch (_that) {
case _EditProfileState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( User? original,  String? loadError,  String name,  String bio,  String avatarUrl,  FormStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EditProfileState() when $default != null:
return $default(_that.original,_that.loadError,_that.name,_that.bio,_that.avatarUrl,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( User? original,  String? loadError,  String name,  String bio,  String avatarUrl,  FormStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _EditProfileState():
return $default(_that.original,_that.loadError,_that.name,_that.bio,_that.avatarUrl,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( User? original,  String? loadError,  String name,  String bio,  String avatarUrl,  FormStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _EditProfileState() when $default != null:
return $default(_that.original,_that.loadError,_that.name,_that.bio,_that.avatarUrl,_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _EditProfileState extends EditProfileState {
  const _EditProfileState({this.original, this.loadError, this.name = '', this.bio = '', this.avatarUrl = '', this.status = FormStatus.idle, this.errorMessage}): super._();
  

/// The profile the form started from; `null` until it has loaded.
@override final  User? original;
/// Why the profile couldn't be loaded, if it couldn't.
@override final  String? loadError;
@override@JsonKey() final  String name;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String avatarUrl;
@override@JsonKey() final  FormStatus status;
/// Why the last save failed, from the server.
@override final  String? errorMessage;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EditProfileStateCopyWith<_EditProfileState> get copyWith => __$EditProfileStateCopyWithImpl<_EditProfileState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EditProfileState&&(identical(other.original, original) || other.original == original)&&(identical(other.loadError, loadError) || other.loadError == loadError)&&(identical(other.name, name) || other.name == name)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,original,loadError,name,bio,avatarUrl,status,errorMessage);
}

@override
String toString() {
    return 'EditProfileState(original: $original, loadError: $loadError, name: $name, bio: $bio, avatarUrl: $avatarUrl, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$EditProfileStateCopyWith<$Res> implements $EditProfileStateCopyWith<$Res> {
  factory _$EditProfileStateCopyWith(_EditProfileState value, $Res Function(_EditProfileState) _then) = __$EditProfileStateCopyWithImpl;
@override @useResult
$Res call({
 User? original, String? loadError, String name, String bio, String avatarUrl, FormStatus status, String? errorMessage
});


@override $UserCopyWith<$Res>? get original;

}
/// @nodoc
class __$EditProfileStateCopyWithImpl<$Res>
    implements _$EditProfileStateCopyWith<$Res> {
  __$EditProfileStateCopyWithImpl(this._self, this._then);

  final _EditProfileState _self;
  final $Res Function(_EditProfileState) _then;

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? original = freezed,Object? loadError = freezed,Object? name = null,Object? bio = null,Object? avatarUrl = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_EditProfileState(
original: freezed == original ? _self.original : original // ignore: cast_nullable_to_non_nullable
as User?,loadError: freezed == loadError ? _self.loadError : loadError // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of EditProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserCopyWith<$Res>? get original {
    if (_self.original == null) {
    return null;
  }

  return $UserCopyWith<$Res>(_self.original!, (value) {
    return _then(_self.copyWith(original: value));
  });
}
}

// dart format on
