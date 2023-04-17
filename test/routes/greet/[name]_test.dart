import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../routes/greet/[name].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

void main() {
  test('Test untuk /greet/[name]', () {
    final context = _MockRequestContext();

    when(
      () => context.read<String>(),
    ).thenAnswer((_) => 'Hello');

    final response = route.onRequest(context, 'Jennie');

    expect(response.statusCode, equals(HttpStatus.ok));
    expect(response.body(), completion(equals('Hello Jennie! How are you?')));
  });
}
