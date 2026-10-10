// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PostDto', json, ($checkedConvert) {
  final val = PostDto(
    id: $checkedConvert('id', (v) => v as String),
    author: $checkedConvert(
      'author',
      (v) => UserDto.fromJson(v as Map<String, dynamic>),
    ),
    content: $checkedConvert('content', (v) => v as String),
    imageUrl: $checkedConvert('imageURL', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    likeCount: $checkedConvert('likeCount', (v) => (v as num).toInt()),
    commentCount: $checkedConvert('commentCount', (v) => (v as num).toInt()),
    isLiked: $checkedConvert('isLiked', (v) => v as bool? ?? false),
    bookmarkedAt: $checkedConvert(
      'bookmarkedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'imageUrl': 'imageURL'});
