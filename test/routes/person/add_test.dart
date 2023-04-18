import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/person/add.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _FakeRequest extends Fake implements Request {
  _FakeRequest({
    this.httpMethod = HttpMethod.post,
    this.jsonData = const {},
  });

  final HttpMethod httpMethod;
  final Map<String, dynamic> jsonData;

  @override
  Future<Map<String, dynamic>> json() async => jsonData;

  @override
  HttpMethod get method => httpMethod;
}

void main() async {
  final context = _MockRequestContext();
  final request = _FakeRequest(jsonData: {'name': 'Jennie Kim'});

  when(
    () => context.request,
  ).thenAnswer((_) => request);

  final response = await route.onRequest(context);
  final json = await response.json();

  group('Add Test Berhasil', () {
    test('Status code = OK', () {
      expect(response.statusCode, equals(HttpStatus.ok));
    });

    test('Response memiliki data berupa JSON', () {
      expect(json, isNotNull);
      expect(json, isA<Map<String, dynamic>>());
    });

    test("Json memiliki key 'Data'", () {
      expect((json! as Map<String, dynamic>)['data'], isNotNull);
    });

    final person =
        (json! as Map<String, dynamic>)['data'] as Map<String, dynamic>;

    test('Person memiliki ID integerr 0-99', () {
      expect(person['id'], isNotNull);
      expect(person['id'], isA<int>());
      expect(person['id'], greaterThanOrEqualTo(0));
      expect(person['id'], lessThan(100));
    });

    test('Name sesuai dengan yang diberikan', () {
      expect(person['name'], equals('Jennie Kim'));
    });
  });

  group('Add Test Gagal', () {
    test('HttpMethod harus POST', () async {
      final context = _MockRequestContext();
      final request = _FakeRequest(
        httpMethod: HttpMethod.get,
        jsonData: {'name': 'Jennie Kim'},
      );

      when(
        () => context.request,
      ).thenAnswer((_) => request);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.methodNotAllowed));

      final json = await response.json();

      expect(json, isNotNull);
      expect((json! as Map<String, dynamic>)['message'], isNotNull);
    });

    test('Request memiliki name', () async {
      final context = _MockRequestContext();
      final request = _FakeRequest();

      when(
        () => context.request,
      ).thenAnswer((_) => request);

      final response = await route.onRequest(context);

      expect(response.statusCode, equals(HttpStatus.badRequest));

      final json = await response.json();

      expect(json, isNotNull);
      expect((json! as Map<String, dynamic>)['message'], isNotNull);
    });
  });
}
