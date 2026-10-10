// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SignUpState {

 String get name; String get email; String get password; String get confirmPassword;/// As on Login: quiet until the first submit, then live.
 bool get showErrors; FormStatus get status;/// The server's answer, e.g. "An account with this email already exists.".
 String? get errorMessage;
/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SignUpStateCopyWith<SignUpState> get copyWith => _$SignUpStateCopyWithImpl<SignUpState>(this as SignUpState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SignUpState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SignUpState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.confirmPassword, _this.confirmPassword) || other.confirmPassword == _this.confirmPassword)&&(identical(other.showErrors, _this.showErrors) || other.showErrors == _this.showErrors)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as SignUpState;
  return Object.hash(runtimeType,_this.name,_this.email,_this.password,_this.confirmPassword,_this.showErrors,_this.status,_this.errorMessage);
}

@override
String toString() {
  final _this = this as SignUpState;
  return 'SignUpState(name: ${_this.name}, email: ${_this.email}, password: ${_this.password}, confirmPassword: ${_this.confirmPassword}, showErrors: ${_this.showErrors}, status: ${_this.status}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $SignUpStateCopyWith<$Res>  {
  factory $SignUpStateCopyWith(SignUpState value, $Res Function(SignUpState) _then) = _$SignUpStateCopyWithImpl;
@useResult
$Res call({
 String name, String email, String password, String confirmPassword, bool showErrors, FormStatus status, String? errorMessage
});




}
/// @nodoc
class _$SignUpStateCopyWithImpl<$Res>
    implements $SignUpStateCopyWith<$Res> {
  _$SignUpStateCopyWithImpl(this._self, this._then);

  final SignUpState _self;
  final $Res Function(SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? email = null,Object? password = null,Object? confirmPassword = null,Object? showErrors = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(SignUpState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SignUpState].
extension SignUpStatePatterns on SignUpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SignUpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SignUpState value)  $default,){
final _that = this;
switch (_that) {
case _SignUpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SignUpState value)?  $default,){
final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String email,  String password,  String confirmPassword,  bool showErrors,  FormStatus status,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.name,_that.email,_that.password,_that.confirmPassword,_that.showErrors,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String email,  String password,  String confirmPassword,  bool showErrors,  FormStatus status,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SignUpState():
return $default(_that.name,_that.email,_that.password,_that.confirmPassword,_that.showErrors,_that.status,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String email,  String password,  String confirmPassword,  bool showErrors,  FormStatus status,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SignUpState() when $default != null:
return $default(_that.name,_that.email,_that.password,_that.confirmPassword,_that.showErrors,_that.status,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SignUpState extends SignUpState {
  const _SignUpState({this.name = '', this.email = '', this.password = '', this.confirmPassword = '', this.showErrors = false, this.status = FormStatus.idle, this.errorMessage}): super._();
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String email;
@override@JsonKey() final  String password;
@override@JsonKey() final  String confirmPassword;
/// As on Login: quiet until the first submit, then live.
@override@JsonKey() final  bool showErrors;
@override@JsonKey() final  FormStatus status;
/// The server's answer, e.g. "An account with this email already exists.".
@override final  String? errorMessage;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SignUpStateCopyWith<_SignUpState> get copyWith => __$SignUpStateCopyWithImpl<_SignUpState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SignUpState&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.showErrors, showErrors) || other.showErrors == showErrors)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,email,password,confirmPassword,showErrors,status,errorMessage);
}

@override
String toString() {
    return 'SignUpState(name: $name, email: $email, password: $password, confirmPassword: $confirmPassword, showErrors: $showErrors, status: $status, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SignUpStateCopyWith<$Res> implements $SignUpStateCopyWith<$Res> {
  factory _$SignUpStateCopyWith(_SignUpState value, $Res Function(_SignUpState) _then) = __$SignUpStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String email, String password, String confirmPassword, bool showErrors, FormStatus status, String? errorMessage
});




}
/// @nodoc
class __$SignUpStateCopyWithImpl<$Res>
    implements _$SignUpStateCopyWith<$Res> {
  __$SignUpStateCopyWithImpl(this._self, this._then);

  final _SignUpState _self;
  final $Res Function(_SignUpState) _then;

/// Create a copy of SignUpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? email = null,Object? password = null,Object? confirmPassword = null,Object? showErrors = null,Object? status = null,Object? errorMessage = freezed,}) {
  return _then(_SignUpState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,showErrors: null == showErrors ? _self.showErrors : showErrors // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FormStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
