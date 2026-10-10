// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'post_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPageDto _$PostPageDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PostPageDto', json, ($checkedConvert) {
      final val = PostPageDto(
        posts: $checkedConvert(
          'posts',
          (v) => (v as List<dynamic>)
              .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        nextCursor: $checkedConvert('nextCursor', (v) => v as String?),
      );
      return val;
    });
