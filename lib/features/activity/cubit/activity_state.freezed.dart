// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ActivityState {

 ActivityStatus get status; ActivityFilter get filter;/// Every cached notification, newest first, whatever the filter.
 List<AppNotification> get notifications; String get errorMessage;/// A one-time SnackBar.
 UiMessage? get message;
/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityStateCopyWith<ActivityState> get copyWith => _$ActivityStateCopyWithImpl<ActivityState>(this as ActivityState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ActivityState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActivityState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.filter, _this.filter) || other.filter == _this.filter)&&const DeepCollectionEquality().equals(other.notifications, _this.notifications)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as ActivityState;
  return Object.hash(runtimeType,_this.status,_this.filter,const DeepCollectionEquality().hash(_this.notifications),_this.errorMessage,_this.message);
}

@override
String toString() {
  final _this = this as ActivityState;
  return 'ActivityState(status: ${_this.status}, filter: ${_this.filter}, notifications: ${_this.notifications}, errorMessage: ${_this.errorMessage}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ActivityStateCopyWith<$Res>  {
  factory $ActivityStateCopyWith(ActivityState value, $Res Function(ActivityState) _then) = _$ActivityStateCopyWithImpl;
@useResult
$Res call({
 ActivityStatus status, ActivityFilter filter, List<AppNotification> notifications, String errorMessage, UiMessage? message
});


$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$ActivityStateCopyWithImpl<$Res>
    implements $ActivityStateCopyWith<$Res> {
  _$ActivityStateCopyWithImpl(this._self, this._then);

  final ActivityState _self;
  final $Res Function(ActivityState) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? filter = null,Object? notifications = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(ActivityState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ActivityFilter,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}
/// Create a copy of ActivityState
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


/// Adds pattern-matching-related methods to [ActivityState].
extension ActivityStatePatterns on ActivityState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActivityState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActivityState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActivityState value)  $default,){
final _that = this;
switch (_that) {
case _ActivityState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActivityState value)?  $default,){
final _that = this;
switch (_that) {
case _ActivityState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ActivityStatus status,  ActivityFilter filter,  List<AppNotification> notifications,  String errorMessage,  UiMessage? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActivityState() when $default != null:
return $default(_that.status,_that.filter,_that.notifications,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ActivityStatus status,  ActivityFilter filter,  List<AppNotification> notifications,  String errorMessage,  UiMessage? message)  $default,) {final _that = this;
switch (_that) {
case _ActivityState():
return $default(_that.status,_that.filter,_that.notifications,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ActivityStatus status,  ActivityFilter filter,  List<AppNotification> notifications,  String errorMessage,  UiMessage? message)?  $default,) {final _that = this;
switch (_that) {
case _ActivityState() when $default != null:
return $default(_that.status,_that.filter,_that.notifications,_that.errorMessage,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ActivityState extends ActivityState {
  const _ActivityState({this.status = ActivityStatus.loading, this.filter = ActivityFilter.all,  List<AppNotification> notifications = const <AppNotification>[], this.errorMessage = '', this.message}): _notifications = notifications,super._();
  

@override@JsonKey() final  ActivityStatus status;
@override@JsonKey() final  ActivityFilter filter;
/// Every cached notification, newest first, whatever the filter.
 final  List<AppNotification> _notifications;
/// Every cached notification, newest first, whatever the filter.
@override@JsonKey() List<AppNotification> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override@JsonKey() final  String errorMessage;
/// A one-time SnackBar.
@override final  UiMessage? message;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityStateCopyWith<_ActivityState> get copyWith => __$ActivityStateCopyWithImpl<_ActivityState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActivityState&&(identical(other.status, status) || other.status == status)&&(identical(other.filter, filter) || other.filter == filter)&&const DeepCollectionEquality().equals(other.notifications, _notifications)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,filter,const DeepCollectionEquality().hash(_notifications),errorMessage,message);
}

@override
String toString() {
    return 'ActivityState(status: $status, filter: $filter, notifications: $notifications, errorMessage: $errorMessage, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ActivityStateCopyWith<$Res> implements $ActivityStateCopyWith<$Res> {
  factory _$ActivityStateCopyWith(_ActivityState value, $Res Function(_ActivityState) _then) = __$ActivityStateCopyWithImpl;
@override @useResult
$Res call({
 ActivityStatus status, ActivityFilter filter, List<AppNotification> notifications, String errorMessage, UiMessage? message
});


@override $UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$ActivityStateCopyWithImpl<$Res>
    implements _$ActivityStateCopyWith<$Res> {
  __$ActivityStateCopyWithImpl(this._self, this._then);

  final _ActivityState _self;
  final $Res Function(_ActivityState) _then;

/// Create a copy of ActivityState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? filter = null,Object? notifications = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(_ActivityState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ActivityStatus,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as ActivityFilter,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of ActivityState
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
