// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UiMessage {

 int get id; String get text;/// A button on the message, such as Undo.
 UiMessageAction? get action;
/// Create a copy of UiMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UiMessageCopyWith<UiMessage> get copyWith => _$UiMessageCopyWithImpl<UiMessage>(this as UiMessage, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UiMessage;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UiMessage&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.text, _this.text) || other.text == _this.text)&&(identical(other.action, _this.action) || other.action == _this.action));
}


@override
int get hashCode {
  final _this = this as UiMessage;
  return Object.hash(runtimeType,_this.id,_this.text,_this.action);
}

@override
String toString() {
  final _this = this as UiMessage;
  return 'UiMessage(id: ${_this.id}, text: ${_this.text}, action: ${_this.action})';
}


}

/// @nodoc
abstract mixin class $UiMessageCopyWith<$Res>  {
  factory $UiMessageCopyWith(UiMessage value, $Res Function(UiMessage) _then) = _$UiMessageCopyWithImpl;
@useResult
$Res call({
 int id, String text, UiMessageAction? action
});




}
/// @nodoc
class _$UiMessageCopyWithImpl<$Res>
    implements $UiMessageCopyWith<$Res> {
  _$UiMessageCopyWithImpl(this._self, this._then);

  final UiMessage _self;
  final $Res Function(UiMessage) _then;

/// Create a copy of UiMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? action = freezed,}) {
  return _then(UiMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as UiMessageAction?,
  ));
}

}


/// Adds pattern-matching-related methods to [UiMessage].
extension UiMessagePatterns on UiMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UiMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UiMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UiMessage value)  $default,){
final _that = this;
switch (_that) {
case _UiMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UiMessage value)?  $default,){
final _that = this;
switch (_that) {
case _UiMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String text,  UiMessageAction? action)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UiMessage() when $default != null:
return $default(_that.id,_that.text,_that.action);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String text,  UiMessageAction? action)  $default,) {final _that = this;
switch (_that) {
case _UiMessage():
return $default(_that.id,_that.text,_that.action);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String text,  UiMessageAction? action)?  $default,) {final _that = this;
switch (_that) {
case _UiMessage() when $default != null:
return $default(_that.id,_that.text,_that.action);case _:
  return null;

}
}

}

/// @nodoc


class _UiMessage implements UiMessage {
  const _UiMessage({required this.id, required this.text, this.action});
  

@override final  int id;
@override final  String text;
/// A button on the message, such as Undo.
@override final  UiMessageAction? action;

/// Create a copy of UiMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UiMessageCopyWith<_UiMessage> get copyWith => __$UiMessageCopyWithImpl<_UiMessage>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UiMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.action, action) || other.action == action));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,text,action);
}

@override
String toString() {
    return 'UiMessage(id: $id, text: $text, action: $action)';
}


}

/// @nodoc
abstract mixin class _$UiMessageCopyWith<$Res> implements $UiMessageCopyWith<$Res> {
  factory _$UiMessageCopyWith(_UiMessage value, $Res Function(_UiMessage) _then) = __$UiMessageCopyWithImpl;
@override @useResult
$Res call({
 int id, String text, UiMessageAction? action
});




}
/// @nodoc
class __$UiMessageCopyWithImpl<$Res>
    implements _$UiMessageCopyWith<$Res> {
  __$UiMessageCopyWithImpl(this._self, this._then);

  final _UiMessage _self;
  final $Res Function(_UiMessage) _then;

/// Create a copy of UiMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? action = freezed,}) {
  return _then(_UiMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as UiMessageAction?,
  ));
}


}

// dart format on
