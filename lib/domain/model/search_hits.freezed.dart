// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_hits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchHits {

 List<String> get userIds; List<String> get postIds;
/// Create a copy of SearchHits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHitsCopyWith<SearchHits> get copyWith => _$SearchHitsCopyWithImpl<SearchHits>(this as SearchHits, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SearchHits;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHits&&const DeepCollectionEquality().equals(other.userIds, _this.userIds)&&const DeepCollectionEquality().equals(other.postIds, _this.postIds));
}


@override
int get hashCode {
  final _this = this as SearchHits;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.userIds),const DeepCollectionEquality().hash(_this.postIds));
}

@override
String toString() {
  final _this = this as SearchHits;
  return 'SearchHits(userIds: ${_this.userIds}, postIds: ${_this.postIds})';
}


}

/// @nodoc
abstract mixin class $SearchHitsCopyWith<$Res>  {
  factory $SearchHitsCopyWith(SearchHits value, $Res Function(SearchHits) _then) = _$SearchHitsCopyWithImpl;
@useResult
$Res call({
 List<String> userIds, List<String> postIds
});




}
/// @nodoc
class _$SearchHitsCopyWithImpl<$Res>
    implements $SearchHitsCopyWith<$Res> {
  _$SearchHitsCopyWithImpl(this._self, this._then);

  final SearchHits _self;
  final $Res Function(SearchHits) _then;

/// Create a copy of SearchHits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userIds = null,Object? postIds = null,}) {
  return _then(SearchHits(
userIds: null == userIds ? _self.userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,postIds: null == postIds ? _self.postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHits].
extension SearchHitsPatterns on SearchHits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHits value)  $default,){
final _that = this;
switch (_that) {
case _SearchHits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHits value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> userIds,  List<String> postIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHits() when $default != null:
return $default(_that.userIds,_that.postIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> userIds,  List<String> postIds)  $default,) {final _that = this;
switch (_that) {
case _SearchHits():
return $default(_that.userIds,_that.postIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> userIds,  List<String> postIds)?  $default,) {final _that = this;
switch (_that) {
case _SearchHits() when $default != null:
return $default(_that.userIds,_that.postIds);case _:
  return null;

}
}

}

/// @nodoc


class _SearchHits implements SearchHits {
  const _SearchHits({ List<String> userIds = const <String>[],  List<String> postIds = const <String>[]}): _userIds = userIds,_postIds = postIds;
  

 final  List<String> _userIds;
@override@JsonKey() List<String> get userIds {
  if (_userIds is EqualUnmodifiableListView) return _userIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userIds);
}

 final  List<String> _postIds;
@override@JsonKey() List<String> get postIds {
  if (_postIds is EqualUnmodifiableListView) return _postIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postIds);
}


/// Create a copy of SearchHits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHitsCopyWith<_SearchHits> get copyWith => __$SearchHitsCopyWithImpl<_SearchHits>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHits&&const DeepCollectionEquality().equals(other.userIds, _userIds)&&const DeepCollectionEquality().equals(other.postIds, _postIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_userIds),const DeepCollectionEquality().hash(_postIds));
}

@override
String toString() {
    return 'SearchHits(userIds: $userIds, postIds: $postIds)';
}


}

/// @nodoc
abstract mixin class _$SearchHitsCopyWith<$Res> implements $SearchHitsCopyWith<$Res> {
  factory _$SearchHitsCopyWith(_SearchHits value, $Res Function(_SearchHits) _then) = __$SearchHitsCopyWithImpl;
@override @useResult
$Res call({
 List<String> userIds, List<String> postIds
});




}
/// @nodoc
class __$SearchHitsCopyWithImpl<$Res>
    implements _$SearchHitsCopyWith<$Res> {
  __$SearchHitsCopyWithImpl(this._self, this._then);

  final _SearchHits _self;
  final $Res Function(_SearchHits) _then;

/// Create a copy of SearchHits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userIds = null,Object? postIds = null,}) {
  return _then(_SearchHits(
userIds: null == userIds ? _self._userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,postIds: null == postIds ? _self._postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
