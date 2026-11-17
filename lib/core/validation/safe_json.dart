import 'package:json_annotation/json_annotation.dart';

/// Thrown when a response body does not match the DTO it should become.
/// The message names the DTO and the field, for example:
///   AuthResponseDto: field "accessToken" is missing or has the wrong type.
/// safeApiCall converts it into a friendly ApiError; it never reaches the UI.
class DtoParsingException implements Exception {
  const DtoParsingException(this.message);

  final String message;

  @override
  String toString() => 'DtoParsingException: $message';
}

/// Converts a decoded JSON value into a DTO without crashing on bad data.
///
///   final dto = parseDto(response.data, UserDto.fromJson, name: 'UserDto');
///
/// Every remote data source parses through this (or [parseDtoList]).
T parseDto<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson, {
  required String name,
}) {
  if (json is! Map) {
    throw DtoParsingException(
      '$name: expected a JSON object but got ${json == null ? 'null' : json.runtimeType}.',
    );
  }
  try {
    return fromJson(Map<String, dynamic>.from(json));
  } on CheckedFromJsonException catch (e) {
    final field = e.key == null ? 'a field' : 'field "${e.key}"';
    throw DtoParsingException(
      '$name: $field is missing or has the wrong type.',
    );
  } on DtoParsingException {
    rethrow;
  } on FormatException catch (e) {
    throw DtoParsingException('$name: ${e.message}');
  } on TypeError catch (e) {
    throw DtoParsingException(
      '$name: a field is missing or has the wrong type ($e).',
    );
  }
}

/// Same as [parseDto] for a JSON array of objects.
List<T> parseDtoList<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson, {
  required String name,
}) {
  if (json is! List) {
    throw DtoParsingException(
      '$name list: expected a JSON array but got ${json == null ? 'null' : json.runtimeType}.',
    );
  }
  return <T>[for (final item in json) parseDto<T>(item, fromJson, name: name)];
}

/// Parses a "YYYY-MM-DD" or ISO-8601 string, with a readable error.
DateTime parseDate(String value, {required String field}) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw DtoParsingException('field "$field" is not a valid date: "$value".');
  }
  return parsed;
}
