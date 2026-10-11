// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'search_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResponseDto _$SearchResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SearchResponseDto', json, ($checkedConvert) {
      final val = SearchResponseDto(
        users: $checkedConvert(
          'users',
          (v) => (v as List<dynamic>)
              .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        posts: $checkedConvert(
          'posts',
          (v) => (v as List<dynamic>)
              .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });
