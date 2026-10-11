// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_tools_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsToolsState {

/// "Simulate network failure".
 bool get failsRequests; bool get isClearingCache;/// A one-time SnackBar.
 UiMessage? get message;
/// Create a copy of SettingsToolsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsToolsStateCopyWith<SettingsToolsState> get copyWith => _$SettingsToolsStateCopyWithImpl<SettingsToolsState>(this as SettingsToolsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SettingsToolsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsToolsState&&(identical(other.failsRequests, _this.failsRequests) || other.failsRequests == _this.failsRequests)&&(identical(other.isClearingCache, _this.isClearingCache) || other.isClearingCache == _this.isClearingCache)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as SettingsToolsState;
  return Object.hash(runtimeType,_this.failsRequests,_this.isClearingCache,_this.message);
}

@override
String toString() {
  final _this = this as SettingsToolsState;
  return 'SettingsToolsState(failsRequests: ${_this.failsRequests}, isClearingCache: ${_this.isClearingCache}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $SettingsToolsStateCopyWith<$Res>  {
  factory $SettingsToolsStateCopyWith(SettingsToolsState value, $Res Function(SettingsToolsState) _then) = _$SettingsToolsStateCopyWithImpl;
@useResult
$Res call({
 bool failsRequests, bool isClearingCache, UiMessage? message
});


$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$SettingsToolsStateCopyWithImpl<$Res>
    implements $SettingsToolsStateCopyWith<$Res> {
  _$SettingsToolsStateCopyWithImpl(this._self, this._then);

  final SettingsToolsState _self;
  final $Res Function(SettingsToolsState) _then;

/// Create a copy of SettingsToolsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? failsRequests = null,Object? isClearingCache = null,Object? message = freezed,}) {
  return _then(SettingsToolsState(
failsRequests: null == failsRequests ? _self.failsRequests : failsRequests // ignore: cast_nullable_to_non_nullable
as bool,isClearingCache: null == isClearingCache ? _self.isClearingCache : isClearingCache // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}
/// Create a copy of SettingsToolsState
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


/// Adds pattern-matching-related methods to [SettingsToolsState].
extension SettingsToolsStatePatterns on SettingsToolsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SettingsToolsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SettingsToolsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SettingsToolsState value)  $default,){
final _that = this;
switch (_that) {
case _SettingsToolsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SettingsToolsState value)?  $default,){
final _that = this;
switch (_that) {
case _SettingsToolsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool failsRequests,  bool isClearingCache,  UiMessage? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SettingsToolsState() when $default != null:
return $default(_that.failsRequests,_that.isClearingCache,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool failsRequests,  bool isClearingCache,  UiMessage? message)  $default,) {final _that = this;
switch (_that) {
case _SettingsToolsState():
return $default(_that.failsRequests,_that.isClearingCache,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool failsRequests,  bool isClearingCache,  UiMessage? message)?  $default,) {final _that = this;
switch (_that) {
case _SettingsToolsState() when $default != null:
return $default(_that.failsRequests,_that.isClearingCache,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _SettingsToolsState implements SettingsToolsState {
  const _SettingsToolsState({this.failsRequests = false, this.isClearingCache = false, this.message});
  

/// "Simulate network failure".
@override@JsonKey() final  bool failsRequests;
@override@JsonKey() final  bool isClearingCache;
/// A one-time SnackBar.
@override final  UiMessage? message;

/// Create a copy of SettingsToolsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsToolsStateCopyWith<_SettingsToolsState> get copyWith => __$SettingsToolsStateCopyWithImpl<_SettingsToolsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SettingsToolsState&&(identical(other.failsRequests, failsRequests) || other.failsRequests == failsRequests)&&(identical(other.isClearingCache, isClearingCache) || other.isClearingCache == isClearingCache)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failsRequests,isClearingCache,message);
}

@override
String toString() {
    return 'SettingsToolsState(failsRequests: $failsRequests, isClearingCache: $isClearingCache, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SettingsToolsStateCopyWith<$Res> implements $SettingsToolsStateCopyWith<$Res> {
  factory _$SettingsToolsStateCopyWith(_SettingsToolsState value, $Res Function(_SettingsToolsState) _then) = __$SettingsToolsStateCopyWithImpl;
@override @useResult
$Res call({
 bool failsRequests, bool isClearingCache, UiMessage? message
});


@override $UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$SettingsToolsStateCopyWithImpl<$Res>
    implements _$SettingsToolsStateCopyWith<$Res> {
  __$SettingsToolsStateCopyWithImpl(this._self, this._then);

  final _SettingsToolsState _self;
  final $Res Function(_SettingsToolsState) _then;

/// Create a copy of SettingsToolsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? failsRequests = null,Object? isClearingCache = null,Object? message = freezed,}) {
  return _then(_SettingsToolsState(
failsRequests: null == failsRequests ? _self.failsRequests : failsRequests // ignore: cast_nullable_to_non_nullable
as bool,isClearingCache: null == isClearingCache ? _self.isClearingCache : isClearingCache // ignore: cast_nullable_to_non_nullable
as bool,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of SettingsToolsState
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
