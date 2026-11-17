import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:smart_memories/core/validation/safe_json.dart';

class _Item {
  const _Item(this.id);

  final String id;

  /// Behaves like generated code: a missing or wrongly typed field throws.
  static _Item fromJson(Map<String, dynamic> json) => _Item(json['id'] as String);
}

void main() {
  group('unwrapData', () {
    test('returns the data part of a { message, data } envelope', () {
      expect(
        unwrapData(<String, dynamic>{
          'message': 'Done',
          'data': <String, dynamic>{'id': 'a1'},
        }),
        <String, dynamic>{'id': 'a1'},
      );
    });

    test('returns a list inside the envelope', () {
      expect(
        unwrapData(<String, dynamic>{
          'message': 'Done',
          'data': <Object?>[1, 2],
        }),
        <Object?>[1, 2],
      );
    });

    test('leaves a body without a data key unchanged', () {
      final body = <String, dynamic>{'message': 'Done'};
      expect(unwrapData(body), same(body));
    });

    test('leaves null unchanged', () {
      expect(unwrapData(null), isNull);
    });
  });

  group('parseDto', () {
    test('parses a valid object', () {
      final item = parseDto(
        <String, dynamic>{'id': 'a1'},
        _Item.fromJson,
        name: 'Item',
      );

      expect(item.id, 'a1');
    });

    test('explains when the body is not an object', () {
      expect(
        () => parseDto(null, _Item.fromJson, name: 'Item'),
        throwsA(
          isA<DtoParsingException>().having(
            (e) => e.message,
            'message',
            'Item: expected a JSON object but got null.',
          ),
        ),
      );
      expect(
        () => parseDto(<Object?>[], _Item.fromJson, name: 'Item'),
        throwsA(isA<DtoParsingException>()),
      );
    });

    test('turns a missing field into a readable error, not a crash', () {
      expect(
        () => parseDto(<String, dynamic>{}, _Item.fromJson, name: 'Item'),
        throwsA(
          isA<DtoParsingException>().having(
            (e) => e.message,
            'message',
            startsWith('Item: a field is missing or has the wrong type'),
          ),
        ),
      );
    });

    test('names the field when generated code reports it', () {
      _Item checked(Map<String, dynamic> json) {
        throw CheckedFromJsonException(json, 'id', 'Item', 'Missing');
      }

      expect(
        () => parseDto(<String, dynamic>{}, checked, name: 'Item'),
        throwsA(
          isA<DtoParsingException>().having(
            (e) => e.message,
            'message',
            'Item: field "id" is missing or has the wrong type.',
          ),
        ),
      );
    });
  });

  group('parseDtoList', () {
    test('parses every item', () {
      final items = parseDtoList(
        <Object?>[
          <String, dynamic>{'id': 'a'},
          <String, dynamic>{'id': 'b'},
        ],
        _Item.fromJson,
        name: 'Item',
      );

      expect(items.map((i) => i.id), <String>['a', 'b']);
    });

    test('explains when the body is not an array', () {
      expect(
        () => parseDtoList(<String, dynamic>{}, _Item.fromJson, name: 'Item'),
        throwsA(isA<DtoParsingException>()),
      );
    });
  });

  group('parseDate', () {
    test('parses an ISO date', () {
      expect(parseDate('2023-11-15', field: 'memoryDate'), DateTime(2023, 11, 15));
    });

    test('explains an invalid date', () {
      expect(
        () => parseDate('15/11/2023', field: 'memoryDate'),
        throwsA(
          isA<DtoParsingException>().having(
            (e) => e.message,
            'message',
            contains('memoryDate'),
          ),
        ),
      );
    });
  });
}