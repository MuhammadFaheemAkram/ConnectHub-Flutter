// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SessionState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'SessionState()';
}


}

/// @nodoc
class $SessionStateCopyWith<$Res>  {
$SessionStateCopyWith(SessionState _, $Res Function(SessionState) __);
}


/// Adds pattern-matching-related methods to [SessionState].
extension SessionStatePatterns on SessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SignedIn value)?  signedIn,TResult Function( SignedOut value)?  signedOut,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SignedIn() when signedIn != null:
return signedIn(_that);case SignedOut() when signedOut != null:
return signedOut(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SignedIn value)  signedIn,required TResult Function( SignedOut value)  signedOut,}){
final _that = this;
switch (_that) {
case SignedIn():
return signedIn(_that);case SignedOut():
return signedOut(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SignedIn value)?  signedIn,TResult? Function( SignedOut value)?  signedOut,}){
final _that = this;
switch (_that) {
case SignedIn() when signedIn != null:
return signedIn(_that);case SignedOut() when signedOut != null:
return signedOut(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Session session)?  signedIn,TResult Function( SignOutReason reason)?  signedOut,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SignedIn() when signedIn != null:
return signedIn(_that.session);case SignedOut() when signedOut != null:
return signedOut(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Session session)  signedIn,required TResult Function( SignOutReason reason)  signedOut,}) {final _that = this;
switch (_that) {
case SignedIn():
return signedIn(_that.session);case SignedOut():
return signedOut(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Session session)?  signedIn,TResult? Function( SignOutReason reason)?  signedOut,}) {final _that = this;
switch (_that) {
case SignedIn() when signedIn != null:
return signedIn(_that.session);case SignedOut() when signedOut != null:
return signedOut(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class SignedIn implements SessionState {
  const SignedIn(this.session);
  

 final  Session session;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedInCopyWith<SignedIn> get copyWith => _$SignedInCopyWithImpl<SignedIn>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedIn&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session);
}

@override
String toString() {
    return 'SessionState.signedIn(session: $session)';
}


}

/// @nodoc
abstract mixin class $SignedInCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SignedInCopyWith(SignedIn value, $Res Function(SignedIn) _then) = _$SignedInCopyWithImpl;
@useResult
$Res call({
 Session session
});


$SessionCopyWith<$Res> get session;

}
/// @nodoc
class _$SignedInCopyWithImpl<$Res>
    implements $SignedInCopyWith<$Res> {
  _$SignedInCopyWithImpl(this._self, this._then);

  final SignedIn _self;
  final $Res Function(SignedIn) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(SignedIn(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Session,
  ));
}

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SessionCopyWith<$Res> get session {
  
  return $SessionCopyWith<$Res>(_self.session, (value) {
    return _then(_self.copyWith(session: value));
  });
}
}

/// @nodoc


class SignedOut implements SessionState {
  const SignedOut({this.reason = SignOutReason.none});
  

@JsonKey() final  SignOutReason reason;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignedOutCopyWith<SignedOut> get copyWith => _$SignedOutCopyWithImpl<SignedOut>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SignedOut&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'SessionState.signedOut(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $SignedOutCopyWith<$Res> implements $SessionStateCopyWith<$Res> {
  factory $SignedOutCopyWith(SignedOut value, $Res Function(SignedOut) _then) = _$SignedOutCopyWithImpl;
@useResult
$Res call({
 SignOutReason reason
});




}
/// @nodoc
class _$SignedOutCopyWithImpl<$Res>
    implements $SignedOutCopyWith<$Res> {
  _$SignedOutCopyWithImpl(this._self, this._then);

  final SignedOut _self;
  final $Res Function(SignedOut) _then;

/// Create a copy of SessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(SignedOut(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SignOutReason,
  ));
}


}

// dart format on
