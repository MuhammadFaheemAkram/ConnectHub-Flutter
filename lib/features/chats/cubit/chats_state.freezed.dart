// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatsState {

 ChatsStatus get status;/// Every cached conversation, the most recent activity first.
 List<Conversation> get conversations;/// The search field's text, as typed.
 String get query; String get errorMessage;/// A one-time SnackBar.
 UiMessage? get message;
/// Create a copy of ChatsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsStateCopyWith<ChatsState> get copyWith => _$ChatsStateCopyWithImpl<ChatsState>(this as ChatsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ChatsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsState&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.conversations, _this.conversations)&&(identical(other.query, _this.query) || other.query == _this.query)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.message, _this.message) || other.message == _this.message));
}


@override
int get hashCode {
  final _this = this as ChatsState;
  return Object.hash(runtimeType,_this.status,const DeepCollectionEquality().hash(_this.conversations),_this.query,_this.errorMessage,_this.message);
}

@override
String toString() {
  final _this = this as ChatsState;
  return 'ChatsState(status: ${_this.status}, conversations: ${_this.conversations}, query: ${_this.query}, errorMessage: ${_this.errorMessage}, message: ${_this.message})';
}


}

/// @nodoc
abstract mixin class $ChatsStateCopyWith<$Res>  {
  factory $ChatsStateCopyWith(ChatsState value, $Res Function(ChatsState) _then) = _$ChatsStateCopyWithImpl;
@useResult
$Res call({
 ChatsStatus status, List<Conversation> conversations, String query, String errorMessage, UiMessage? message
});


$UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$ChatsStateCopyWithImpl<$Res>
    implements $ChatsStateCopyWith<$Res> {
  _$ChatsStateCopyWithImpl(this._self, this._then);

  final ChatsState _self;
  final $Res Function(ChatsState) _then;

/// Create a copy of ChatsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? conversations = null,Object? query = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(ChatsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatsStatus,conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}
/// Create a copy of ChatsState
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


/// Adds pattern-matching-related methods to [ChatsState].
extension ChatsStatePatterns on ChatsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsState value)  $default,){
final _that = this;
switch (_that) {
case _ChatsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChatsStatus status,  List<Conversation> conversations,  String query,  String errorMessage,  UiMessage? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsState() when $default != null:
return $default(_that.status,_that.conversations,_that.query,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChatsStatus status,  List<Conversation> conversations,  String query,  String errorMessage,  UiMessage? message)  $default,) {final _that = this;
switch (_that) {
case _ChatsState():
return $default(_that.status,_that.conversations,_that.query,_that.errorMessage,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChatsStatus status,  List<Conversation> conversations,  String query,  String errorMessage,  UiMessage? message)?  $default,) {final _that = this;
switch (_that) {
case _ChatsState() when $default != null:
return $default(_that.status,_that.conversations,_that.query,_that.errorMessage,_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsState extends ChatsState {
  const _ChatsState({this.status = ChatsStatus.loading,  List<Conversation> conversations = const <Conversation>[], this.query = '', this.errorMessage = '', this.message}): _conversations = conversations,super._();
  

@override@JsonKey() final  ChatsStatus status;
/// Every cached conversation, the most recent activity first.
 final  List<Conversation> _conversations;
/// Every cached conversation, the most recent activity first.
@override@JsonKey() List<Conversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

/// The search field's text, as typed.
@override@JsonKey() final  String query;
@override@JsonKey() final  String errorMessage;
/// A one-time SnackBar.
@override final  UiMessage? message;

/// Create a copy of ChatsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsStateCopyWith<_ChatsState> get copyWith => __$ChatsStateCopyWithImpl<_ChatsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.conversations, _conversations)&&(identical(other.query, query) || other.query == query)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_conversations),query,errorMessage,message);
}

@override
String toString() {
    return 'ChatsState(status: $status, conversations: $conversations, query: $query, errorMessage: $errorMessage, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ChatsStateCopyWith<$Res> implements $ChatsStateCopyWith<$Res> {
  factory _$ChatsStateCopyWith(_ChatsState value, $Res Function(_ChatsState) _then) = __$ChatsStateCopyWithImpl;
@override @useResult
$Res call({
 ChatsStatus status, List<Conversation> conversations, String query, String errorMessage, UiMessage? message
});


@override $UiMessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$ChatsStateCopyWithImpl<$Res>
    implements _$ChatsStateCopyWith<$Res> {
  __$ChatsStateCopyWithImpl(this._self, this._then);

  final _ChatsState _self;
  final $Res Function(_ChatsState) _then;

/// Create a copy of ChatsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? conversations = null,Object? query = null,Object? errorMessage = null,Object? message = freezed,}) {
  return _then(_ChatsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChatsStatus,conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,errorMessage: null == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as UiMessage?,
  ));
}

/// Create a copy of ChatsState
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
