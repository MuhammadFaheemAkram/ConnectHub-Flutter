// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badges_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BadgesState {

/// Settings → "Show unread badges".
 bool get enabled; int get unreadNotifications; int get unreadMessages;
/// Create a copy of BadgesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgesStateCopyWith<BadgesState> get copyWith => _$BadgesStateCopyWithImpl<BadgesState>(this as BadgesState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BadgesState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgesState&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.unreadNotifications, _this.unreadNotifications) || other.unreadNotifications == _this.unreadNotifications)&&(identical(other.unreadMessages, _this.unreadMessages) || other.unreadMessages == _this.unreadMessages));
}


@override
int get hashCode {
  final _this = this as BadgesState;
  return Object.hash(runtimeType,_this.enabled,_this.unreadNotifications,_this.unreadMessages);
}

@override
String toString() {
  final _this = this as BadgesState;
  return 'BadgesState(enabled: ${_this.enabled}, unreadNotifications: ${_this.unreadNotifications}, unreadMessages: ${_this.unreadMessages})';
}


}

/// @nodoc
abstract mixin class $BadgesStateCopyWith<$Res>  {
  factory $BadgesStateCopyWith(BadgesState value, $Res Function(BadgesState) _then) = _$BadgesStateCopyWithImpl;
@useResult
$Res call({
 bool enabled, int unreadNotifications, int unreadMessages
});




}
/// @nodoc
class _$BadgesStateCopyWithImpl<$Res>
    implements $BadgesStateCopyWith<$Res> {
  _$BadgesStateCopyWithImpl(this._self, this._then);

  final BadgesState _self;
  final $Res Function(BadgesState) _then;

/// Create a copy of BadgesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? unreadNotifications = null,Object? unreadMessages = null,}) {
  return _then(BadgesState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BadgesState].
extension BadgesStatePatterns on BadgesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgesState value)  $default,){
final _that = this;
switch (_that) {
case _BadgesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgesState value)?  $default,){
final _that = this;
switch (_that) {
case _BadgesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int unreadNotifications,  int unreadMessages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgesState() when $default != null:
return $default(_that.enabled,_that.unreadNotifications,_that.unreadMessages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int unreadNotifications,  int unreadMessages)  $default,) {final _that = this;
switch (_that) {
case _BadgesState():
return $default(_that.enabled,_that.unreadNotifications,_that.unreadMessages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int unreadNotifications,  int unreadMessages)?  $default,) {final _that = this;
switch (_that) {
case _BadgesState() when $default != null:
return $default(_that.enabled,_that.unreadNotifications,_that.unreadMessages);case _:
  return null;

}
}

}

/// @nodoc


class _BadgesState extends BadgesState {
  const _BadgesState({this.enabled = true, this.unreadNotifications = 0, this.unreadMessages = 0}): super._();
  

/// Settings → "Show unread badges".
@override@JsonKey() final  bool enabled;
@override@JsonKey() final  int unreadNotifications;
@override@JsonKey() final  int unreadMessages;

/// Create a copy of BadgesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgesStateCopyWith<_BadgesState> get copyWith => __$BadgesStateCopyWithImpl<_BadgesState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgesState&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.unreadNotifications, unreadNotifications) || other.unreadNotifications == unreadNotifications)&&(identical(other.unreadMessages, unreadMessages) || other.unreadMessages == unreadMessages));
}


@override
int get hashCode {
    return Object.hash(runtimeType,enabled,unreadNotifications,unreadMessages);
}

@override
String toString() {
    return 'BadgesState(enabled: $enabled, unreadNotifications: $unreadNotifications, unreadMessages: $unreadMessages)';
}


}

/// @nodoc
abstract mixin class _$BadgesStateCopyWith<$Res> implements $BadgesStateCopyWith<$Res> {
  factory _$BadgesStateCopyWith(_BadgesState value, $Res Function(_BadgesState) _then) = __$BadgesStateCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int unreadNotifications, int unreadMessages
});




}
/// @nodoc
class __$BadgesStateCopyWithImpl<$Res>
    implements _$BadgesStateCopyWith<$Res> {
  __$BadgesStateCopyWithImpl(this._self, this._then);

  final _BadgesState _self;
  final $Res Function(_BadgesState) _then;

/// Create a copy of BadgesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? unreadNotifications = null,Object? unreadMessages = null,}) {
  return _then(_BadgesState(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,unreadNotifications: null == unreadNotifications ? _self.unreadNotifications : unreadNotifications // ignore: cast_nullable_to_non_nullable
as int,unreadMessages: null == unreadMessages ? _self.unreadMessages : unreadMessages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
