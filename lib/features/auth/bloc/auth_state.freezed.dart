// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthUnknown value)?  unknown,TResult Function( AuthAuthenticated value)?  authenticated,TResult Function( AuthUnauthenticated value)?  unauthenticated,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthUnknown() when unknown != null:
return unknown(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthUnknown value)  unknown,required TResult Function( AuthAuthenticated value)  authenticated,required TResult Function( AuthUnauthenticated value)  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthUnknown():
return unknown(_that);case AuthAuthenticated():
return authenticated(_that);case AuthUnauthenticated():
return unauthenticated(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthUnknown value)?  unknown,TResult? Function( AuthAuthenticated value)?  authenticated,TResult? Function( AuthUnauthenticated value)?  unauthenticated,}){
final _that = this;
switch (_that) {
case AuthUnknown() when unknown != null:
return unknown(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  unknown,TResult Function( Session session)?  authenticated,TResult Function( SignOutReason reason)?  unauthenticated,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthUnknown() when unknown != null:
return unknown();case AuthAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  unknown,required TResult Function( Session session)  authenticated,required TResult Function( SignOutReason reason)  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthUnknown():
return unknown();case AuthAuthenticated():
return authenticated(_that.session);case AuthUnauthenticated():
return unauthenticated(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  unknown,TResult? Function( Session session)?  authenticated,TResult? Function( SignOutReason reason)?  unauthenticated,}) {final _that = this;
switch (_that) {
case AuthUnknown() when unknown != null:
return unknown();case AuthAuthenticated() when authenticated != null:
return authenticated(_that.session);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class AuthUnknown implements AuthState {
  const AuthUnknown();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnknown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'AuthState.unknown()';
}


}




/// @nodoc


class AuthAuthenticated implements AuthState {
  const AuthAuthenticated(this.session);
  

 final  Session session;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAuthenticatedCopyWith<AuthAuthenticated> get copyWith => _$AuthAuthenticatedCopyWithImpl<AuthAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthenticated&&(identical(other.session, session) || other.session == session));
}


@override
int get hashCode {
    return Object.hash(runtimeType,session);
}

@override
String toString() {
    return 'AuthState.authenticated(session: $session)';
}


}

/// @nodoc
abstract mixin class $AuthAuthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthAuthenticatedCopyWith(AuthAuthenticated value, $Res Function(AuthAuthenticated) _then) = _$AuthAuthenticatedCopyWithImpl;
@useResult
$Res call({
 Session session
});


$SessionCopyWith<$Res> get session;

}
/// @nodoc
class _$AuthAuthenticatedCopyWithImpl<$Res>
    implements $AuthAuthenticatedCopyWith<$Res> {
  _$AuthAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthAuthenticated _self;
  final $Res Function(AuthAuthenticated) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? session = null,}) {
  return _then(AuthAuthenticated(
null == session ? _self.session : session // ignore: cast_nullable_to_non_nullable
as Session,
  ));
}

/// Create a copy of AuthState
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


class AuthUnauthenticated implements AuthState {
  const AuthUnauthenticated({this.reason = SignOutReason.none});
  

@JsonKey() final  SignOutReason reason;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUnauthenticatedCopyWith<AuthUnauthenticated> get copyWith => _$AuthUnauthenticatedCopyWithImpl<AuthUnauthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnauthenticated&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,reason);
}

@override
String toString() {
    return 'AuthState.unauthenticated(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AuthUnauthenticatedCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthUnauthenticatedCopyWith(AuthUnauthenticated value, $Res Function(AuthUnauthenticated) _then) = _$AuthUnauthenticatedCopyWithImpl;
@useResult
$Res call({
 SignOutReason reason
});




}
/// @nodoc
class _$AuthUnauthenticatedCopyWithImpl<$Res>
    implements $AuthUnauthenticatedCopyWith<$Res> {
  _$AuthUnauthenticatedCopyWithImpl(this._self, this._then);

  final AuthUnauthenticated _self;
  final $Res Function(AuthUnauthenticated) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(AuthUnauthenticated(
reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as SignOutReason,
  ));
}


}

// dart format on
